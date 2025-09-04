import React from 'react'
import { WagmiProvider, createConfig, http as wagmiHttp } from 'wagmi'
import { injected } from 'wagmi/connectors'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { mainnet, sepolia, holesky, hoodi } from 'viem/chains'

const queryClient = new QueryClient()

export const wagmiConfig = createConfig({
  chains: [mainnet, holesky, sepolia, hoodi],
  connectors: [injected({ shimDisconnect: true })],
  transports: {
    [mainnet.id]: wagmiHttp(),
    [holesky.id]: wagmiHttp(),
    [sepolia.id]: wagmiHttp(),
    [hoodi.id]: wagmiHttp(),
  },
})

export function WagmiProviders({ children }: { children: React.ReactNode }) {
  return (
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    </WagmiProvider>
  )
}
