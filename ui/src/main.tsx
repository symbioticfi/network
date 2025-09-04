import React from 'react'
import './index.css'
import { createRoot } from 'react-dom/client'
import TimelockDashboard from './TimelockDashboard'
import { WagmiProviders } from './wagmiConfig'

createRoot(document.getElementById('root')!).render(
  <WagmiProviders>
    <TimelockDashboard />
  </WagmiProviders>
)
