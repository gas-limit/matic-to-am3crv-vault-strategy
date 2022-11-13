// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

    //Strategy:
    // 1. Users deposit ETH 
    // 2. ETH is swapped for DAI, USDC, and USDT on on Uniswap V2
    // 3. DAI, USDC, USDT is lent on AAVE
    //      AAVE gives aDAI, aUSDC, and aUSDT tokens
    // 4. aDAI, aUSDC, and aUSDT is deposited into Curve AAVE Stablecoin pool
    //      Curve gives am3CRV tokens

    //Instructions
    //**How to Execute
    //1. A_ETHToStablesUniswap() - swap from eth to USDC, USDT, and DAI from a DEX
    //2. B_DepositIntoAAVE() - deposit USDC, USDT, and DAI into AAVE
    //3. C_DepositIntoCurve() - deposit aUSDC, aUSDT, and aDAI into Curve's AAVE stablecoin pool

    // Contract owner can lock contract which prevents users from depositing or withdrawing
    // 

contract Vault {

// ========================================= Variables and Instances 🧾

    address owner;

    //Chainlink pricefeed dolllrs per wei
    AggregatorV3Interface internal priceFeed = AggregatorV3Interface(0xAB594600376Ec9fD91F8e885dADF0CE036862dE0);

    //vault variables
    uint public totalLPTokensMinted;
    bool public isLocked;

    //Stablecoin Instances
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant DAI = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
    address constant USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address constant USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;

    //AAVE Token Instances
    address constant maDAI = 0x27F8D03b3a2196956ED754baDc28D73be8830A6e;
    address constant maUSDC = 0x1a13F4Ca1d028320A707D99520AbFefca3998b7F;
    address constant maUSDT = 0x60D55F02A771d515e077c9C2403a1ef324885CeC;

    //Curve AAVE pool LP token instance
    address constant am3CRV = 0xE7a24EF0C5e95Ffb0f6684b813A78F2a3AD7D171;

    //Uniswapv2 Router Instance
    IUniswapV2Router02 public uniswapRouter = IUniswapV2Router02(0x93bcDc45f7e62f89a8e901DC4A0E2c6C427D9F25);
    //AAVE Lending Pool instance
    IAaveLendingPool public aaveLendingPool = IAaveLendingPool(0x580D4Fdc4BF8f9b5ae2fb9225D584fED4AD5375c);
    //Curve Polygon AAVE Stablecoin Pool instance
    ICurve_AAVE_Stable_Pool curvePool = ICurve_AAVE_Stable_Pool(0x445FE580eF8d70FF569aB36e80c647af338db351);

    constructor() {
        owner = msg.sender;
    }

// ========================================= Vault Management 🔐

    //total supply of shares
    uint public totalSupply;

    //returns number of shares per user
    mapping(address => uint) public balanceOf;

    //adds shares from user deposit
    function _mint(address _to, uint _shares) private {
        totalSupply += _shares;
        balanceOf[_to] += _shares;
    }

    //burns shares from user withdrawal
    function _burn(address _from, uint _shares) private {
        totalSupply -= _shares;
        balanceOf[_from] -= _shares;
    }

    function lock(bool _lock) public {
        require(msg.sender == owner);
        isLocked =  _lock;
    }

    //add ETH to vault
    function deposit() payable external {
        require(!isLocked);
        uint shares;
        if (totalSupply == 0) {
            shares = msg.value;
        } else {
            shares = (msg.value * totalSupply) / address(this).balance;
        }

        _mint(msg.sender, shares);
    }

    function withdraw(uint _shares) external {
        require(!isLocked,"Contract Locked!");
        require(_shares <= balanceOf[msg.sender],"You dont have that many shares");
        uint amount = (_shares * address(this).balance) / totalSupply;
        _burn(msg.sender, _shares);

        //  ** send user something of amount **

    }

// ========================================= Strategy Execution Methods ⚔️

    // How to Execute
    //1. A_ETHToStablesUniswap() - swap from eth to USDC, USDT, and DAI from a DEX
    //2. B_DepositIntoAAVE() - deposit USDC, USDT, and DAI into AAVE 
    //3. C_DepositIntoCurve() - deposit aUSDC, aUSDT, and aDAI into Curve's AAVE stablecoin pool 


    function A_ETHToStablesUniswap() public {
        require(msg.sender == owner,"must be owner");

        //get amount of ETH to spend per stablecoin (1/3)
        uint thirdOfETH = address(this).balance / 3;

        // using 'now' for convenience, for mainnet pass deadline from frontend!
        uint deadline = block.timestamp + 15; 

       // tokenAmount is the minimum amount of output tokens that must be received for the transaction not to revert.
        //can use oracle
        // calculate: pricefeed returns dollars per wei
        // pricefeed * msg.value
        (,int price,,,) = priceFeed.latestRoundData();

        // dollars per matic wei * 1/3 of contract eth
        uint swapAmount = uint(price) * thirdOfETH;

        // swap all ETH to USDC, USDT, and DAI from a DEX (Uniswap v2)
        uniswapRouter.swapExactETHForTokens{ value: thirdOfETH }(swapAmount, getPathForETHtoDAI(), address(this), deadline);
        uniswapRouter.swapExactETHForTokens{ value: thirdOfETH }(swapAmount, getPathForETHtoUSDC(), address(this), deadline);
        uniswapRouter.swapExactETHForTokens{ value: thirdOfETH }(swapAmount, getPathForETHtoUSDT(), address(this), deadline);

        // refund leftover ETH to user
        (bool success,) = msg.sender.call{ value: address(this).balance }("");
        require(success, "refund failed");


       
    }

     
    function B_DepositIntoAAVE() public {
        //approve erc20 transfer
        IERC20(DAI).approve(address(aaveLendingPool),  IERC20(DAI).balanceOf(address(this)));
        IERC20(USDC).approve(address(aaveLendingPool), IERC20(USDC).balanceOf(address(this)));
        IERC20(USDT).approve(address(aaveLendingPool), IERC20(USDT).balanceOf(address(this)));
        //  deposit USDC, USDT, and DAI into AAVE
        aaveLendingPool.deposit(DAI, IERC20(DAI).balanceOf(address(this)), 0);
        aaveLendingPool.deposit(USDC, IERC20(USDC).balanceOf(address(this)), 0);
        aaveLendingPool.deposit(USDT, IERC20(USDT).balanceOf(address(this)), 0);
    }
    
    
    function C_DepositIntoCurve() public {
        require(msg.sender == owner,"must be owner");
    
        //  calculate amount of AAVE stablecoins in contract and store in array
        uint[3] memory aaveTokenAmount = [IERC20(maDAI).balanceOf(address(this)),IERC20(maUSDC).balanceOf(address(this)),IERC20(maUSDT).balanceOf(address(this))];


        //calculate minumum amount of LP tokens to mint (required by add liquidity function)
        uint curve_expected_LP_token_amount = ICurve_AAVE_Stable_Pool(curvePool).calc_token_amount(aaveTokenAmount,true);

        //approve
        IERC20(maDAI).approve(address(curvePool), type(uint256).max);
        IERC20(maUSDC).approve(address(curvePool), type(uint256).max);
        IERC20(maUSDT).approve(address(curvePool), type(uint256).max);

        // Deposit funds into Curve's Polygon AAVE Stablecoin Pool
        uint actual_LP_token_amount = ICurve_AAVE_Stable_Pool(curvePool).add_liquidity(aaveTokenAmount,curve_expected_LP_token_amount);
        //update public LP token amount minted
        totalLPTokensMinted = actual_LP_token_amount;


    }

    function D_WithdrawFromCurve() public {
      //  require(msg.sender == owner, "must be owner");
      //  uint LPTokens = IERC20(am3CRV).balanceOf(address(this));

       // uint curve_expected_LP_token_amount = ICurve_AAVE_Stable_Pool(curvePool).calc_token_amount(, false);
       // ICurve_AAVE_Stable_Pool(curvePool).remove_liquidity(uint256 _amount, )
    }

// ========================================= internal utility methods ✨


    function getPathForETHtoDAI() internal view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = uniswapRouter.WETH();
    path[1] = DAI;
    
    return path;
    }

    function getPathForETHtoUSDC() internal view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = uniswapRouter.WETH();
    path[1] = USDC;
    
    return path;
    }
    
    function getPathForETHtoUSDT() internal view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = uniswapRouter.WETH();
    path[1] = USDT;
    
    return path;
    }
    
    // receive function 
  receive() payable external {}

}


interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
}


interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint amount) external;
}

interface IAaveLendingPool {
    function deposit(address _reserve, uint256 _amount, uint16 _referralCode) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

}

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
}


interface ICurve_AAVE_Stable_Pool {
    function calc_token_amount(uint256[3] memory _amounts, bool _is_deposit) external returns (uint256);

    function add_liquidity(uint256[3] memory _amounts, uint256 _min_mint_amount) external returns (uint256);
}
