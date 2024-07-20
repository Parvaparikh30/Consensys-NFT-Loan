// components/CardGrid.js
import Image from 'next/image';
import { useEffect, useState } from 'react';
import { useAccount } from 'wagmi';

const OPENSEA_API = process.env.NEXT_PUBLIC_OPENSEA_API as string
type OpenseaResponse = {
    name: string,
    description: string,
    display_image_url: string,
    title: string
}

const NFTDisplayGrid = () => {
    const [nftDetails, setNftDetails] = useState([]);
    const accountConnected = useAccount()

    useEffect(() => {
        if (!accountConnected.address) return
        (async () => {
            const options = {
                method: 'GET',
                headers: { accept: 'application/json', 'x-api-key': OPENSEA_API }
            };
            fetch(`https://api.opensea.io/api/v2/chain/ethereum/account/${accountConnected.address}/nfts`, options)
                .then(response => response.json())
                .then(data => {
                    console.log(data);
                    setNftDetails(data.nfts)
                })
                .catch(err => console.error(err));
        })
            ()

    }, [accountConnected.address])

    return (
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
            {nftDetails && nftDetails.map((nft: OpenseaResponse, index: number) => (
                <div key={index} className="bg-white rounded-lg shadow-lg overflow-hidden">
                    <Image
                        src={nft.display_image_url}
                        alt={nft.title}
                        width={150}
                        height={150}
                        className="w-full h-48 object-cover"
                    />
                    <div className="p-4">
                        <h2 className="text-lg font-semibold">{nft.name}</h2>
                        <p className="text-gray-600">{nft.description}</p>
                    </div>
                </div>
            ))}
        </div>
    );
}

export default NFTDisplayGrid;
