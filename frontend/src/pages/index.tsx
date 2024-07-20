import { Inter } from "next/font/google";
import React, { useEffect, useState } from "react";
import Navbar from "@/components/Navbar";
import NFTDisplayGrid from "@/components/NFTDisplayGrid";

export default function Home() {
  const [isClient, setIsClient] = useState(false);

  useEffect(() => {
    setIsClient(true);
  }, []);
  return (
    <div>
      <Navbar />
      <main className="container min-h-screen mx-auto p-4">
        {isClient && (
          <h1 className="text-2xl font-bold mb-6">Select your NFT for Collateral</h1>
        )}
        <NFTDisplayGrid />
      </main>
      <footer className="bg-gray-800 text-white text-center p-4" />


    </div>
  );
}
