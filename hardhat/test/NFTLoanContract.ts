import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract } from "ethers";

describe("NFTLoanContract", function () {
    let nftLoanContract: Contract;
    let nftContract: Contract;
    let loanTokenContract: Contract;
    let owner: any, borrower: any, lender: any;

    beforeEach(async function () {
        // Get signers
        [owner, borrower, lender] = await ethers.getSigners();

        // Deploy ERC20 loan token
        const LoanToken = await ethers.getContractFactory("ERC20Mock");
        loanTokenContract = await LoanToken.deploy("WETH", "WETH", 18);
        await loanTokenContract.deployed();

        // Deploy ERC721 NFT contract
        const NFT = await ethers.getContractFactory("NFTMock");
        nftContract = await NFT.deploy("Bored Ape", "BAYC");
        await nftContract.deployed();

        // Deploy NFTLoanContract
        const NFTLoan = await ethers.getContractFactory("NFTLoanContract");
        nftLoanContract = await NFTLoan.deploy();
        await nftLoanContract.deployed();

        // Mint an NFT to the borrower
        await nftContract.mint(borrower.address, 1);

        // Transfer some loan tokens to the lender
        await loanTokenContract.transfer(lender.address, ethers.utils.parseUnits("1000", 18));
    });

    it("should list NFT as collateral with deadline as 5 min", async function () {
        await nftContract.connect(borrower).approve(nftLoanContract.address, 1);
        await expect(
            nftLoanContract.connect(borrower).listNFTCollateral(
                nftContract.address,
                1,
                ethers.utils.parseUnits("100", 18),
                500,
                Math.floor(Date.now() / 1000) + 300,
                loanTokenContract.address,
                18
            )
        ).to.emit(nftLoanContract, "NFTListed")
            .withArgs(
                0,
                borrower.address,
                nftContract.address,
                1,
                ethers.utils.parseUnits("100", 18),
                500,
                Math.floor(Date.now() / 1000) + 3600
            );
    });

    it("should accept a loan offer", async function () {
        // List NFT collateral
        await nftContract.connect(borrower).approve(nftLoanContract.address, 1);
        await nftLoanContract.connect(borrower).listNFTCollateral(
            nftContract.address,
            1,
            ethers.utils.parseUnits("100", 18),
            500,
            Math.floor(Date.now() / 1000) + 3600,
            loanTokenContract.address,
            18
        );

        // Make a loan offer
        await loanTokenContract.connect(lender).approve(nftLoanContract.address, ethers.utils.parseUnits("100", 18));
        await nftLoanContract.connect(lender).makeLoanOffer(0, ethers.utils.parseUnits("100", 18), 500);

        // Accept the loan offer
        await expect(
            nftLoanContract.connect(borrower).acceptLoanOffer(0, 0)
        ).to.emit(nftLoanContract, "LoanOfferAccepted")
            .withArgs(
                0,
                borrower.address,
                lender.address,
                ethers.utils.parseUnits("100", 18),
                500
            );
    });

    it("should repay the loan", async function () {
        // List NFT collateral and make a loan offer
        await nftContract.connect(borrower).approve(nftLoanContract.address, 1);
        await nftLoanContract.connect(borrower).listNFTCollateral(
            nftContract.address,
            1,
            ethers.utils.parseUnits("100", 18),
            500,
            Math.floor(Date.now() / 1000) + 3600,
            loanTokenContract.address,
            18
        );
        await loanTokenContract.connect(lender).approve(nftLoanContract.address, ethers.utils.parseUnits("100", 18));
        await nftLoanContract.connect(lender).makeLoanOffer(0, ethers.utils.parseUnits("100", 18), 500);

        // Accept the loan offer
        await nftLoanContract.connect(borrower).acceptLoanOffer(0, 0);

        // Repay the loan
        await loanTokenContract.connect(borrower).approve(nftLoanContract.address, ethers.utils.parseUnits("105", 18)); // 100 + 5 interest
        await expect(
            nftLoanContract.connect(borrower).repayLoan(0)
        ).to.emit(nftLoanContract, "LoanRepaid")
            .withArgs(
                0,
                borrower.address,
                lender.address,
                ethers.utils.parseUnits("105", 18)
            );
    });
});
