**eth-to-am3crv-vault-strategy**

I built this for some practice 🔒

 **Strategy:**
  1. Users deposit ETH 
  2. ETH is swapped for DAI, USDC, and USDT on Uniswap V2
  3. DAI, USDC, USDT is lent on AAVE *+ ~ 1.5% APY* <br/> 
    AAVE gives aDAI, aUSDC, and aUSDT tokens 
  4. aDAI, aUSDC, and aUSDT is deposited into Curve AAVE Stablecoin pool *1.14% APY + 0.13% CRV APY* <br/> 
    Curve gives am3CRV tokens to contract

  **How to Execute**
  1. A_ETHToStablesUniswap() - swap from eth to USDC, USDT, and DAI from a DEX
  2. B_DepositIntoAAVE() - deposit USDC, USDT, and DAI into AAVE
  3. C_DepositIntoCurve() - deposit aUSDC, aUSDT, and aDAI into Curve's AAVE stablecoin pool
