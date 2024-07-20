import { useAccount, useConnect, useDisconnect } from 'wagmi'
import { metaMask } from 'wagmi/connectors'

const Navbar = () => {
    const { address, isConnected } = useAccount()
    const { connect } = useConnect()
    const { disconnect } = useDisconnect()
    return (
        <div>
            <nav className="bg-gray-800 p-4" >
                <div className="container mx-auto flex justify-between items-center" >
                    <h1 className="text-white text-2xl" > NFT Loan </h1>
                    {
                        isConnected ? (
                            <div className="flex items-center space-x-4" >
                                <span className="text-white" > {address} </span>
                                < button
                                    className="bg-red-500 text-white px-4 py-2 rounded"
                                    onClick={() => disconnect()
                                    }
                                >
                                    Disconnect
                                </button>
                            </div>
                        ) : (
                            <button
                                className="bg-blue-500 text-white px-4 py-2 rounded"
                                onClick={() => connect({ connector: metaMask() })}
                            >
                                Connect Wallet
                            </button>
                        )}
                </div>
            </nav>
        </div>
    )
}

export default Navbar
