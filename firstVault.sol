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
    //AggregatorV3Interface internal priceFeed = AggregatorV3Interface(0xAB594600376Ec9fD91F8e885dADF0CE036862dE0);

    //vault variables
    uint public totalLPTokensMinted;
    bool public isLocked;
    uint public step;

    //Stablecoin Instances
    //address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    //address constant DAI = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
    //address constant USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    //address constant USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;

    //AAVE Token Instances
    //address constant maDAI = 0x27F8D03b3a2196956ED754baDc28D73be8830A6e;
    //address constant maUSDC = 0x1a13F4Ca1d028320A707D99520AbFefca3998b7F;
    //address constant maUSDT = 0x60D55F02A771d515e077c9C2403a1ef324885CeC;

    //Curve AAVE pool LP token instance
    //address constant am3CRV = 0xE7a24EF0C5e95Ffb0f6684b813A78F2a3AD7D171;

    //Uniswapv2 Router Instance
    //IUniswapV2Router02 public uniswapRouter = IUniswapV2Router02(0x93bcDc45f7e62f89a8e901DC4A0E2c6C427D9F25);


    /// @notice Interface for Aave lendingPoolAddressesProviderRegistry

    
    //address constant RegistryAddress = 0x3ac4e9aa29940770aeC38fe853a4bbabb2dA9C19;
    //address constant LendingPoolAddress = 0x3ac4e9aa29940770aeC38fe853a4bbabb2dA9C19;

    //address constant ProviderAddress = 0xd05e3E715d945B59290df0ae8eF85c1BdB684744;
    //ILendingPool LendingPool = (ILendingPool(ILendingPoolAddressesProvider(ProviderAddress).getLendingPool()));
    
    //Curve Polygon AAVE Stablecoin Pool instance
    //ICurve_AAVE_Stable_Pool curvePool = ICurve_AAVE_Stable_Pool(0x445FE580eF8d70FF569aB36e80c647af338db351);

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

    function returnContractBalance() public view returns(uint) {
        return address(this).balance;
     }

  /*  function withdraw(uint _shares) external {
        require(!isLocked,"Contract Locked!");
        require(_shares <= balanceOf[msg.sender],"You dont have that many shares");
        uint amount = (_shares * address(this).balance) / totalSupply;
        _burn(msg.sender, _shares);

        //  ** send user something of amount **

    }
    */

// ========================================= Strategy Execution Methods ⚔️

    // How to Execute
    //1. A_ETHToStablesUniswap() - swap from eth to USDC, USDT, and DAI from a DEX
    //2. B_DepositIntoAAVE() - deposit USDC, USDT, and DAI into AAVE 
    //3. C_DepositIntoCurve() - deposit aUSDC, aUSDT, and aDAI into Curve's AAVE stablecoin pool 


    function A_ETHToStablesUniswap() public {
        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(0x93bcDc45f7e62f89a8e901DC4A0E2c6C427D9F25);
        //require(msg.sender == owner,"must be owner");
        //require(step == 0, "STEP_COMPLETED");

        //get amount of ETH to spend per stablecoin (1/3)
       // uint thirdOfETH = address(this).balance / 3;

        // using 'now' for convenience, for mainnet pass deadline from frontend!
        uint deadline = block.timestamp + 15; 

       // tokenAmount is the minimum amount of output tokens that must be received for the transaction not to revert.
        //can use oracle
        // calculate: pricefeed returns dollars per wei * 10 ^ 6
        // pricefeed * msg.value
      //  (,int price,,,) = priceFeed.latestRoundData();

        //uint maticPrice = uint(price) / 10 ** 4;


    /*  uint amountToSwapInWei = thirdOfETH * maticPrice;
        amountToSwapInWei = amountToSwapInWei / 10 ** 4;
        amountToSwapInWei -= 2 ether;*/



                                                        //put zero expected amount because it keeps failing if I put an estimate
        // swap all ETH to USDC, USDT, and DAI from a DEX (Uniswap v2)
        uniswapRouter.swapExactETHForTokens{ value: 100 ether }(0, getPathForETHtoDAI(), address(this), deadline);
        uniswapRouter.swapExactETHForTokens{ value: 100 ether }(0, getPathForETHtoUSDC(), address(this), deadline);
        uniswapRouter.swapExactETHForTokens{ value: 100 ether }(0, getPathForETHtoUSDT(), address(this), deadline);

        // refund leftover ETH to user
      //  (bool success,) = msg.sender.call{ value: address(this).balance }("");
      //  require(success, "refund failed");
       
    }

     
    function B_DepositIntoAAVE() public {
       // require(msg.sender == owner,"must be owner");
       // require(step == 1,"STEP_COMPLETED");
        address USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
        address DAI = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
        address USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
        address ProviderAddress = 0xd05e3E715d945B59290df0ae8eF85c1BdB684744;
        ILendingPool LendingPool = (ILendingPool(ILendingPoolAddressesProvider(ProviderAddress).getLendingPool()));
        uint16 REFERRAL_CODE = uint16(0);

        IERC20(DAI).approve(address(LendingPool),  IERC20(DAI).balanceOf(address(this)));
        IERC20(USDC).approve(address(LendingPool), IERC20(USDC).balanceOf(address(this)));
        IERC20(USDT).approve(address(LendingPool), IERC20(USDT).balanceOf(address(this)));
       // return address(_lendingPool());
        //  deposit USDC, USDT, and DAI into AAVE
       LendingPool.deposit(DAI, IERC20(DAI).balanceOf(address(this)) , address(this), REFERRAL_CODE);
       LendingPool.deposit(USDC, IERC20(USDC).balanceOf(address(this)) , address(this), REFERRAL_CODE);
       LendingPool.deposit(USDT, IERC20(USDT).balanceOf(address(this)) , address(this), REFERRAL_CODE);



        //step++;
    }
    
    
    function C_DepositIntoCurve() public {
     //   require(msg.sender == owner,"must be owner");
     //   require(step == 2, "STEP_COMPLETED");
    address maDAI = 0x27F8D03b3a2196956ED754baDc28D73be8830A6e;
    address maUSDC = 0x1a13F4Ca1d028320A707D99520AbFefca3998b7F;
    address maUSDT = 0x60D55F02A771d515e077c9C2403a1ef324885CeC;
    ICurve_AAVE_Stable_Pool curvePool = ICurve_AAVE_Stable_Pool(0x445FE580eF8d70FF569aB36e80c647af338db351);
        //  calculate amount of AAVE stablecoins in contract and store in array
        uint[3] memory aaveTokenAmount = [IERC20(maDAI).balanceOf(address(this)),IERC20(maUSDC).balanceOf(address(this)),IERC20(maUSDT).balanceOf(address(this))];


        //calculate minumum amount of LP tokens to mint (required by add liquidity function)
        //uint curve_expected_LP_token_amount = ICurve_AAVE_Stable_Pool(curvePool).calc_token_amount(aaveTokenAmount,true);

        //approve
        IERC20(maDAI).approve(address(curvePool), type(uint256).max);
        IERC20(maUSDC).approve(address(curvePool), type(uint256).max);
        IERC20(maUSDT).approve(address(curvePool), type(uint256).max);

        // Deposit funds into Curve's Polygon AAVE Stablecoin Pool
        uint actual_LP_token_amount = ICurve_AAVE_Stable_Pool(curvePool).add_liquidity(aaveTokenAmount,0);
        //update public LP token amount minted
        totalLPTokensMinted = actual_LP_token_amount;

        step++;
    }

    function D_WithdrawFromCurve() public {
      //  require(msg.sender == owner, "must be owner");
      //  uint LPTokens = IERC20(am3CRV).balanceOf(address(this));

       // uint curve_expected_LP_token_amount = ICurve_AAVE_Stable_Pool(curvePool).calc_token_amount(, false);
       // ICurve_AAVE_Stable_Pool(curvePool).remove_liquidity(uint256 _amount, )
    }

// ========================================= internal utility methods ✨


    function getPathForETHtoDAI() internal pure returns (address[] memory) {
    IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(0x93bcDc45f7e62f89a8e901DC4A0E2c6C427D9F25);
    address DAI = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
    address[] memory path = new address[](2);
    path[0] = uniswapRouter.WETH();
    path[1] = DAI;
    
    return path;
    }

    function getPathForETHtoUSDC() internal pure returns (address[] memory) {
    address USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(0x93bcDc45f7e62f89a8e901DC4A0E2c6C427D9F25);

    address[] memory path = new address[](2);
    
    path[0] = uniswapRouter.WETH();
    path[1] = USDC;
    
    return path;
    }
    
    function getPathForETHtoUSDT() internal pure returns (address[] memory) {
    address USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
    IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(0x93bcDc45f7e62f89a8e901DC4A0E2c6C427D9F25);
    address[] memory path = new address[](2);
    path[0] = uniswapRouter.WETH();
    path[1] = USDT;
    
    return path;
    }

    function getDaiBalance() public view returns (uint) {
        address DAI = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
        uint daibalance = IERC20(DAI).balanceOf(address(this));
        return daibalance;
    }

    function getUsdcBalance() public view returns (uint) {
        address USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
        uint daibalance = IERC20(USDC).balanceOf(address(this));
        return daibalance;
    }

    function getUsdtBalance() public view returns (uint) {
        address USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
        uint daibalance = IERC20(USDT).balanceOf(address(this));
        return daibalance;
    }
    

    function maDaiBalance() public view returns (uint) {
        address maDAI = 0x27F8D03b3a2196956ED754baDc28D73be8830A6e;
        uint daibalance = IERC20(maDAI).balanceOf(address(this));
        return daibalance;
    }

    function maUSDCBalance() public view returns (uint) {
        address maUSDC = 0x1a13F4Ca1d028320A707D99520AbFefca3998b7F;
        uint daibalance = IERC20(maUSDC).balanceOf(address(this));
        return daibalance;
    }

    function maUSDTBalance() public view returns (uint) {
        address maUSDT = 0x60D55F02A771d515e077c9C2403a1ef324885CeC;
        uint daibalance = IERC20(maUSDT).balanceOf(address(this));
        return daibalance;
    }

    function am3CRVTBalance() public view returns (uint) {
        address am3CRV = 0xE7a24EF0C5e95Ffb0f6684b813A78F2a3AD7D171;
        uint am3CRVamt = IERC20(am3CRV).balanceOf(address(this));
        return am3CRVamt;
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

interface ILendingPool {
    function deposit(address _asset, uint256 _amount, address _onBehalfOf, uint16 referralCode) external;
}

interface ILendingPoolAddressesProvider {
  event MarketIdSet(string newMarketId);
  event LendingPoolUpdated(address indexed newAddress);
  event ConfigurationAdminUpdated(address indexed newAddress);
  event EmergencyAdminUpdated(address indexed newAddress);
  event LendingPoolConfiguratorUpdated(address indexed newAddress);
  event LendingPoolCollateralManagerUpdated(address indexed newAddress);
  event PriceOracleUpdated(address indexed newAddress);
  event LendingRateOracleUpdated(address indexed newAddress);
  event ProxyCreated(bytes32 id, address indexed newAddress);
  event AddressSet(bytes32 id, address indexed newAddress, bool hasProxy);

  function getMarketId() external view returns (string memory);

  function setMarketId(string calldata marketId) external;

  function setAddress(bytes32 id, address newAddress) external;

  function setAddressAsProxy(bytes32 id, address impl) external;

  function getAddress(bytes32 id) external view returns (address);

  function getLendingPool() external view returns (address);

  function setLendingPoolImpl(address pool) external;

  function getLendingPoolConfigurator() external view returns (address);

  function setLendingPoolConfiguratorImpl(address configurator) external;

  function getLendingPoolCollateralManager() external view returns (address);

  function setLendingPoolCollateralManager(address manager) external;

  function getPoolAdmin() external view returns (address);

  function setPoolAdmin(address admin) external;

  function getEmergencyAdmin() external view returns (address);

  function setEmergencyAdmin(address admin) external;

  function getPriceOracle() external view returns (address);

  function setPriceOracle(address priceOracle) external;

  function getLendingRateOracle() external view returns (address);

  function setLendingRateOracle(address lendingRateOracle) external;
}

interface ILendingPoolAddressesProviderRegistry {
  event AddressesProviderRegistered(address indexed newAddress);
  event AddressesProviderUnregistered(address indexed newAddress);

  function getAddressesProvidersList() external view returns (address[] memory);

  function getAddressesProviderIdByAddress(address addressesProvider)
    external
    view
    returns (uint256);

  function registerAddressesProvider(address provider, uint256 id) external;

  function unregisterAddressesProvider(address provider) external;
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
