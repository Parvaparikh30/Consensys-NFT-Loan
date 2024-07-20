# NFT Loan Project

Welcome to the NFT Loan Project! This project consists of two main repositories:

1. **Frontend Application**
2. **Hardhat Smart Contracts**

## 1. Frontend Application

This repository contains the frontend code for Metamask wallet connection with wagmi integration to interact with Smart contract.

### Features

- **Next.js**: Framework for server-rendered React applications.
- **Tailwind CSS**: Utility-first CSS framework for styling.
- **Wagmi**: React Hook library to interact with Smart Contract
- **Metamask SDK**: To connect wallet with UI and integrated with wagmi
- **Opensea API**: TO fetch NFTs and its metadata owned by a user

### Environment Variables

- **INFURA_KEY**
- **NEXT_PUBLIC_OPENSEA_API**

### Get Started
 - Change directory to frontend folder
```bash
cd frontend
```
- Install all dependencies
```bash
    npm install
```
- Start the development server:
```bash
    npm run dev
```
<img width="1185" alt="Screenshot 2024-07-20 at 10 38 25 AM" src="https://github.com/user-attachments/assets/b9f0d7e7-9723-4422-b582-bc52a322ff30">
<img width="1436" alt="Screenshot 2024-07-19 at 10 51 02 PM" src="https://github.com/user-attachments/assets/264ec15a-9ab8-4659-a826-394e5907a79b">


## 2.  Hardhat Smart Contracts
This repo contains all the smart contract, deployment script, testing script, and config

### Features
- **Hardhat**: Ethereum development environment for compiling, testing, and deploying smart contracts.
- **Solidity**: Smart contract programming language.
- **Mocha/Chai**: Testing framework for writing and running tests.
- **Linea**: ETH Equivalence zkEVM layer 2 Rollup solution

### Smart Contract functionality 
- **Listing NFTs**: Users can list their NFTs as collateral for a loan.
- **Making Loan Offers**: Lenders can make loan offers on listed NFTs.
- **Accepting Loan Offers**: Borrowers can accept loan offers, transferring the NFT to an escrow contract.
- **Repaying Loans**: Borrowers can repay their loans, unlocking the NFT from escrow.
- **Liquidating NFTs**: Lenders can liquidate NFTs if the loan deadline has passed and the loan is not repaid.

### Environment Variables

- **INFURA_PROJECT_ID**
- **PRIVATE_KEY**

**NFT Loan Linea Sepolia Contract Details** - https://sepolia.lineascan.build/address/0x44732e05585e60478fa5d5ecabd080540d3adfc0

### Get Started
1. To Compile Smart Contract
```bash
npx hardhat compile
```
2. To Test smart contract
```bash
npx hardhat test
```
3. Deploy Smart contracts to local hardhat chain
```bash
npx hardhat run scripts/deploy.js --network localhost
```
4. Deploy Smart contracts to Linea Sepolia Testnet
```bash
npx hardhat run scripts/deploy.js --network lineaSepolia
```
5. Deploy Smart contracts to Linea Mainnet
```bash
npx hardhat run scripts/deploy.js --network linea
```


### Smart Contract Flow
<img width="839" alt="Screenshot 2024-07-20 at 4 18 09 PM" src="https://github.com/user-attachments/assets/ea71254b-36c5-4f2d-9efa-5fb00375a818">

### Hardhat Config
<img width="637" alt="Screenshot 2024-07-19 at 11 31 17 PM" src="https://github.com/user-attachments/assets/c297442f-f8e5-47e9-beca-721856f9f97c">


