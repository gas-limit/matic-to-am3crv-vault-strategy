
const { providers } = require("ethers");
const hre = require("hardhat");

async function main() {
const Vault = await ethers.getContractFactory("Vault");
const vault = await Vault.deploy();

await vault.deployed();

console.log("Index fund deployed to:", vault.address);

await vault.deposit({value: ethers.utils.parseEther("2.0")});

const vaultBalance = await vault.returnContractBalance();

console.log(ethers.utils.formatEther(vaultBalance.toString()))

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  