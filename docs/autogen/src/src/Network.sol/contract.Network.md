# Network
[Git Source](https://github.com/symbioticfi/network/blob/40885f42f01a00727039ad723d5263fdb740bef0/src/Network.sol)

**Inherits:**
TimelockControllerUpgradeable, [INetwork](/Users/andreikorokhov/symbiotic/network/docs/autogen/src/src/interfaces/INetwork.sol/interface.INetwork.md)

Contract for network management.

It allows any external watcher to verify if the set delay is sufficient for a given operation (call to some contract's function).
It supports delays for native asset transfers (native transfer is determined as a call with 0xEEEEEEEE selector).
It supports setting delay for (exact target | exact selector) pairs and for (any target | exact selector) pairs.


## State Variables
### NAME_UPDATE_ROLE
Returns the role for updating the name.


```solidity
bytes32 public constant NAME_UPDATE_ROLE = keccak256("NAME_UPDATE_ROLE")
```


### METADATA_URI_UPDATE_ROLE
Returns the role for updating the metadata URI.


```solidity
bytes32 public constant METADATA_URI_UPDATE_ROLE = keccak256("METADATA_URI_UPDATE_ROLE")
```


### NETWORK_REGISTRY
Returns the address of the network registry.


```solidity
address public immutable NETWORK_REGISTRY
```


### NETWORK_MIDDLEWARE_SERVICE
Returns the address of the network middleware service.


```solidity
address public immutable NETWORK_MIDDLEWARE_SERVICE
```


### NetworkStorageLocation

```solidity
bytes32 private constant NetworkStorageLocation =
    0x2affd7691de6b6d2a998e6b135d73a3c906ea64896dff9dcb273e98dd44a6100
```


### TimelockControllerStorageLocation

```solidity
bytes32 private constant TimelockControllerStorageLocation =
    0x9a37c2aa9d186a0969ff8a8267bf4e07e864c2f2768f5040949e28a624fb3600
```


## Functions
### constructor


```solidity
constructor(address networkRegistry, address networkMiddlewareService) ;
```

### _getNetworkStorage


```solidity
function _getNetworkStorage() internal pure returns (NetworkStorage storage $);
```

### _getTimelockControllerStorageOverridden


```solidity
function _getTimelockControllerStorageOverridden() internal pure returns (TimelockControllerStorage storage $);
```

### initialize

Initializes the network.


```solidity
function initialize(NetworkInitParams memory initParams) public virtual initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`initParams`|`NetworkInitParams`||


### __Network_init


```solidity
function __Network_init(NetworkInitParams memory initParams) internal virtual onlyInitializing;
```

### getMinDelay

Returns the minimum delay for a given target and calldata.


```solidity
function getMinDelay(address target, bytes memory data) public view virtual returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`target`|`address`|The target address the delay is for.|
|`data`|`bytes`|The calldata of the function call.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The minimum delay for a given target and calldata.|


### name

Returns the name of the network.


```solidity
function name() public view virtual returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|The name of the network.|


### metadataURI

Returns the metadata URI of the network.


```solidity
function metadataURI() public view virtual returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|The metadata URI of the network.|


### updateDelay

Updates the delay for a given target and selector.

Can be reached only via scheduled calls.


```solidity
function updateDelay(address target, bytes4 selector, bool enabled, uint256 newDelay) public virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`target`|`address`|The target address the delay is for.|
|`selector`|`bytes4`|The function selector the delay is for.|
|`enabled`|`bool`|If to enable the delay.|
|`newDelay`|`uint256`|The new delay value.|


### schedule

Schedule an operation containing a single transaction.
Emits {CallSalt} if salt is nonzero, and {CallScheduled}.
Requirements:
- the caller must have the 'proposer' role.


```solidity
function schedule(
    address target,
    uint256 value,
    bytes calldata data,
    bytes32 predecessor,
    bytes32 salt,
    uint256 delay
) public virtual override onlyRole(PROPOSER_ROLE);
```

### scheduleBatch

Schedule an operation containing a batch of transactions.
Emits {CallSalt} if salt is nonzero, and one {CallScheduled} event per transaction in the batch.
Requirements:
- the caller must have the 'proposer' role.


```solidity
function scheduleBatch(
    address[] calldata targets,
    uint256[] calldata values,
    bytes[] calldata payloads,
    bytes32 predecessor,
    bytes32 salt,
    uint256 delay
) public virtual override onlyRole(PROPOSER_ROLE);
```

### updateName

Updates the name of the network.

The caller must have the name update role.


```solidity
function updateName(string memory name_) public virtual onlyRole(NAME_UPDATE_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`name_`|`string`||


### updateMetadataURI

Updates the metadata URI of the network.

The caller must have the metadata URI update role.


```solidity
function updateMetadataURI(string memory metadataURI_) public virtual onlyRole(METADATA_URI_UPDATE_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`metadataURI_`|`string`||


### setMaxNetworkLimit

Sets the maximum network limit for a delegator.

The caller must be the network's middleware.


```solidity
function setMaxNetworkLimit(address delegator, uint96 subnetworkId, uint256 maxNetworkLimit) public virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`delegator`|`address`|The address of the delegator.|
|`subnetworkId`|`uint96`|The identifier of the subnetwork.|
|`maxNetworkLimit`|`uint256`|The maximum network limit.|


### _updateDelay


```solidity
function _updateDelay(address target, bytes4 selector, bool enabled, uint256 newDelay) internal virtual;
```

### _scheduleOverridden


```solidity
function _scheduleOverridden(bytes32 id, uint256 delay) internal virtual;
```

### _updateName


```solidity
function _updateName(string memory name_) internal virtual;
```

### _updateMetadataURI


```solidity
function _updateMetadataURI(string memory metadataURI_) internal virtual;
```

### _setMaxNetworkLimit


```solidity
function _setMaxNetworkLimit(address delegator, uint96 subnetworkId, uint256 maxNetworkLimit) internal virtual;
```

### _getId


```solidity
function _getId(address target, bytes4 selector) internal pure virtual returns (bytes32 id);
```

### _getMinDelay


```solidity
function _getMinDelay(address target, bytes4 selector) internal view virtual returns (uint256);
```

### _getMinDelay


```solidity
function _getMinDelay(bytes32 id) internal view virtual returns (bool, uint256);
```

### _getSelector


```solidity
function _getSelector(bytes memory data) internal pure returns (bytes4 selector);
```

### _getPayload


```solidity
function _getPayload(bytes memory data) internal pure returns (bytes memory payload);
```

### initialize


```solidity
function initialize(
    uint256, /* minDelay */
    address[] memory, /* proposers */
    address[] memory, /* executors */
    address /* admin */
)
    public
    virtual
    override;
```

