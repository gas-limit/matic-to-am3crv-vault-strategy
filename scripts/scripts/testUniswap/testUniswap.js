
const { providers } = require("ethers");
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
const Vault = await ethers.getContractFactory("Vault");
const vault = await Vault.deploy();


await vault.deployed();

console.log("Vault fund deployed to:", vault.address, "\n");

await vault.deposit({value: ethers.utils.parseEther("900.0")});

const vaultBalance = await vault.returnContractBalance();
console.log("Vault ETH balance before swap: ",ethers.utils.formatEther(vaultBalance.toString()));

const daiBalance = await vault.getDaiBalance();
console.log("Vault DAI balance before swap: ",daiBalance.toString());

const usdcBalance = await vault.getUsdcBalance();
console.log("Vault USDC balance before swap: ",daiBalance.toString());

const usdtBalance = await vault.getUsdtBalance();
console.log("Vault USDT balance before swap: ",daiBalance.toString());

console.log("\n");

console.log("Swapping tokens on Uniswap V2..\n 100 ETH for DAI \n 100 ETH for USDC \n 100 ETH for USDT \n")
await vault.A_ETHToStablesUniswap();
console.log("Swap complete")

const vaultBalance2 = await vault.returnContractBalance();
console.log("Vault ETH balance after swap: ",ethers.utils.formatEther(vaultBalance2.toString()));

const daiBalance2 = await vault.getDaiBalance();
console.log("Vault DAI balance after swap: ",ethers.utils.formatEther(daiBalance2.toString()));

const usdcBalance2 = await vault.getUsdcBalance();
console.log("Vault USDC balance before swap: ",ethers.utils.formatEther(usdcBalance2.toString()));

const usdtBalance2 = await vault.getUsdtBalance();
console.log("Vault USDT balance before swap: ",ethers.utils.formatEther(usdtBalance2.toString()));


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  