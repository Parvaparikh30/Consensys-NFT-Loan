// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interface/IERC721.sol";

contract EscrowContract {
    uint256 public loanId;
    address public lender;
    address public borrower;
    address public nftContract;
    uint256 public nftTokenId;
    uint256 public loanAmount;
    uint256 public interest;
    uint256 public deadline;
    bool public isLocked;

    event NFTUnlocked(
        uint256 loanId,
        address borrower,
        address nftContract,
        uint256 nftTokenId
    );
    event NFTLiquidated(
        uint256 loanId,
        address lender,
        address nftContract,
        uint256 nftTokenId
    );

    modifier onlyLender() {
        require(msg.sender == lender, "Only lender can call this function");
        _;
    }

    modifier onlyAfterDeadline() {
        require(block.timestamp > deadline, "Loan deadline has not passed");
        _;
    }

    modifier isLockedState() {
        require(isLocked, "NFT is already unlocked");
        _;
    }

    constructor(
        uint256 _loanId,
        address _lender,
        address _borrower,
        address _nftContract,
        uint256 _nftTokenId,
        uint256 _loanAmount,
        uint256 _interest,
        uint256 _deadline
    ) {
        loanId = _loanId;
        lender = _lender;
        borrower = _borrower;
        nftContract = _nftContract;
        nftTokenId = _nftTokenId;
        loanAmount = _loanAmount;
        interest = _interest;
        deadline = _deadline;
        isLocked = true;
    }

    function unlockNFT() external onlyLender isLockedState {
        isLocked = false;
        IERC721(nftContract).transferFrom(address(this), borrower, nftTokenId);
        emit NFTUnlocked(loanId, borrower, nftContract, nftTokenId);
    }

    function liquidateNFT()
        external
        onlyLender
        onlyAfterDeadline
        isLockedState
    {
        isLocked = false;
        IERC721(nftContract).transferFrom(address(this), lender, nftTokenId);
        emit NFTLiquidated(loanId, lender, nftContract, nftTokenId);
    }
}
