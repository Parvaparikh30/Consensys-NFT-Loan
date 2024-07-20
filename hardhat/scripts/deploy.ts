import { ethers } from "hardhat";

async function main() {
    // We get the contract to deploy
    const NFTLoanContract = await ethers.getContractFactory("NFTLoanContract");
    const nftLoanContract = await NFTLoanContract.deploy();

    await nftLoanContract.deployed();

    console.log("NFTLoanContract deployed to:", nftLoanContract.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
