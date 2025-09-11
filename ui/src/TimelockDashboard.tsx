import { useEffect, useMemo, useRef, useState } from 'react'
import {
  createPublicClient,
  decodeEventLog,
  encodeFunctionData,
  formatEther,
  getAddress,
  Hex,
  http,
  parseEther,
  parseAbiItem,
} from 'viem'
import type { Abi, AbiFunction, PublicClient } from 'viem'
import {
  useAccount,
  useChainId,
  usePublicClient as useWagmiPublicClient,
  useWalletClient,
} from 'wagmi'
import { wagmiAdapter } from './wagmiConfig'
import { networkAbi, OperationState } from './abi'
import { useAppKit } from '@reown/appkit/library/react'

// Constants
const ZERO_32: Hex =
  '0x0000000000000000000000000000000000000000000000000000000000000000'
const ZERO_ADDRESS =
  '0x0000000000000000000000000000000000000000' as `0x${string}`
const DEFAULT_MAX_BLOCKS_PER_QUERY = '10000'
const DEFAULT_BATCH_DELAY = '0'
const DEFAULT_BATCH_BUILDER_ARGS = '[]'
const DEFAULT_BATCH_BUILDER_ROW = '0'
const NATIVE_ASSET_TRANSFER_SELECTOR = '0xeeeeeeee'

// Types
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

type RoleEntry = {
  role: Hex
  name?: string
  admin?: Hex | null
  members: `0x${string}`[]
}

type DelayEntry = {
  key: string
  target: `0x${string}`
  selector: string
  enabled: boolean
  delay: bigint
}

type BatchRow = {
  target: string
  valueEth: string
  data: string
}

type BatchBuilderMode = 'raw' | 'abi' | 'sig'

type ActiveTab = 'main' | 'acl'

// Utility functions
const selectorFromData = (data: string): string => {
  try {
    const d = (data || '').toLowerCase()
    if (!d || d === '0x') return NATIVE_ASSET_TRANSFER_SELECTOR
    return d.startsWith('0x') ? d.slice(0, 10) : '0x' + d.slice(0, 8)
  } catch {
    return '0x'
  }
}

const getLogsChunked = async (
  client: PublicClient,
  params: any,
  start: bigint,
  end: bigint,
  maxSpan: bigint,
  tokenRef: React.MutableRefObject<number>,
  myToken: number
) => {
  let cur = start
  const out: any[] = []
  while (cur <= end) {
    if (tokenRef.current !== myToken) throw new Error('canceled')
    const chunkTo = cur + maxSpan > end ? end : cur + maxSpan
    const part = await client.getLogs({
      ...params,
      fromBlock: cur,
      toBlock: chunkTo,
    } as any)
    out.push(...part)
    cur = chunkTo + 1n
  }
  return out
}

const isArchiveRpcError = (error: any): boolean => {
  const msg = String(error?.message || error)
  return (
    msg.includes('missing trie node') ||
    msg.includes('state') ||
    msg.includes('Missing or invalid parameters')
  )
}

const handleError = (error: any, context: string) => {
  console.error(`${context} error:`, error)
  // Could add user-facing error notifications here
}

// Custom hooks
const useRpcChainId = (
  rpcUrl: string,
  effectivePublicClient: PublicClient | null
) => {
  const [rpcDerivedChainId, setRpcDerivedChainId] = useState<number | null>(
    null
  )

  useEffect(() => {
    let cancelled = false
    async function fetchChainId() {
      try {
        if (rpcUrl && effectivePublicClient) {
          const id = await (effectivePublicClient as any).getChainId?.()
          if (!cancelled && typeof id === 'number') setRpcDerivedChainId(id)
        } else {
          if (!cancelled) setRpcDerivedChainId(null)
        }
      } catch {
        if (!cancelled) setRpcDerivedChainId(null)
      }
    }
    fetchChainId()
    return () => {
      cancelled = true
    }
  }, [rpcUrl, effectivePublicClient])

  return rpcDerivedChainId
}

export default function TimelockDashboard() {
  const [rpcUrl, setRpcUrl] = useState<string>('')
  const [contractAddress, setContractAddress] = useState<string>('')
  const [fromBlock, setFromBlock] = useState<string>('0')
  const { address: account } = useAccount()
  const chainId = useChainId()
  const wagmiPublicClient = useWagmiPublicClient()
  const { data: walletClient } = useWalletClient()
  const { open } = useAppKit()

  const [contractName, setContractName] = useState<string>('')
  const [metadataURI, setMetadataURI] = useState<string>('')
  const [globalMinDelay, setGlobalMinDelay] = useState<bigint | null>(null)
  const [activeTab, setActiveTab] = useState<ActiveTab>('main')

  const [delayEntries, setDelayEntries] = useState<DelayEntry[]>([])

  const [ops, setOps] = useState<OperationEntry[]>([])
  // Loading states
  const [loadingDelays, setLoadingDelays] = useState(false)
  const [loadingOps, setLoadingOps] = useState(false)
  const [scheduling, setScheduling] = useState(false)
  const [executing, setExecuting] = useState<string>('') // id being executed

  // Batch builder state
  const [batchBuilderMode, setBatchBuilderMode] =
    useState<BatchBuilderMode>('raw')
  const [batchBuilderAbiText, setBatchBuilderAbiText] = useState<string>('')
  const [batchBuilderFnName, setBatchBuilderFnName] = useState<string>('')
  const [batchBuilderArgsText, setBatchBuilderArgsText] = useState<string>(
    DEFAULT_BATCH_BUILDER_ARGS
  )
  const [batchBuilderError, setBatchBuilderError] = useState<string>('')
  const [batchBuilderRow, setBatchBuilderRow] = useState<string>(
    DEFAULT_BATCH_BUILDER_ROW
  )

  // Batch schedule state
  const [batchRows, setBatchRows] = useState<BatchRow[]>([
    { target: '', valueEth: '0', data: '0x' },
  ])
  const [batchPredecessor, setBatchPredecessor] = useState<string>(ZERO_32)
  const [batchSalt, setBatchSalt] = useState<string>(ZERO_32)
  const [batchDelay, setBatchDelay] = useState<string>(DEFAULT_BATCH_DELAY)
  const [batchMinDelay, setBatchMinDelay] = useState<bigint | null>(null)

  // Configuration state
  const [maxBlocksPerQuery, setMaxBlocksPerQuery] = useState<string>(
    DEFAULT_MAX_BLOCKS_PER_QUERY
  )
  const [detectingFromBlock, setDetectingFromBlock] = useState(false)
  // Token refs for cancellation
  const delaysTokenRef = useRef(0)
  const opsTokenRef = useRef(0)
  const aclTokenRef = useRef(0)
  const detectTokenRef = useRef(0)

  // Access Control state
  const [rolesLoading, setRolesLoading] = useState(false)
  const [roles, setRoles] = useState<RoleEntry[]>([])

  // Unified loading state across sections
  const isAnyLoading = loadingDelays || loadingOps || rolesLoading

  // Extracted Access Control loader for unified Load
  const loadAccessControl = async () => {
    if (!effectivePublicClient || !contractAddress) return
    setRolesLoading(true)
    try {
      const myToken = ++aclTokenRef.current
      const from = BigInt(fromBlock || '0')
      const latest = await effectivePublicClient.getBlockNumber()
      const maxSpan = BigInt(
        Number(maxBlocksPerQuery || DEFAULT_MAX_BLOCKS_PER_QUERY)
      )

      const [grants, revokes] = await Promise.all([
        getLogsChunked(
          effectivePublicClient,
          {
            address: contractAddress as `0x${string}`,
            event: {
              type: 'event',
              name: 'RoleGranted',
              inputs: [
                { name: 'role', type: 'bytes32', indexed: true },
                { name: 'account', type: 'address', indexed: true },
                { name: 'sender', type: 'address', indexed: true },
              ],
              anonymous: false,
            } as const,
          },
          from,
          latest,
          maxSpan,
          aclTokenRef,
          myToken
        ),
        getLogsChunked(
          effectivePublicClient,
          {
            address: contractAddress as `0x${string}`,
            event: {
              type: 'event',
              name: 'RoleRevoked',
              inputs: [
                { name: 'role', type: 'bytes32', indexed: true },
                { name: 'account', type: 'address', indexed: true },
                { name: 'sender', type: 'address', indexed: true },
              ],
              anonymous: false,
            } as const,
          },
          from,
          latest,
          maxSpan,
          aclTokenRef,
          myToken
        ),
      ])

      if (aclTokenRef.current !== myToken) return
      const members = new Map<string, Set<`0x${string}`>>()
      for (const log of grants) {
        // @ts-ignore
        const role: Hex = log.args.role
        // @ts-ignore
        const account: `0x${string}` = log.args.account
        const set = members.get(role) ?? new Set()
        set.add(account)
        members.set(role, set)
      }
      for (const log of revokes) {
        // @ts-ignore
        const role: Hex = log.args.role
        // @ts-ignore
        const account: `0x${string}` = log.args.account
        const set = members.get(role)
        if (set) set.delete(account)
      }

      const known: { [k: string]: string } = {}
      const tryRead = async (fn: string, name: string) => {
        try {
          const id = (await effectivePublicClient.readContract({
            address: contractAddress as `0x${string}`,
            abi: networkAbi,
            functionName: fn as any,
          })) as Hex
          known[id] = name
        } catch {}
      }
      await Promise.all([
        tryRead('DEFAULT_ADMIN_ROLE', 'DEFAULT_ADMIN_ROLE'),
        tryRead('PROPOSER_ROLE', 'PROPOSER_ROLE'),
        tryRead('EXECUTOR_ROLE', 'EXECUTOR_ROLE'),
        tryRead('CANCELLER_ROLE', 'CANCELLER_ROLE'),
        tryRead('NAME_UPDATE_ROLE', 'NAME_UPDATE_ROLE'),
        tryRead('METADATA_URI_UPDATE_ROLE', 'METADATA_URI_UPDATE_ROLE'),
      ])

      if (aclTokenRef.current !== myToken) return
      const roleIds = Array.from(members.keys())
      if (Object.keys(known).length) {
        for (const k of Object.keys(known))
          if (!roleIds.includes(k)) roleIds.push(k)
      }

      const entries: RoleEntry[] = []
      for (const role of roleIds) {
        if (aclTokenRef.current !== myToken) return
        let admin: Hex | null = null
        try {
          admin = (await effectivePublicClient.readContract({
            address: contractAddress as `0x${string}`,
            abi: networkAbi,
            functionName: 'getRoleAdmin',
            args: [role as Hex],
          })) as Hex
        } catch {}
        const mems = Array.from(members.get(role) ?? [])
        entries.push({
          role: role as Hex,
          name: known[role],
          admin,
          members: mems,
        })
      }

      if (aclTokenRef.current !== myToken) return
      entries.sort(
        (a, b) =>
          (a.name ? 0 : 1) - (b.name ? 0 : 1) || a.role.localeCompare(b.role)
      )
      if (aclTokenRef.current === myToken) setRoles(entries)
    } finally {
      setRolesLoading(false)
    }
  }

  // Unified load and cancel controls

  const cancelAllLoads = useMemo(
    () => () => {
      delaysTokenRef.current++
      opsTokenRef.current++
      aclTokenRef.current++
      setLoadingDelays(false)
      setLoadingOps(false)
      setRolesLoading(false)
    },
    [
      delaysTokenRef,
      opsTokenRef,
      aclTokenRef,
      setLoadingDelays,
      setLoadingOps,
      setRolesLoading,
    ]
  )

  const detectDeploymentBlock = async () => {
    if (!effectivePublicClient || !contractAddress) return
    setDetectingFromBlock(true)
    try {
      const myToken = ++detectTokenRef.current
      const latest = await effectivePublicClient.getBlockNumber()
      const hasCodeLatest = await effectivePublicClient
        .getCode({
          address: contractAddress as `0x${string}`,
          blockNumber: latest,
        })
        .catch((e: any) => {
          console.error('Detect latest code error', e)
          throw e
        })
      if (!hasCodeLatest) {
        alert('No code found at the latest block — is the address correct?')
        return
      }
      let lo = 0n
      let hi = latest
      while (lo < hi) {
        if (detectTokenRef.current !== myToken) throw new Error('canceled')
        const mid = (lo + hi) >> 1n
        let code: Hex | undefined
        try {
          code = await effectivePublicClient.getCode({
            address: contractAddress as `0x${string}`,
            blockNumber: mid,
          })
        } catch (e: any) {
          if (isArchiveRpcError(e)) {
            alert(
              'Archive RPC is required to detect the exact deployment block. Please provide an archive-capable RPC URL in the RPC URL field (e.g. Alchemy/Infura), or set From Block manually.'
            )
            throw new Error('archive-rpc-required')
          }
          throw e
        }
        if (code) hi = mid
        else lo = mid + 1n
      }
      if (detectTokenRef.current === myToken) setFromBlock(lo.toString())
    } catch (e) {
      if ((e as any)?.message !== 'archive-rpc-required')
        handleError(e, 'Detect deployment block')
    } finally {
      setDetectingFromBlock(false)
    }
  }

  const effectivePublicClient: PublicClient | null = useMemo(() => {
    if (rpcUrl) return createPublicClient({ transport: http(rpcUrl) })
    return wagmiPublicClient ?? null
  }, [rpcUrl, wagmiPublicClient])

  // Derive chainId from custom RPC when wallet is not connected
  const rpcDerivedChainId = useRpcChainId(rpcUrl, effectivePublicClient)
  const effectiveChainId = rpcDerivedChainId ?? chainId

  const canSchedule = useMemo(() => {
    return Boolean(effectivePublicClient && contractAddress)
  }, [effectivePublicClient, contractAddress])
  const canInteract = useMemo(() => {
    return Boolean(
      effectivePublicClient && walletClient && account && contractAddress
    )
  }, [effectivePublicClient, walletClient, account, contractAddress])

  // Explorer link for manual deployment block lookup (uses configured chains)
  const explorerAddressUrl = useMemo(() => {
    if (!contractAddress) return ''
    const chain = wagmiAdapter?.wagmiConfig?.chains?.find(
      (c) => c.id === effectiveChainId
    )
    const base = chain?.blockExplorers?.default?.url
    if (!base) return ''
    const trimmed = base.endsWith('/') ? base.slice(0, -1) : base
    return `${trimmed}/address/${contractAddress}`
  }, [effectiveChainId, contractAddress])

  const readHeader = async () => {
    if (!effectivePublicClient || !contractAddress) return
    try {
      const [nm, meta, global] = await Promise.all([
        effectivePublicClient
          .readContract({
            address: contractAddress as `0x${string}`,
            abi: networkAbi,
            functionName: 'name',
          })
          .catch(() => ''),
        effectivePublicClient
          .readContract({
            address: contractAddress as `0x${string}`,
            abi: networkAbi,
            functionName: 'metadataURI',
          })
          .catch(() => ''),
        effectivePublicClient
          .readContract({
            address: contractAddress as `0x${string}`,
            abi: networkAbi,
            functionName: 'getMinDelay',
            args: [],
          })
          .catch(() => null),
      ])
      setContractName(nm as string)
      setMetadataURI(meta as string)
      setGlobalMinDelay(global as bigint | null)
    } catch (e) {
      handleError(e, 'Read header')
    }
  }

  useEffect(() => {
    readHeader()
  }, [effectivePublicClient, contractAddress])

  const loadDelays = async () => {
    if (!effectivePublicClient || !contractAddress) return
    setLoadingDelays(true)
    try {
      const myToken = ++delaysTokenRef.current
      const from = BigInt(fromBlock || '0')
      const latest = await effectivePublicClient.getBlockNumber()

      const maxSpan = BigInt(
        Number(maxBlocksPerQuery || DEFAULT_MAX_BLOCKS_PER_QUERY)
      )
      const logs = await getLogsChunked(
        effectivePublicClient,
        {
          address: contractAddress as `0x${string}`,
          event: {
            type: 'event',
            name: 'MinDelayChange',
            inputs: [
              { name: 'target', type: 'address', indexed: true },
              { name: 'selector', type: 'bytes4', indexed: true },
              { name: 'oldEnabledStatus', type: 'bool', indexed: false },
              { name: 'oldDelay', type: 'uint256', indexed: false },
              { name: 'newEnabledStatus', type: 'bool', indexed: false },
              { name: 'newDelay', type: 'uint256', indexed: false },
            ],
            anonymous: false,
          } as const,
        },
        from,
        latest,
        maxSpan,
        delaysTokenRef,
        myToken
      )

      // Decode only the custom MinDelayChange by trying both event defs and accepting the address+bytes4 one
      const map = new Map<
        string,
        {
          target: `0x${string}`
          selector: string
          enabled: boolean
          delay: bigint
        }
      >()
      for (const log of logs) {
        try {
          const decoded = decodeEventLog({
            abi: networkAbi,
            data: log.data,
            topics: log.topics,
          })
          if (decoded.eventName === 'MinDelayChange') {
            // Two possible overloads; we need the one with address + bytes4 indexed
            const args: any = decoded.args
            if (
              args &&
              typeof args.target === 'string' &&
              typeof args.selector === 'string' &&
              (typeof args.newEnabledStatus === 'boolean' ||
                typeof args.oldEnabledStatus === 'boolean')
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

      if (delaysTokenRef.current !== myToken) return
      const arr = Array.from(map.entries()).map(([key, v]) => ({ key, ...v }))
      // Sort: enabled first, then by target, then selector
      arr.sort(
        (a, b) =>
          (a.enabled === b.enabled ? 0 : a.enabled ? -1 : 1) ||
          a.target.localeCompare(b.target) ||
          a.selector.localeCompare(b.selector)
      )
      if (delaysTokenRef.current === myToken) setDelayEntries(arr)
    } catch (e) {
      handleError(e, 'Load delays')
    } finally {
      setLoadingDelays(false)
    }
  }

  const loadOperations = async () => {
    if (!effectivePublicClient || !contractAddress) return
    setLoadingOps(true)
    try {
      const myToken = ++opsTokenRef.current
      const from = BigInt(fromBlock || '0')
      const latest = await effectivePublicClient.getBlockNumber()

      const maxSpan = BigInt(
        Number(maxBlocksPerQuery || DEFAULT_MAX_BLOCKS_PER_QUERY)
      )

      // Fetch CallScheduled logs
      const scheduled = await getLogsChunked(
        effectivePublicClient,
        {
          address: contractAddress as `0x${string}`,
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
        },
        from,
        latest,
        maxSpan,
        opsTokenRef,
        myToken
      )

      // Fetch CallSalt logs
      const salts = await getLogsChunked(
        effectivePublicClient,
        {
          address: contractAddress as `0x${string}`,
          event: {
            type: 'event',
            name: 'CallSalt',
            inputs: [
              { name: 'id', type: 'bytes32', indexed: true },
              { name: 'salt', type: 'bytes32', indexed: false },
            ],
            anonymous: false,
          } as const,
        },
        from,
        latest,
        maxSpan,
        opsTokenRef,
        myToken
      )

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
            salt: saltById.get(id) ?? ZERO_32,
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
        entry.txs.sort((a, b) =>
          a.index < b.index ? -1 : a.index > b.index ? 1 : 0
        )
        try {
          const [ts, st] = await Promise.all([
            effectivePublicClient.readContract({
              address: contractAddress as `0x${string}`,
              abi: networkAbi,
              functionName: 'getTimestamp',
              args: [entry.id],
            }) as Promise<bigint>,
            effectivePublicClient.readContract({
              address: contractAddress as `0x${string}`,
              abi: networkAbi,
              functionName: 'getOperationState',
              args: [entry.id],
            }) as Promise<number>,
          ])
          entry.timestamp = ts
          entry.state = st as OperationState
        } catch (e) {
          // ignore
        }
      }

      if (opsTokenRef.current !== myToken) return
      // Sort entries: Ready first, then Waiting by timestamp, then Done
      entries.sort((a, b) => {
        const prio = (x: OperationEntry) =>
          x.state === OperationState.Ready
            ? 0
            : x.state === OperationState.Waiting
            ? 1
            : x.state === OperationState.Done
            ? 2
            : 3
        return prio(a) - prio(b) || Number(a.timestamp - b.timestamp)
      })

      if (opsTokenRef.current === myToken) setOps(entries)
    } catch (e) {
      handleError(e, 'Load operations')
    } finally {
      setLoadingOps(false)
    }
  }

  const loadAll = useMemo(
    () => () => {
      loadDelays()
      loadOperations()
      loadAccessControl()
    },
    [loadDelays, loadOperations, loadAccessControl]
  )

  // Single schedule removed

  const onScheduleBatch = async () => {
    if (!effectivePublicClient || !contractAddress) return
    if (!walletClient || !account) {
      // Prompt user to connect if not connected
      try {
        await open?.()
      } catch {}
      return
    }
    setScheduling(true)
    try {
      const targets = batchRows.map(
        (r) => getAddress(r.target) as `0x${string}`
      )
      const values = batchRows.map((r) => parseEther(r.valueEth || '0'))
      const payloads = batchRows.map((r) => (r.data || '0x') as Hex)
      const hash = await walletClient.writeContract({
        address: contractAddress as `0x${string}`,
        abi: networkAbi,
        functionName: 'scheduleBatch',
        args: [
          targets,
          values,
          payloads,
          (batchPredecessor || ZERO_32) as Hex,
          (batchSalt || ZERO_32) as Hex,
          BigInt(batchDelay || DEFAULT_BATCH_DELAY),
        ],
        account,
        chain: undefined,
      })
      console.log('scheduleBatch tx', hash)
      await effectivePublicClient.waitForTransactionReceipt({ hash })
      await loadOperations()
    } catch (e) {
      handleError(e, 'Schedule batch')
    } finally {
      setScheduling(false)
    }
  }

  const onExecute = async (entry: OperationEntry) => {
    if (!walletClient || !effectivePublicClient || !account || !contractAddress)
      return
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
        await effectivePublicClient.waitForTransactionReceipt({ hash })
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
        await effectivePublicClient.waitForTransactionReceipt({ hash })
      }
      await loadOperations()
    } catch (e) {
      handleError(e, 'Execute operation')
    } finally {
      setExecuting('')
    }
  }

  // Single builder removed

  // Batch builder helpers
  const buildBatchCalldataFromAbi = () => {
    setBatchBuilderError('')
    try {
      const abi = JSON.parse(batchBuilderAbiText || '[]') as Abi
      const fns = (abi as any[]).filter(
        (i) => i && i.type === 'function'
      ) as AbiFunction[]
      const found = fns.find((f) => f.name === batchBuilderFnName)
      if (!found) {
        setBatchBuilderError('Function not found in ABI')
        return
      }
      const args = JSON.parse(batchBuilderArgsText || '[]')
      const data = encodeFunctionData({
        abi: abi as Abi,
        functionName: batchBuilderFnName as any,
        args,
      }) as Hex
      const idx = Math.max(
        0,
        Math.min(Number(batchBuilderRow) || 0, batchRows.length - 1)
      )
      const next = [...batchRows]
      if (!next[idx]) return
      next[idx] = { ...next[idx], data }
      setBatchRows(next)
    } catch (e: any) {
      setBatchBuilderError(e?.message || String(e))
    }
  }

  const buildBatchCalldataFromSignature = () => {
    setBatchBuilderError('')
    try {
      const item = parseAbiItem('function ' + batchBuilderFnName) as AbiFunction
      const args = JSON.parse(batchBuilderArgsText || '[]')
      const data = encodeFunctionData({
        abi: [item] as unknown as Abi,
        functionName: (item as any).name,
        args,
      }) as Hex
      const idx = Math.max(
        0,
        Math.min(Number(batchBuilderRow) || 0, batchRows.length - 1)
      )
      const next = [...batchRows]
      if (!next[idx]) return
      next[idx] = { ...next[idx], data }
      setBatchRows(next)
    } catch (e: any) {
      setBatchBuilderError(e?.message || String(e))
    }
  }

  const computeBatchMinDelay = async () => {
    if (!effectivePublicClient || !contractAddress) return
    try {
      if (!batchRows.length) {
        setBatchMinDelay(null)
        return
      }
      const mins = await Promise.all(
        batchRows.map(async (r) => {
          try {
            const m = await effectivePublicClient!.readContract({
              address: contractAddress as `0x${string}`,
              abi: networkAbi,
              functionName: 'getMinDelay',
              args: [
                getAddress(r.target) as `0x${string}`,
                (r.data || '0x') as Hex,
              ],
            })
            return m as bigint
          } catch {
            return 0n
          }
        })
      )
      const max = mins.reduce((acc, v) => (v > acc ? v : acc), 0n)
      setBatchMinDelay(max)
      if ((batchDelay || DEFAULT_BATCH_DELAY) === DEFAULT_BATCH_DELAY)
        setBatchDelay(String(max))
    } catch (e) {
      handleError(e, 'Compute batch min delay')
    }
  }

  // Keep required min delay up to date when inputs change
  const batchRowsStringified = useMemo(
    () => JSON.stringify(batchRows),
    [batchRows]
  )
  useEffect(() => {
    computeBatchMinDelay()
  }, [effectivePublicClient, contractAddress, batchRowsStringified])

  return (
    <div className='min-h-screen bg-gray-50 text-gray-900'>
      <div className='w-full bg-yellow-50 border-b border-yellow-200 text-yellow-900'>
        <div className='max-w-6xl mx-auto px-4 py-2 text-sm font-medium text-center flex justify-center'>
          WIP, USE WITH CAUTION!
        </div>
      </div>
      <div className='max-w-6xl mx-auto p-4 space-y-6'>
        <header className='flex items-center justify-between'>
          <div>
            <h1 className='text-2xl font-semibold'>Network Dashboard</h1>
            <p className='text-sm text-gray-500'>
              View delays and role holders, schedule actions, execute when ready
            </p>
          </div>
          <div className='flex items-center gap-2'>
            <appkit-button />
          </div>
        </header>

        <section className='bg-white rounded border p-4 space-y-3'>
          <div className='grid grid-cols-1 md:grid-cols-4 gap-3'>
            <div>
              <label className='block text-xs text-gray-600 mb-1'>
                RPC URL (optional)
              </label>
              <input
                className='w-full border rounded px-2 py-1'
                placeholder='http(s)://...'
                value={rpcUrl}
                onChange={(e) => setRpcUrl(e.target.value.trim())}
              />
              <p className='text-xs text-gray-500 mt-1'>
                If empty, uses injected wallet provider.
              </p>
            </div>
            <div>
              <label className='block text-xs text-gray-600 mb-1'>
                Contract Address
              </label>
              <input
                className='w-full border rounded px-2 py-1'
                placeholder='0x...'
                value={contractAddress}
                onChange={(e) => setContractAddress(e.target.value.trim())}
              />
              <div className='text-xs text-gray-500 mt-1'>
                Timelock-enabled Network contract
              </div>
            </div>
            <div>
              <label className='block text-xs text-gray-600 mb-1'>
                From Block (logs)
              </label>
              <div className='flex gap-2'>
                <input
                  className='w-full border rounded px-2 py-1'
                  placeholder='0'
                  value={fromBlock}
                  onChange={(e) => setFromBlock(e.target.value.trim())}
                />
                <div className='flex gap-2'>
                  <button
                    onClick={detectDeploymentBlock}
                    disabled={
                      detectingFromBlock ||
                      !contractAddress ||
                      !effectivePublicClient
                    }
                    className='px-2 py-1 border rounded text-sm disabled:opacity-60'
                  >
                    {detectingFromBlock ? 'Detecting…' : 'Detect'}
                  </button>
                  {detectingFromBlock && (
                    <button
                      onClick={() => {
                        detectTokenRef.current++
                        setDetectingFromBlock(false)
                      }}
                      className='px-2 py-1 border rounded text-sm'
                    >
                      Cancel
                    </button>
                  )}
                </div>
              </div>
              <div className='text-xs text-gray-500 mt-1'>
                Use a recent block to limit queries. Detect finds the deployment
                block.
                {explorerAddressUrl ? (
                  <>
                    {' '}
                    Or get it from{' '}
                    <a
                      href={explorerAddressUrl}
                      target='_blank'
                      rel='noreferrer'
                      className='text-indigo-600 hover:underline'
                    >
                      explorer
                    </a>
                    .
                  </>
                ) : null}
              </div>
            </div>
            <div>
              <label className='block text-xs text-gray-600 mb-1'>
                Max Blocks per Query
              </label>
              <input
                className='w-full border rounded px-2 py-1'
                value={maxBlocksPerQuery}
                onChange={(e) => setMaxBlocksPerQuery(e.target.value)}
              />
              <div className='text-xs text-gray-500 mt-1'>
                Lower if your RPC has strict limits
              </div>
            </div>
          </div>

          <div className='flex items-center gap-3 text-sm'>
            <div className='text-gray-700'>
              Name: <span className='font-medium'>{contractName || '—'}</span>
            </div>
            <div className='text-gray-700'>
              Metadata: <span className='font-mono'>{metadataURI || '—'}</span>
            </div>
            <div className='text-gray-700'>
              Global Min Delay:{' '}
              <span className='font-mono'>
                {globalMinDelay !== null ? `${globalMinDelay} s` : '—'}
              </span>
            </div>
          </div>
          <div className='flex justify-end gap-2'>
            <button
              onClick={loadAll}
              disabled={
                isAnyLoading || !contractAddress || !effectivePublicClient
              }
              className='px-3 py-1.5 rounded bg-indigo-600 text-white text-sm disabled:opacity-60'
            >
              {isAnyLoading ? 'Loading…' : 'Load'}
            </button>
            {isAnyLoading && (
              <button
                onClick={cancelAllLoads}
                className='px-3 py-1.5 rounded bg-gray-100 border text-sm'
              >
                Cancel
              </button>
            )}
          </div>
        </section>

        <div className='border-b mb-4'>
          <div className='flex gap-2'>
            <button
              onClick={() => setActiveTab('main')}
              className={`px-3 py-2 text-sm ${
                activeTab === 'main'
                  ? 'border-b-2 border-indigo-600 text-indigo-600'
                  : 'text-gray-600'
              }`}
            >
              Actions
            </button>
            <button
              onClick={() => setActiveTab('acl')}
              className={`px-3 py-2 text-sm ${
                activeTab === 'acl'
                  ? 'border-b-2 border-indigo-600 text-indigo-600'
                  : 'text-gray-600'
              }`}
            >
              Access Control
            </button>
          </div>
        </div>
        {activeTab === 'main' && (
          <section className='bg-white rounded border p-4 space-y-3'>
            <div className='flex items-center justify-between'>
              <h2 className='font-semibold'>Delays Setup</h2>
            </div>

            <div className='overflow-x-auto'>
              <table className='min-w-full text-sm'>
                <thead>
                  <tr className='text-left text-gray-500'>
                    <th className='py-2 pr-4'>Target</th>
                    <th className='py-2 pr-4'>Selector</th>
                    <th className='py-2 pr-4'>Enabled</th>
                    <th className='py-2 pr-4'>Min Delay (s)</th>
                  </tr>
                </thead>
                <tbody>
                  {delayEntries.length === 0 ? (
                    <tr>
                      <td className='py-3 text-gray-400' colSpan={4}>
                        No entries loaded
                      </td>
                    </tr>
                  ) : (
                    <>
                      {delayEntries.map((d) => {
                        const displayTarget =
                          d.target === ZERO_ADDRESS ? 'any' : d.target
                        const displaySelector = d.selector
                        return (
                          <tr key={d.key} className='border-t'>
                            <td className='py-2 pr-4 font-mono text-xs'>
                              {displayTarget}
                            </td>
                            <td className='py-2 pr-4 font-mono text-xs'>
                              {displaySelector}
                            </td>
                            <td className='py-2 pr-4'>
                              {d.enabled ? 'Yes' : 'No'}
                            </td>
                            <td className='py-2 pr-4'>{d.delay.toString()}</td>
                          </tr>
                        )
                      })}
                    </>
                  )}
                  <tr className='border-t bg-gray-50'>
                    <td className='py-2 pr-4 font-mono text-xs'>any</td>
                    <td className='py-2 pr-4 font-mono text-xs'>any</td>
                    <td className='py-2 pr-4'>—</td>
                    <td className='py-2 pr-4'>
                      {globalMinDelay !== null
                        ? globalMinDelay.toString()
                        : '—'}
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </section>
        )}

        {activeTab === 'main' && (
          <section className='bg-white rounded border p-4 space-y-3'>
            <div className='space-y-3'>
              <h2 className='font-semibold'>Schedule</h2>
              <div className='space-y-2'>
                {batchRows.map((row, i) => (
                  <div key={i} className='grid grid-cols-12 gap-2 items-end'>
                    <div className='col-span-4'>
                      <label className='block text-xs text-gray-600 mb-1'>
                        Target
                      </label>
                      <input
                        className='w-full border rounded px-2 py-1 text-sm'
                        value={row.target}
                        onChange={(e) => {
                          const next = [...batchRows]
                          next[i].target = e.target.value
                          setBatchRows(next)
                        }}
                      />
                    </div>
                    <div className='col-span-2'>
                      <label className='block text-xs text-gray-600 mb-1'>
                        Value (ETH)
                      </label>
                      <input
                        className='w-full border rounded px-2 py-1 text-sm'
                        value={row.valueEth}
                        onChange={(e) => {
                          const next = [...batchRows]
                          next[i].valueEth = e.target.value
                          setBatchRows(next)
                        }}
                      />
                    </div>
                    <div className='col-span-5'>
                      <label className='block text-xs text-gray-600 mb-1'>
                        Calldata (hex)
                      </label>
                      <input
                        className='w-full border rounded px-2 py-1 font-mono text-sm'
                        value={row.data}
                        onChange={(e) => {
                          const next = [...batchRows]
                          next[i].data = e.target.value
                          setBatchRows(next)
                        }}
                      />
                    </div>
                    <div className='col-span-1 flex gap-2'>
                      <button
                        className='px-2 py-1 border rounded'
                        onClick={() =>
                          setBatchRows((rows) => rows.filter((_, j) => j !== i))
                        }
                      >
                        −
                      </button>
                    </div>
                  </div>
                ))}
                <button
                  className='px-3 py-1.5 border rounded'
                  onClick={() =>
                    setBatchRows((r) => [
                      ...r,
                      { target: '', valueEth: '0', data: '0x' },
                    ])
                  }
                >
                  + Add Row
                </button>
                <details className='mt-2'>
                  <summary className='cursor-pointer text-sm text-indigo-600'>
                    Calldata Builder
                  </summary>
                  <div className='mt-2 space-y-2 border rounded p-2 bg-gray-50'>
                    <div className='grid grid-cols-1 sm:grid-cols-2 gap-3'>
                      <div>
                        <label className='block text-xs text-gray-600 mb-1'>
                          Row index
                        </label>
                        <input
                          className='w-full border rounded px-2 py-1 text-sm'
                          type='number'
                          min={0}
                          max={Math.max(0, batchRows.length - 1)}
                          value={batchBuilderRow}
                          onChange={(e) => setBatchBuilderRow(e.target.value)}
                        />
                        <div className='text-xs text-gray-500 mt-1'>
                          0 to {Math.max(0, batchRows.length - 1)}
                        </div>
                      </div>
                      <div>
                        <label className='block text-xs text-gray-600 mb-1'>
                          Mode
                        </label>
                        <select
                          className='w-full border rounded px-2 py-1'
                          value={batchBuilderMode}
                          onChange={(e) =>
                            setBatchBuilderMode(e.target.value as any)
                          }
                        >
                          <option value='raw'>Raw Hex</option>
                          <option value='abi'>ABI Function</option>
                          <option value='sig'>Function Signature</option>
                        </select>
                      </div>
                    </div>

                    {batchBuilderMode === 'abi' && (
                      <div className='space-y-2'>
                        <div>
                          <label className='block text-xs text-gray-600 mb-1'>
                            ABI JSON
                          </label>
                          <textarea
                            className='w-full border rounded px-2 py-1 font-mono text-xs'
                            rows={4}
                            placeholder='[ { "type": "function", "name": "transfer", "inputs": [ { "name": "to", "type": "address" }, { "name": "amount", "type": "uint256" } ] } ]'
                            value={batchBuilderAbiText}
                            onChange={(e) =>
                              setBatchBuilderAbiText(e.target.value)
                            }
                          />
                        </div>
                        <div>
                          <label className='block text-xs text-gray-600 mb-1'>
                            Function Name
                          </label>
                          <input
                            className='w-full border rounded px-2 py-1 text-sm'
                            placeholder='transfer'
                            value={batchBuilderFnName}
                            onChange={(e) =>
                              setBatchBuilderFnName(e.target.value)
                            }
                          />
                        </div>
                        <div>
                          <label className='block text-xs text-gray-600 mb-1'>
                            Args (JSON array)
                          </label>
                          <input
                            className='w-full border rounded px-2 py-1 font-mono text-xs'
                            placeholder='["0xabc...", "1"]'
                            value={batchBuilderArgsText}
                            onChange={(e) =>
                              setBatchBuilderArgsText(e.target.value)
                            }
                          />
                        </div>
                        {batchBuilderError && (
                          <div className='text-xs text-red-600'>
                            {batchBuilderError}
                          </div>
                        )}
                        <button
                          className='px-3 py-1.5 border rounded bg-white'
                          onClick={buildBatchCalldataFromAbi}
                        >
                          Apply to Row
                        </button>
                      </div>
                    )}

                    {batchBuilderMode === 'sig' && (
                      <div className='space-y-2'>
                        <div>
                          <label className='block text-xs text-gray-600 mb-1'>
                            Function Signature
                          </label>
                          <input
                            className='w-full border rounded px-2 py-1 text-sm'
                            placeholder='transfer(address,uint256)'
                            value={batchBuilderFnName}
                            onChange={(e) =>
                              setBatchBuilderFnName(e.target.value)
                            }
                          />
                        </div>
                        <div>
                          <label className='block text-xs text-gray-600 mb-1'>
                            Args (JSON array)
                          </label>
                          <input
                            className='w-full border rounded px-2 py-1 font-mono text-xs'
                            placeholder='["0xabc...", "1"]'
                            value={batchBuilderArgsText}
                            onChange={(e) =>
                              setBatchBuilderArgsText(e.target.value)
                            }
                          />
                        </div>
                        {batchBuilderError && (
                          <div className='text-xs text-red-600'>
                            {batchBuilderError}
                          </div>
                        )}
                        <button
                          className='px-3 py-1.5 border rounded bg-white'
                          onClick={buildBatchCalldataFromSignature}
                        >
                          Apply to Row
                        </button>
                      </div>
                    )}

                    {batchBuilderMode === 'raw' && (
                      <div className='text-xs text-gray-600'>
                        Edit the row's hex directly in the table above. Builder
                        is optional.
                      </div>
                    )}
                  </div>
                </details>
              </div>
              <div className='grid grid-cols-2 gap-3'>
                <div>
                  <label className='block text-xs text-gray-600 mb-1'>
                    Predecessor (bytes32)
                  </label>
                  <input
                    className='w-full border rounded px-2 py-1 font-mono text-xs'
                    value={batchPredecessor}
                    onChange={(e) => setBatchPredecessor(e.target.value)}
                  />
                </div>
                <div>
                  <label className='block text-xs text-gray-600 mb-1'>
                    Salt (bytes32)
                  </label>
                  <input
                    className='w-full border rounded px-2 py-1 font-mono text-xs'
                    value={batchSalt}
                    onChange={(e) => setBatchSalt(e.target.value)}
                  />
                </div>
              </div>
              <div className='grid grid-cols-2 gap-3 items-end'>
                <div>
                  <label className='block text-xs text-gray-600 mb-1'>
                    Delay (seconds)
                  </label>
                  <input
                    className='w-full border rounded px-2 py-1'
                    placeholder='0'
                    value={batchDelay}
                    onChange={(e) => setBatchDelay(e.target.value)}
                  />
                  <div className='text-xs text-gray-500 mt-1'>
                    Required min:{' '}
                    {batchMinDelay !== null ? `${batchMinDelay} s` : '—'}
                  </div>
                </div>
                <div className='col-span-2 flex items-center justify-end gap-2'>
                  <button
                    onClick={onScheduleBatch}
                    disabled={scheduling || !canSchedule}
                    className='px-3 py-1.5 rounded bg-indigo-600 text-white disabled:opacity-60'
                  >
                    {scheduling ? 'Scheduling…' : 'Schedule'}
                  </button>
                </div>
              </div>
            </div>
          </section>
        )}

        {activeTab === 'main' && (
          <section className='bg-white rounded border p-4 space-y-3'>
            <div className='flex items-center justify-between'>
              <h2 className='font-semibold'>Scheduled Operations</h2>
            </div>
            <div className='overflow-x-auto'>
              <table className='min-w-full text-sm'>
                <thead>
                  <tr className='text-left text-gray-500'>
                    <th className='py-2 pr-4'>ID</th>
                    <th className='py-2 pr-4'>Txs</th>
                    <th className='py-2 pr-4'>ETA</th>
                    <th className='py-2 pr-4'>State</th>
                    <th className='py-2 pr-4'>Action</th>
                  </tr>
                </thead>
                <tbody>
                  {ops.length === 0 ? (
                    <tr>
                      <td className='py-3 text-gray-400' colSpan={4}>
                        No scheduled operations loaded
                      </td>
                    </tr>
                  ) : (
                    ops.map((op) => (
                      <tr key={op.id} className='border-t align-top'>
                        <td className='py-2 pr-4 font-mono text-xs'>{op.id}</td>
                        <td className='py-2 pr-4'>
                          <div className='space-y-2'>
                            {op.txs.map((t) => (
                              <div
                                key={`${op.id}-${t.index.toString()}`}
                                className='p-2 bg-gray-50 rounded border'
                              >
                                <div className='text-xs text-gray-600'>
                                  Index {t.index.toString()}
                                </div>
                                <div className='text-xs'>
                                  Target:{' '}
                                  <span className='font-mono'>{t.target}</span>
                                </div>
                                <div className='text-xs'>
                                  Value: {formatEther(t.value)} ETH
                                </div>
                                <div className='text-xs'>
                                  Selector:{' '}
                                  <span className='font-mono'>
                                    {selectorFromData(t.data)}
                                  </span>
                                </div>
                                <details>
                                  <summary className='text-xs text-gray-600 cursor-pointer'>
                                    Data
                                  </summary>
                                  <div className='font-mono text-xs break-all'>
                                    {t.data}
                                  </div>
                                </details>
                              </div>
                            ))}
                          </div>
                        </td>
                        <td className='py-2 pr-4 text-xs'>
                          {op.timestamp === 0n
                            ? '—'
                            : new Date(
                                Number(op.timestamp) * 1000
                              ).toLocaleString()}
                        </td>
                        <td className='py-2 pr-4'>
                          {op.state === OperationState.Ready ? (
                            <span className='px-2 py-0.5 rounded bg-green-100 text-green-700 text-xs'>
                              Ready
                            </span>
                          ) : op.state === OperationState.Waiting ? (
                            <span className='px-2 py-0.5 rounded bg-yellow-100 text-yellow-700 text-xs'>
                              Waiting
                            </span>
                          ) : op.state === OperationState.Done ? (
                            <span className='px-2 py-0.5 rounded bg-gray-200 text-gray-700 text-xs'>
                              Done
                            </span>
                          ) : (
                            <span className='px-2 py-0.5 rounded bg-gray-100 text-gray-600 text-xs'>
                              Unset
                            </span>
                          )}
                        </td>
                        <td className='py-2 pr-4'>
                          <button
                            onClick={() => onExecute(op)}
                            disabled={
                              executing === op.id ||
                              !canInteract ||
                              op.state !== OperationState.Ready
                            }
                            className='px-3 py-1.5 rounded bg-indigo-600 text-white text-sm disabled:opacity-60'
                          >
                            {executing === op.id
                              ? 'Executing…'
                              : op.txs.length === 1
                              ? 'Execute'
                              : 'Execute Batch'}
                          </button>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </section>
        )}

        {activeTab === 'acl' && (
          <section className='bg-white rounded border p-4 space-y-3'>
            <div className='flex items-center justify-between'>
              <h2 className='font-semibold'>Access Control</h2>
            </div>

            <div className='overflow-x-auto'>
              <table className='min-w-full text-sm'>
                <thead>
                  <tr className='text-left text-gray-500'>
                    <th className='py-2 pr-4'>Role</th>
                    <th className='py-2 pr-4'>Role Id</th>
                    <th className='py-2 pr-4'>Admin</th>
                    <th className='py-2 pr-4'>Members</th>
                  </tr>
                </thead>
                <tbody>
                  {roles.length === 0 ? (
                    <tr>
                      <td className='py-3 text-gray-400' colSpan={4}>
                        No roles loaded
                      </td>
                    </tr>
                  ) : (
                    roles.map((r) => (
                      <tr key={r.role} className='border-t align-top'>
                        <td className='py-2 pr-4'>{r.name || '—'}</td>
                        <td className='py-2 pr-4 font-mono text-xs'>
                          {r.role}
                        </td>
                        <td className='py-2 pr-4 font-mono text-xs'>
                          {r.admin || '—'}
                        </td>
                        <td className='py-2 pr-4'>
                          {r.members.length === 0 ? (
                            <span className='text-xs text-gray-500'>
                              No members
                            </span>
                          ) : (
                            <div className='space-y-1'>
                              {r.members.map((m) => (
                                <div
                                  key={`${r.role}-${m}`}
                                  className='font-mono text-xs'
                                >
                                  {m}
                                </div>
                              ))}
                            </div>
                          )}
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </section>
        )}
      </div>
    </div>
  )
}
