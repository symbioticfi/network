import type { ReactNode } from 'react'
import { WagmiProvider } from 'wagmi'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { mainnet, sepolia, holesky, hoodi } from '@reown/appkit/networks'
import { createAppKit } from '@reown/appkit/react'
import { WagmiAdapter } from '@reown/appkit-adapter-wagmi'

// 0. Setup queryClient
const queryClient = new QueryClient()

// 1. Get projectId from https://dashboard.reown.com
const projectId =
  (import.meta as any)?.env?.VITE_APPKIT_PROJECT_ID ||
  '43eff4b1fac476ffee43e467ab916f34'

// 2. Create a metadata object
const metadata = {
  name: 'Symbiotic Network Dashboard',
  description: 'Manage delays, roles, and timelock operations',
  url: 'https://symbiotic.fi',
  icons: ['https://symbiotic.fi/favicon.ico'],
}

const networks = [mainnet, sepolia, holesky, hoodi]

// 4. Create Wagmi Adapter
export const wagmiAdapter = new WagmiAdapter({
  networks: networks as any,
  projectId,
  ssr: true,
})

// 5. Create modal
createAppKit({
  adapters: [wagmiAdapter],
  networks: networks as any,
  projectId,
  metadata,
  features: {
    analytics: false,
  },
})

export function AppKitProvider({ children }: { children: ReactNode }) {
  return (
    <WagmiProvider config={wagmiAdapter.wagmiConfig}>
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    </WagmiProvider>
  )
}

export const WagmiProviders = AppKitProvider
