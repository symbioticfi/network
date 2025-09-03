import React, { useEffect, useMemo, useState } from 'react'
import { createPublicClient, createWalletClient, custom, decodeEventLog, encodeFunctionData, formatEther, getAddress, Hex, http, parseEther, parseAbiItem } from 'viem'
import type { Abi, AbiFunction, PublicClient, WalletClient } from 'viem'
import { networkAbi, OperationState } from './abi'

type ScheduledTx = {
  target: `0x${string}`
  value: bigint
  data: Hex
  index: bigint
}

type OperationEntry = {
  id: Hex
  predecessor: Hex
  salt: Hex
  delay: bigint
  txs: ScheduledTx[]
  timestamp: bigint
  state: OperationState
}

const zero32: Hex = '0x0000000000000000000000000000000000000000000000000000000000000000'

export default function TimelockDashboard() {
  const [rpcUrl, setRpcUrl] = useState<string>('')
  const [contractAddress, setContractAddress] = useState<string>('')
  const [fromBlock, setFromBlock] = useState<string>('0')
  const [account, setAccount] = useState<`0x${string}` | null>(null)
  const [chainId, setChainId] = useState<number | null>(null)

  const [publicClient, setPublicClient] = useState<PublicClient | null>(null)
  const [walletClient, setWalletClient] = useState<WalletClient | null>(null)

  const [contractName, setContractName] = useState<string>('')
  const [metadataURI, setMetadataURI] = useState<string>('')
  const [globalMinDelay, setGlobalMinDelay] = useState<bigint | null>(null)

  const [delayEntries, setDelayEntries] = useState<{
    key: string
    target: `0x${string}`
    selector: string
    enabled: boolean
    delay: bigint
  }[]>([])

  const [ops, setOps] = useState<OperationEntry[]>([])
  const [loadingDelays, setLoadingDelays] = useState(false)
  const [loadingOps, setLoadingOps] = useState(false)
  const [scheduling, setScheduling] = useState(false)
  const [executing, setExecuting] = useState<string>('') // id being executed

  // Single schedule form state
  const [singleTarget, setSingleTarget] = useState<string>('')
  const [singleValueEth, setSingleValueEth] = useState<string>('0')
  const [singleData, setSingleData] = useState<string>('0x')
  const [singlePredecessor, setSinglePredecessor] = useState<string>(zero32)
  const [singleSalt, setSingleSalt] = useState<string>(zero32)
  const [singleDelay, setSingleDelay] = useState<string>('0')
  const [singleMinDelay, setSingleMinDelay] = useState<bigint | null>(null)

  // Calldata builder state
  const [builderOpen, setBuilderOpen] = useState<boolean>(false)
  const [builderMode, setBuilderMode] = useState<'raw' | 'abi' | 'sig'>('raw')
  const [builderAbiText, setBuilderAbiText] = useState<string>('')
  const [builderFnName, setBuilderFnName] = useState<string>('')
  const [builderArgsText, setBuilderArgsText] = useState<string>('[]')
  const [builderError, setBuilderError] = useState<string>('')

  // Batch schedule form state
  const [batchRows, setBatchRows] = useState<Array<{ target: string; valueEth: string; data: string }>>([
    { target: '', valueEth: '0', data: '0x' },
  ])
  const [batchPredecessor, setBatchPredecessor] = useState<string>(zero32)
  const [batchSalt, setBatchSalt] = useState<string>(zero32)
  const [batchDelay, setBatchDelay] = useState<string>('0')

  const canInteract = useMemo(() => {
    return publicClient && walletClient && account && contractAddress
  }, [publicClient, walletClient, account, contractAddress])

  // Setup clients whenever rpcUrl or provider changes
  useEffect(() => {
    const setup = async () => {
      try {
        if ((window as any).ethereum) {
          const provider = (window as any).ethereum
          const pub = createPublicClient({ transport: custom(provider) })
          const wal = createWalletClient({ transport: custom(provider) })
          setPublicClient(pub)
          setWalletClient(wal)

          const [cidHex, accounts] = await Promise.all([
            provider.request({ method: 'eth_chainId' }) as Promise<string>,
            provider.request({ method: 'eth_accounts' }) as Promise<string[]>,
          ])
          setChainId(parseInt(cidHex, 16))
          setAccount(accounts[0] ? (getAddress(accounts[0]) as `0x${string}`) : null)

          provider.on?.('accountsChanged', (accs: string[]) => {
            setAccount(accs[0] ? (getAddress(accs[0]) as `0x${string}`) : null)
          })
          provider.on?.('chainChanged', (cid: string) => setChainId(parseInt(cid, 16)))
        } else if (rpcUrl) {
          const pub = createPublicClient({ transport: http(rpcUrl) })
          setPublicClient(pub)
          setWalletClient(null)
        }
      } catch (e) {
        console.error('Client setup error', e)
      }
    }
    setup()
  }, [rpcUrl])

  const connect = async () => {
    if (!(window as any).ethereum) return
    const provider = (window as any).ethereum
    const wal = createWalletClient({ transport: custom(provider) })
    const pub = createPublicClient({ transport: custom(provider) })
    const accs: string[] = await provider.request({ method: 'eth_requestAccounts' })
    setWalletClient(wal)
    setPublicClient(pub)
    setAccount(accs[0] ? (getAddress(accs[0]) as `0x${string}`) : null)
    const cidHex: string = await provider.request({ method: 'eth_chainId' })
    setChainId(parseInt(cidHex, 16))
  }

  const disconnect = () => {
    // Clear local connection state; wallets typically require manual disconnect in their UI
    setAccount(null)
    setWalletClient(null)
    setScheduling(false)
    setExecuting('')
  }

  const readHeader = async () => {
    if (!publicClient || !contractAddress) return
    try {
      const [nm, meta, global] = await Promise.all([
        publicClient.readContract({ address: contractAddress as `0x${string}`, abi: networkAbi, functionName: 'name' }).catch(() => ''),
        publicClient
          .readContract({ address: contractAddress as `0x${string}`, abi: networkAbi, functionName: 'metadataURI' })
          .catch(() => ''),
        publicClient.readContract({ address: contractAddress as `0x${string}`, abi: networkAbi, functionName: 'getMinDelay', args: [] }).catch(() => null),
      ])
      setContractName(nm as string)
      setMetadataURI(meta as string)
      setGlobalMinDelay(global as bigint | null)
    } catch (e) {
      console.error(e)
    }
  }

  useEffect(() => {
    readHeader()
  }, [publicClient, contractAddress])

  const loadDelays = async () => {
    if (!publicClient || !contractAddress) return
    setLoadingDelays(true)
    try {
      const from = BigInt(fromBlock || '0')
      const to = 'latest'
      const logs = await publicClient.getLogs({
        address: contractAddress as `0x${string}`,
        fromBlock: from,
        toBlock: to,
        // Ambiguous name in ABI; viem can still decode with topic filtering via signature
        // We'll filter by the custom event signature topic directly
        // topic0: keccak256("MinDelayChange(address,bytes4,bool,uint256,bool,uint256)")
        // 0x1b9b6442d6f3efc773e47bf09593f9f17a5a8a4a9a5fdfcbcc9c8e0b69aaf5a6 (compute below?)
      })

      // Decode only the custom MinDelayChange by trying both event defs and accepting the address+bytes4 one
      const map = new Map<string, { target: `0x${string}`; selector: string; enabled: boolean; delay: bigint }>()
      for (const log of logs) {
        try {
          const decoded = decodeEventLog({ abi: networkAbi, data: log.data, topics: log.topics })
          if (decoded.eventName === 'MinDelayChange') {
            // Two possible overloads; we need the one with address + bytes4 indexed
            const args: any = decoded.args
            if (
              args &&
              typeof args.target === 'string' &&
              typeof args.selector === 'string' &&
              (typeof args.newEnabledStatus === 'boolean' || typeof args.oldEnabledStatus === 'boolean')
            ) {
              const key = `${getAddress(args.target)}-${args.selector}`
              map.set(key, {
                target: getAddress(args.target) as `0x${string}`,
                selector: args.selector,
                enabled: Boolean(args.newEnabledStatus),
                delay: BigInt(args.newDelay ?? 0n),
              })
            }
          }
        } catch {}
      }

      const arr = Array.from(map.entries()).map(([key, v]) => ({ key, ...v }))
      // Sort: enabled first, then by target, then selector
      arr.sort((a, b) => (a.enabled === b.enabled ? 0 : a.enabled ? -1 : 1) || a.target.localeCompare(b.target) || a.selector.localeCompare(b.selector))
      setDelayEntries(arr)
    } catch (e) {
      console.error(e)
    } finally {
      setLoadingDelays(false)
    }
  }

  const loadOperations = async () => {
    if (!publicClient || !contractAddress) return
    setLoadingOps(true)
    try {
      const from = BigInt(fromBlock || '0')
      const to = 'latest'

      // Fetch CallScheduled logs
      const scheduled = await publicClient.getLogs({
        address: contractAddress as `0x${string}`,
        fromBlock: from,
        toBlock: to,
        event: {
          type: 'event',
          name: 'CallScheduled',
          inputs: [
            { name: 'id', type: 'bytes32', indexed: true },
            { name: 'index', type: 'uint256', indexed: true },
            { name: 'target', type: 'address', indexed: false },
            { name: 'value', type: 'uint256', indexed: false },
            { name: 'data', type: 'bytes', indexed: false },
            { name: 'predecessor', type: 'bytes32', indexed: false },
            { name: 'delay', type: 'uint256', indexed: false },
          ],
          anonymous: false,
        } as const,
      })

      // Fetch CallSalt logs
      const salts = await publicClient.getLogs({
        address: contractAddress as `0x${string}`,
        fromBlock: from,
        toBlock: to,
        event: {
          type: 'event',
          name: 'CallSalt',
          inputs: [
            { name: 'id', type: 'bytes32', indexed: true },
            { name: 'salt', type: 'bytes32', indexed: false },
          ],
          anonymous: false,
        } as const,
      })

      const saltById = new Map<string, Hex>()
      for (const s of salts) {
        // @ts-ignore viem narrows via event
        saltById.set(s.args.id as string, s.args.salt as Hex)
      }

      // Group scheduled by id
      const byId = new Map<string, OperationEntry>()
      for (const ev of scheduled) {
        // @ts-ignore event typing from viem
        const id: Hex = ev.args.id
        // @ts-ignore
        const index: bigint = ev.args.index
        // @ts-ignore
        const target: `0x${string}` = getAddress(ev.args.target)
        // @ts-ignore
        const value: bigint = ev.args.value
        // @ts-ignore
        const data: Hex = ev.args.data
        // @ts-ignore
        const predecessor: Hex = ev.args.predecessor
        // @ts-ignore
        const delay: bigint = ev.args.delay

        const existing = byId.get(id)
        if (!existing) {
          byId.set(id, {
            id,
            predecessor,
            salt: saltById.get(id) ?? zero32,
            delay,
            txs: [{ index, target, value, data }],
            timestamp: 0n,
            state: OperationState.Unset,
          })
        } else {
          existing.txs.push({ index, target, value, data })
        }
      }

      // Sort txs by index and fill status/timestamp from contract
      const entries = Array.from(byId.values())
      for (const entry of entries) {
        entry.txs.sort((a, b) => (a.index < b.index ? -1 : a.index > b.index ? 1 : 0))
        try {
          const [ts, st] = await Promise.all([
            publicClient.readContract({ address: contractAddress as `0x${string}`, abi: networkAbi, functionName: 'getTimestamp', args: [entry.id] }) as Promise<bigint>,
            publicClient.readContract({ address: contractAddress as `0x${string}`, abi: networkAbi, functionName: 'getOperationState', args: [entry.id] }) as Promise<number>,
          ])
          entry.timestamp = ts
          entry.state = st as OperationState
        } catch (e) {
          // ignore
        }
      }

      // Sort entries: Ready first, then Waiting by timestamp, then Done
      entries.sort((a, b) => {
        const prio = (x: OperationEntry) => (x.state === OperationState.Ready ? 0 : x.state === OperationState.Waiting ? 1 : x.state === OperationState.Done ? 2 : 3)
        return prio(a) - prio(b) || Number(a.timestamp - b.timestamp)
      })

      setOps(entries)
    } catch (e) {
      console.error(e)
    } finally {
      setLoadingOps(false)
    }
  }

  const computeSingleMinDelay = async () => {
    if (!publicClient || !contractAddress) return
    try {
      const min = await publicClient.readContract({
        address: contractAddress as `0x${string}`,
        abi: networkAbi,
        functionName: 'getMinDelay',
        args: [singleTarget as `0x${string}`, singleData as Hex],
      })
      setSingleMinDelay(min as bigint)
      if ((singleDelay || '0') === '0') setSingleDelay(String(min))
    } catch (e) {
      console.error(e)
    }
  }

  useEffect(() => {
    // debounce minimal
    const t = setTimeout(() => {
      if (singleTarget && singleData) computeSingleMinDelay()
    }, 400)
    return () => clearTimeout(t)
  }, [singleTarget, singleData, contractAddress, publicClient])

  const onScheduleSingle = async () => {
    if (!walletClient || !publicClient || !account || !contractAddress) return
    setScheduling(true)
    try {
      const value = parseEther(singleValueEth || '0')
      const hash = await walletClient.writeContract({
        address: contractAddress as `0x${string}`,
        abi: networkAbi,
        functionName: 'schedule',
        args: [
          getAddress(singleTarget) as `0x${string}`,
          value,
          (singleData || '0x') as Hex,
          (singlePredecessor || zero32) as Hex,
          (singleSalt || zero32) as Hex,
          BigInt(singleDelay || '0'),
        ],
        account,
        chain: undefined,
      })
      console.log('schedule tx', hash)
      await publicClient.waitForTransactionReceipt({ hash })
      await loadOperations()
    } catch (e) {
      console.error(e)
    } finally {
      setScheduling(false)
    }
  }

  const onScheduleBatch = async () => {
    if (!walletClient || !publicClient || !account || !contractAddress) return
    setScheduling(true)
    try {
      const targets = batchRows.map((r) => getAddress(r.target) as `0x${string}`)
      const values = batchRows.map((r) => parseEther(r.valueEth || '0'))
      const payloads = batchRows.map((r) => (r.data || '0x') as Hex)
      const hash = await walletClient.writeContract({
        address: contractAddress as `0x${string}`,
        abi: networkAbi,
        functionName: 'scheduleBatch',
        args: [targets, values, payloads, (batchPredecessor || zero32) as Hex, (batchSalt || zero32) as Hex, BigInt(batchDelay || '0')],
        account,
        chain: undefined,
      })
      console.log('scheduleBatch tx', hash)
      await publicClient.waitForTransactionReceipt({ hash })
      await loadOperations()
    } catch (e) {
      console.error(e)
    } finally {
      setScheduling(false)
    }
  }

  const onExecute = async (entry: OperationEntry) => {
    if (!walletClient || !publicClient || !account || !contractAddress) return
    setExecuting(entry.id)
    try {
      if (entry.txs.length === 1) {
        const tx = entry.txs[0]
        const hash = await walletClient.writeContract({
          address: contractAddress as `0x${string}`,
          abi: networkAbi,
          functionName: 'execute',
          args: [tx.target, tx.value, tx.data, entry.predecessor, entry.salt],
          account,
          chain: undefined,
        })
        await publicClient.waitForTransactionReceipt({ hash })
      } else {
        const targets = entry.txs.map((t) => t.target)
        const values = entry.txs.map((t) => t.value)
        const payloads = entry.txs.map((t) => t.data)
        const hash = await walletClient.writeContract({
          address: contractAddress as `0x${string}`,
          abi: networkAbi,
          functionName: 'executeBatch',
          args: [targets, values, payloads, entry.predecessor, entry.salt],
          account,
          chain: undefined,
        })
        await publicClient.waitForTransactionReceipt({ hash })
      }
      await loadOperations()
    } catch (e) {
      console.error(e)
    } finally {
      setExecuting('')
    }
  }

  const selectorFromData = (data: string) => {
    try {
      const d = (data || '').toLowerCase()
      if (!d || d === '0x') return '0xeeeeeeee'
      return (d.startsWith('0x') ? d.slice(0, 10) : '0x' + d.slice(0, 8))
    } catch {
      return '0x'
    }
  }

  const buildCalldataFromAbi = () => {
    setBuilderError('')
    try {
      const abi = JSON.parse(builderAbiText || '[]') as Abi
      const fns = (abi as any[]).filter((i) => i && i.type === 'function') as AbiFunction[]
      const found = fns.find((f) => f.name === builderFnName)
      if (!found) {
        setBuilderError('Function not found in ABI')
        return
      }
      const args = JSON.parse(builderArgsText || '[]')
      const data = encodeFunctionData({ abi: abi as Abi, functionName: builderFnName as any, args }) as Hex
      setSingleData(data)
    } catch (e: any) {
      setBuilderError(e?.message || String(e))
    }
  }

  const buildCalldataFromSignature = () => {
    setBuilderError('')
    try {
      // Example: "transfer(address,uint256)"
      const item = parseAbiItem('function ' + builderFnName) as AbiFunction
      const args = JSON.parse(builderArgsText || '[]')
      const data = encodeFunctionData({ abi: [item] as unknown as Abi, functionName: (item as any).name, args }) as Hex
      setSingleData(data)
    } catch (e: any) {
      setBuilderError(e?.message || String(e))
    }
  }

  return (
    <div className="min-h-screen bg-gray-50 text-gray-900">
      <div className="max-w-6xl mx-auto p-4 space-y-6">
        <header className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-semibold">Timelock Dashboard</h1>
            <p className="text-sm text-gray-500">View delays, schedule actions, execute when ready</p>
          </div>
          <div className="flex items-center gap-2">
            {!account ? (
              <button onClick={connect} className="px-3 py-1.5 rounded bg-indigo-600 text-white text-sm">Connect Wallet</button>
            ) : (
              <>
                <span className="text-sm text-gray-600">{account.slice(0, 6)}…{account.slice(-4)}{chainId ? ` · Chain ${chainId}` : ''}</span>
                <button onClick={disconnect} className="px-3 py-1.5 rounded bg-gray-100 border text-sm">Disconnect</button>
              </>
            )}
          </div>
        </header>

        <section className="bg-white rounded border p-4 space-y-3">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
            <div>
              <label className="block text-xs text-gray-600 mb-1">RPC URL (optional)</label>
              <input className="w-full border rounded px-2 py-1" placeholder="http(s)://..." value={rpcUrl} onChange={(e) => setRpcUrl(e.target.value)} />
              <p className="text-xs text-gray-500 mt-1">If empty, uses injected wallet provider.</p>
            </div>
            <div>
              <label className="block text-xs text-gray-600 mb-1">Contract Address</label>
              <input className="w-full border rounded px-2 py-1" placeholder="0x..." value={contractAddress} onChange={(e) => setContractAddress(e.target.value)} />
              <div className="text-xs text-gray-500 mt-1">Timelock-enabled Network contract</div>
            </div>
            <div>
              <label className="block text-xs text-gray-600 mb-1">From Block (logs)</label>
              <input className="w-full border rounded px-2 py-1" placeholder="0" value={fromBlock} onChange={(e) => setFromBlock(e.target.value)} />
              <div className="text-xs text-gray-500 mt-1">Use a recent block to limit queries</div>
            </div>
          </div>

          <div className="flex items-center gap-3 text-sm">
            <button onClick={readHeader} className="px-3 py-1.5 rounded bg-gray-100 border">Refresh Header</button>
            <div className="text-gray-700">Name: <span className="font-medium">{contractName || '—'}</span></div>
            <div className="text-gray-700">Metadata: <span className="font-mono">{metadataURI || '—'}</span></div>
            <div className="text-gray-700">Global Min Delay: <span className="font-mono">{globalMinDelay !== null ? `${globalMinDelay} s` : '—'}</span></div>
          </div>
        </section>

        <section className="bg-white rounded border p-4 space-y-3">
          <div className="flex items-center justify-between">
            <h2 className="font-semibold">Delays Setup</h2>
            <button onClick={loadDelays} disabled={loadingDelays || !contractAddress || !publicClient} className="px-3 py-1.5 rounded bg-indigo-600 text-white text-sm disabled:opacity-60">{loadingDelays ? 'Loading…' : 'Load Delays'}</button>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full text-sm">
              <thead>
                <tr className="text-left text-gray-500">
                  <th className="py-2 pr-4">Target</th>
                  <th className="py-2 pr-4">Selector</th>
                  <th className="py-2 pr-4">Enabled</th>
                  <th className="py-2 pr-4">Min Delay (s)</th>
                </tr>
              </thead>
              <tbody>
                {delayEntries.length === 0 ? (
                  <tr><td className="py-3 text-gray-400" colSpan={4}>No entries loaded</td></tr>
                ) : (
                  delayEntries.map((d) => (
                    <tr key={d.key} className="border-t">
                      <td className="py-2 pr-4 font-mono text-xs">{d.target}</td>
                      <td className="py-2 pr-4 font-mono text-xs">{d.selector}</td>
                      <td className="py-2 pr-4">{d.enabled ? 'Yes' : 'No'}</td>
                      <td className="py-2 pr-4">{d.delay.toString()}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </section>

        <section className="bg-white rounded border p-4 grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="space-y-3">
            <h2 className="font-semibold">Schedule — Single</h2>
            <div>
              <label className="block text-xs text-gray-600 mb-1">Target</label>
              <input className="w-full border rounded px-2 py-1" placeholder="0x..." value={singleTarget} onChange={(e) => setSingleTarget(e.target.value)} />
            </div>
            <div>
              <label className="block text-xs text-gray-600 mb-1">Value (ETH)</label>
              <input className="w-full border rounded px-2 py-1" placeholder="0" value={singleValueEth} onChange={(e) => setSingleValueEth(e.target.value)} />
            </div>
            <div>
              <div className="flex items-center justify-between">
                <label className="block text-xs text-gray-600 mb-1">Calldata (hex)</label>
                <span className="text-xs text-gray-500">Selector: <span className="font-mono">{selectorFromData(singleData)}</span></span>
              </div>
              <input className="w-full border rounded px-2 py-1 font-mono text-xs" placeholder="0x" value={singleData} onChange={(e) => setSingleData(e.target.value)} />

              <details className="mt-2">
                <summary className="cursor-pointer text-sm text-indigo-600">Calldata Builder</summary>
                <div className="mt-2 space-y-2 border rounded p-2 bg-gray-50">
                  <div className="flex items-center gap-2 text-xs">
                    <label className="font-medium">Mode:</label>
                    <select className="border rounded px-2 py-1" value={builderMode} onChange={(e) => setBuilderMode(e.target.value as any)}>
                      <option value="raw">Raw Hex</option>
                      <option value="abi">ABI Function</option>
                      <option value="sig">Function Signature</option>
                    </select>
                  </div>

                  {builderMode === 'abi' && (
                    <div className="space-y-2">
                      <div>
                        <label className="block text-xs text-gray-600 mb-1">ABI JSON</label>
                        <textarea className="w-full border rounded px-2 py-1 font-mono text-xs" rows={4} placeholder='[ { "type": "function", "name": "transfer", "inputs": [ { "name": "to", "type": "address" }, { "name": "amount", "type": "uint256" } ] } ]' value={builderAbiText} onChange={(e) => setBuilderAbiText(e.target.value)} />
                      </div>
                      <div>
                        <label className="block text-xs text-gray-600 mb-1">Function Name</label>
                        <input className="w-full border rounded px-2 py-1 text-sm" placeholder="transfer" value={builderFnName} onChange={(e) => setBuilderFnName(e.target.value)} />
                      </div>
                      <div>
                        <label className="block text-xs text-gray-600 mb-1">Args (JSON array)</label>
                        <input className="w-full border rounded px-2 py-1 font-mono text-xs" placeholder='["0xabc...", "1"]' value={builderArgsText} onChange={(e) => setBuilderArgsText(e.target.value)} />
                      </div>
                      {builderError && <div className="text-xs text-red-600">{builderError}</div>}
                      <button className="px-3 py-1.5 border rounded bg-white" onClick={buildCalldataFromAbi}>Build Calldata</button>
                    </div>
                  )}

                  {builderMode === 'sig' && (
                    <div className="space-y-2">
                      <div>
                        <label className="block text-xs text-gray-600 mb-1">Function Signature</label>
                        <input className="w-full border rounded px-2 py-1 text-sm" placeholder="transfer(address,uint256)" value={builderFnName} onChange={(e) => setBuilderFnName(e.target.value)} />
                      </div>
                      <div>
                        <label className="block text-xs text-gray-600 mb-1">Args (JSON array)</label>
                        <input className="w-full border rounded px-2 py-1 font-mono text-xs" placeholder='["0xabc...", "1"]' value={builderArgsText} onChange={(e) => setBuilderArgsText(e.target.value)} />
                      </div>
                      {builderError && <div className="text-xs text-red-600">{builderError}</div>}
                      <button className="px-3 py-1.5 border rounded bg-white" onClick={buildCalldataFromSignature}>Build Calldata</button>
                    </div>
                  )}

                  {builderMode === 'raw' && (
                    <div className="text-xs text-gray-600">Enter hex calldata above. Builder is optional.</div>
                  )}
                </div>
              </details>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs text-gray-600 mb-1">Predecessor (bytes32)</label>
                <input className="w-full border rounded px-2 py-1 font-mono text-xs" value={singlePredecessor} onChange={(e) => setSinglePredecessor(e.target.value)} />
              </div>
              <div>
                <label className="block text-xs text-gray-600 mb-1">Salt (bytes32)</label>
                <input className="w-full border rounded px-2 py-1 font-mono text-xs" value={singleSalt} onChange={(e) => setSingleSalt(e.target.value)} />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-3 items-end">
              <div>
                <label className="block text-xs text-gray-600 mb-1">Delay (seconds)</label>
                <input className="w-full border rounded px-2 py-1" placeholder="0" value={singleDelay} onChange={(e) => setSingleDelay(e.target.value)} />
                <div className="text-xs text-gray-500 mt-1">Required min: {singleMinDelay !== null ? `${singleMinDelay} s` : '—'}</div>
              </div>
              <div className="flex items-center gap-2">
                <button onClick={computeSingleMinDelay} disabled={!canInteract} className="px-3 py-1.5 rounded bg-gray-100 border">Check Min Delay</button>
                <button onClick={onScheduleSingle} disabled={scheduling || !canInteract} className="px-3 py-1.5 rounded bg-indigo-600 text-white disabled:opacity-60">{scheduling ? 'Scheduling…' : 'Schedule'}</button>
              </div>
            </div>
          </div>

          <div className="space-y-3">
            <h2 className="font-semibold">Schedule — Batch</h2>
            <div className="space-y-2">
              {batchRows.map((row, i) => (
                <div key={i} className="grid grid-cols-12 gap-2 items-end">
                  <div className="col-span-4">
                    <label className="block text-xs text-gray-600 mb-1">Target</label>
                    <input className="w-full border rounded px-2 py-1" value={row.target} onChange={(e) => {
                      const next = [...batchRows]; next[i].target = e.target.value; setBatchRows(next)
                    }} />
                  </div>
                  <div className="col-span-2">
                    <label className="block text-xs text-gray-600 mb-1">Value (ETH)</label>
                    <input className="w-full border rounded px-2 py-1" value={row.valueEth} onChange={(e) => {
                      const next = [...batchRows]; next[i].valueEth = e.target.value; setBatchRows(next)
                    }} />
                  </div>
                  <div className="col-span-5">
                    <label className="block text-xs text-gray-600 mb-1">Calldata (hex)</label>
                    <input className="w-full border rounded px-2 py-1 font-mono text-xs" value={row.data} onChange={(e) => {
                      const next = [...batchRows]; next[i].data = e.target.value; setBatchRows(next)
                    }} />
                  </div>
                  <div className="col-span-1 flex gap-2">
                    <button className="px-2 py-1 border rounded" onClick={() => setBatchRows((rows) => rows.filter((_, j) => j !== i))}>−</button>
                  </div>
                </div>
              ))}
              <button className="px-3 py-1.5 border rounded" onClick={() => setBatchRows((r) => [...r, { target: '', valueEth: '0', data: '0x' }])}>+ Add Row</button>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs text-gray-600 mb-1">Predecessor (bytes32)</label>
                <input className="w-full border rounded px-2 py-1 font-mono text-xs" value={batchPredecessor} onChange={(e) => setBatchPredecessor(e.target.value)} />
              </div>
              <div>
                <label className="block text-xs text-gray-600 mb-1">Salt (bytes32)</label>
                <input className="w-full border rounded px-2 py-1 font-mono text-xs" value={batchSalt} onChange={(e) => setBatchSalt(e.target.value)} />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-3 items-end">
              <div>
                <label className="block text-xs text-gray-600 mb-1">Delay (seconds)</label>
                <input className="w-full border rounded px-2 py-1" placeholder="0" value={batchDelay} onChange={(e) => setBatchDelay(e.target.value)} />
              </div>
              <div>
                <button onClick={onScheduleBatch} disabled={scheduling || !canInteract} className="px-3 py-1.5 rounded bg-indigo-600 text-white disabled:opacity-60">{scheduling ? 'Scheduling…' : 'Schedule Batch'}</button>
              </div>
            </div>
          </div>
        </section>

        <section className="bg-white rounded border p-4 space-y-3">
          <div className="flex items-center justify-between">
            <h2 className="font-semibold">Scheduled Operations</h2>
            <button onClick={loadOperations} disabled={loadingOps || !contractAddress || !publicClient} className="px-3 py-1.5 rounded bg-indigo-600 text-white text-sm disabled:opacity-60">{loadingOps ? 'Loading…' : 'Load Scheduled'}</button>
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full text-sm">
              <thead>
                <tr className="text-left text-gray-500">
                  <th className="py-2 pr-4">ID</th>
                  <th className="py-2 pr-4">Txs</th>
                  <th className="py-2 pr-4">ETA</th>
                  <th className="py-2 pr-4">State</th>
                  <th className="py-2 pr-4">Action</th>
                </tr>
              </thead>
              <tbody>
                {ops.length === 0 ? (
                  <tr><td className="py-3 text-gray-400" colSpan={5}>No scheduled operations loaded</td></tr>
                ) : (
                  ops.map((op) => (
                    <tr key={op.id} className="border-t align-top">
                      <td className="py-2 pr-4 font-mono text-xs">{op.id}</td>
                      <td className="py-2 pr-4">
                        <div className="space-y-2">
                          {op.txs.map((t) => (
                            <div key={`${op.id}-${t.index.toString()}`} className="p-2 bg-gray-50 rounded border">
                              <div className="text-xs text-gray-600">Index {t.index.toString()}</div>
                              <div className="text-xs">Target: <span className="font-mono">{t.target}</span></div>
                              <div className="text-xs">Value: {formatEther(t.value)} ETH</div>
                              <div className="text-xs">Selector: <span className="font-mono">{selectorFromData(t.data)}</span></div>
                              <details>
                                <summary className="text-xs text-gray-600 cursor-pointer">Data</summary>
                                <div className="font-mono text-xs break-all">{t.data}</div>
                              </details>
                            </div>
                          ))}
                        </div>
                      </td>
                      <td className="py-2 pr-4 text-xs">
                        {op.timestamp === 0n ? '—' : new Date(Number(op.timestamp) * 1000).toLocaleString()}
                      </td>
                      <td className="py-2 pr-4">
                        {op.state === OperationState.Ready ? (
                          <span className="px-2 py-0.5 rounded bg-green-100 text-green-700 text-xs">Ready</span>
                        ) : op.state === OperationState.Waiting ? (
                          <span className="px-2 py-0.5 rounded bg-yellow-100 text-yellow-700 text-xs">Waiting</span>
                        ) : op.state === OperationState.Done ? (
                          <span className="px-2 py-0.5 rounded bg-gray-200 text-gray-700 text-xs">Done</span>
                        ) : (
                          <span className="px-2 py-0.5 rounded bg-gray-100 text-gray-600 text-xs">Unset</span>
                        )}
                      </td>
                      <td className="py-2 pr-4">
                        <button
                          onClick={() => onExecute(op)}
                          disabled={executing === op.id || !canInteract || op.state !== OperationState.Ready}
                          className="px-3 py-1.5 rounded bg-indigo-600 text-white text-sm disabled:opacity-60"
                        >
                          {executing === op.id ? 'Executing…' : op.txs.length === 1 ? 'Execute' : 'Execute Batch'}
                        </button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </section>
      </div>
    </div>
  )
}
