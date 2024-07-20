// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interface/IERC721.sol";
import "../interface/IERC20.sol";
import {EscrowContract} from "./EscrowContract.sol";

contract NFTLoanContract {
    struct LoanOffer {
        uint256 loanOfferId;
        uint256 nftLoanId;
        address lender;
        address nftTokenAddress;
        uint256 nftTokenId;
        uint256 loanTokenAmount;
        address loanTokenAddress;
        uint8 loanTokenDecimal;
        uint256 interest;
        uint256 deadline;
    }

    struct NFTLoan {
        uint256 nftLoanId;
        address borrower;
        address nftTokenAddress;
        uint256 nftTokenId;
        uint256 loanTokenAmount;
        address loanTokenAddress;
        uint8 loanTokenDecimal;
        uint256 deadline;
        address lender;
        bool isActive;
    }

    mapping(uint256 => mapping(uint256 => LoanOffer))
        public loanOffersForEachLoan;
    mapping(uint256 => NFTLoan) public loans;
    mapping(uint256 => uint256) public loanOfferIdCounter;
    uint256 public loanIdCounter;

    event NFTListed(
        uint256 loanId,
        address borrower,
        address nftTokenAddress,
        uint256 nftTokenId,
        uint256 loanAmount,
        uint256 interest,
        uint256 deadline
    );
    event LoanOfferMade(
        uint256 loanId,
        address lender,
        uint256 loanAmount,
        uint256 interest
    );
    event LoanOfferAccepted(
        uint256 loanId,
        address borrower,
        address lender,
        uint256 loanAmount,
        uint256 interest
    );
    event LoanRepaid(
        uint256 loanId,
        address borrower,
        address lender,
        uint256 repaymentAmount
    );
    event NFTLiquidated(
        uint256 loanId,
        address lender,
        address nftTokenAddress,
        uint256 nftTokenId
    );

    modifier onlyBorrower(uint256 loanId) {
        require(
            msg.sender == loans[loanId].borrower,
            "Only borrower can call this function"
        );
        _;
    }

    modifier onlyLender(uint256 loanId) {
        require(
            msg.sender == loans[loanId].lender,
            "Only lender can call this function"
        );
        _;
    }
    function listNFTCollateral(
        address nftTokenAddress,
        uint256 nftTokenId,
        uint256 loanAmount,
        uint256 deadline,
        address loanTokenAddress,
        uint8 loanTokenDecimal
    ) external {
        require(
            IERC721(nftTokenAddress).ownerOf(nftTokenId) == msg.sender,
            "User is not the owner of NFT listed"
        );
        require(deadline > block.timestamp, "Deadline must be in the future");

        loans[loanIdCounter] = NFTLoan({
            nftLoanId: loanIdCounter,
            borrower: msg.sender,
            nftTokenAddress: nftTokenAddress,
            nftTokenId: nftTokenId,
            loanTokenAmount: loanAmount,
            deadline: deadline,
            lender: address(0),
            isActive: true,
            loanTokenAddress: loanTokenAddress,
            loanTokenDecimal: loanTokenDecimal
        });

        emit NFTListed(
            loanIdCounter,
            msg.sender,
            nftTokenAddress,
            nftTokenId,
            loanAmount,
            interest,
            deadline
        );
        loanIdCounter++;
    }

    function makeLoanOffer(
        uint256 loanId,
        uint256 loanAmount,
        uint256 interest
    ) external {
        NFTLoan storage loan = loans[loanId];
        require(loan.isActive, "Loan is not active");
        require(loan.deadline >= block.timestamp, "Loan deadline passed");
        loanOffersForEachLoan[loanId][loanOfferIdCounter[loanId]] = LoanOffer({
            loanOfferId: loanOfferIdCounter[loanId],
            lender: msg.sender,
            loanTokenAmount: loanAmount,
            loanTokenAddress: loan.loanTokenAddress,
            loanTokenDecimal: loan.loanTokenDecimal,
            interest: interest,
            deadline: loan.deadline,
            nftLoanId: loanId,
            nftTokenAddress: loan.nftTokenAddress
        });

        emit LoanOfferMade(loanId, msg.sender, loanAmount, interest);

        loanOfferIdCounter[loanId]++;

        loan.lender = msg.sender;
        loan.loanTokenAmount = loanAmount;
        loan.interest = interest;

        emit LoanOfferMade(loanId, msg.sender, loanAmount, interest);
    }

    function acceptLoanOffer(
        uint256 loanId,
        uint256 loanOfferId
    ) external onlyBorrower(loanId) {
        NFTLoan storage loan = loans[loanId];
        LoanOffer storage loanOffer = loanOffersForEachLoan[loanId][
            loanOfferId
        ];

        require(loan.lender != address(0), "No lender for this loan");
        loan.lender = loanOffer.lender;
        IERC20 token = IERC20(loan.loanTokenAddress);
        token.transferFrom(loan.lender, loan.borrower, loan.loanTokenAmount);

        IERC721(loan.nftTokenAddress).transferFrom(
            address(this),
            address(
                new EscrowContract(
                    loanId,
                    loan.lender,
                    loan.borrower,
                    loan.nftTokenAddress,
                    loan.nftTokenId,
                    loan.loanTokenAmount,
                    loan.interest,
                    loan.deadline
                )
            ),
            loan.nftTokenId
        );

        emit LoanOfferAccepted(
            loanId,
            loan.borrower,
            loan.lender,
            loan.loanTokenAmount,
            loan.interest
        );
    }

    function repayLoan(
        uint256 loanId,
        address escrowContractAddress
    ) external onlyBorrower(loanId) {
        NFTLoan storage loan = loans[loanId];
        require(
            block.timestamp <= loan.deadline,
            "Loan deadline passed, cannot repay"
        );

        uint256 repaymentAmount = loan.loanTokenAmount + loan.interest;
        loan.isActive = false;
        IERC20 token = IERC20(loan.loanTokenAddress);
        token.transferFrom(msg.sender, loan.lender, repaymentAmount);
        EscrowContract escrow = EscrowContract(escrowContractAddress);
        escrow.unlockNFT();

        emit LoanRepaid(loanId, loan.borrower, loan.lender, repaymentAmount);
    }

    function liquidateNFT(
        uint256 loanId,
        address escrowContractAddress
    ) external onlyLender(loanId) {
        NFTLoan storage loan = loans[loanId];
        require(
            block.timestamp > loan.deadline,
            "Loan deadline has not passed"
        );

        EscrowContract escrow = EscrowContract(escrowContractAddress);
        escrow.liquidateNFT();

        emit NFTLiquidated(
            loanId,
            loan.lender,
            loan.nftTokenAddress,
            loan.nftTokenId
        );
    }
}
