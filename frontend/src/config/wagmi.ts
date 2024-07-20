import dotenv from "dotenv"
dotenv.config()
import { metaMask } from 'wagmi/connectors'
import { createConfig, http } from 'wagmi'
import { linea, lineaSepolia } from "wagmi/chains"

const INFURA_KEY = process.env.INFURA_KEY as string

const MetaMaskOptions = {
    dappMetadata: {
        name: "NFT Loan",
    },
    infuraAPIKey: INFURA_KEY,
}

export const config = createConfig({
    chains: [linea, lineaSepolia],
    connectors: [metaMask(MetaMaskOptions)],
    transports: {
        [linea.id]: http(),
        [lineaSepolia.id]: http(),
    },
})