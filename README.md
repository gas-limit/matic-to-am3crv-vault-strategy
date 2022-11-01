**eth-to-am3crv-vault-strategy**

I built this for some practice

 Strategy:
  1. Users deposit ETH 
  2. ETH is swapped for DAI, USDC, and USDT on on Uniswap V2
  3. DAI, USDC, USDT is lent on AAVE <br/>
    AAVE gives aDAI, aUSDC, and aUSDT tokens
  4. aDAI, aUSDC, and aUSDT is deposited into Curve AAVE Stablecoin pool <br/>
    Curve gives am3CRV tokens to contract

  How to Execute
  1. A_ETHToStablesUniswap() - swap from eth to USDC, USDT, and DAI from a DEX
  2. B_DepositIntoAAVE() - deposit USDC, USDT, and DAI into AAVE
  3. C_DepositIntoCurve() - deposit aUSDC, aUSDT, and aDAI into Curve's AAVE stablecoin pool
