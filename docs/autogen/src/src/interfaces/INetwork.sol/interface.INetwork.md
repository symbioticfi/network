# INetwork
[Git Source](https://github.com/symbioticfi/network/blob/13e391e8622daa693350c256ee1d14b7e04abaf2/src/interfaces/INetwork.sol)

**Inherits:**
[ISetMaxNetworkLimitHook](/Users/andreikorokhov/symbiotic/network/docs/autogen/src/src/interfaces/ISetMaxNetworkLimitHook.sol/interface.ISetMaxNetworkLimitHook.md)

Interface for the Network contract.


## Functions
### NAME_UPDATE_ROLE

Returns the role for updating the name.


```solidity
function NAME_UPDATE_ROLE() external view returns (bytes32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|The role for updating the name.|


### METADATA_URI_UPDATE_ROLE

Returns the role for updating the metadata URI.


```solidity
function METADATA_URI_UPDATE_ROLE() external view returns (bytes32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|The role for updating the metadata URI.|


### NETWORK_REGISTRY

Returns the address of the network registry.


```solidity
function NETWORK_REGISTRY() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The address of the network registry.|


### NETWORK_MIDDLEWARE_SERVICE

Returns the address of the network middleware service.


```solidity
function NETWORK_MIDDLEWARE_SERVICE() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The address of the network middleware service.|


### getMinDelay

Returns the minimum delay for a given target and calldata.


```solidity
function getMinDelay(address target, bytes memory data) external view returns (uint256);
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
function name() external view returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|The name of the network.|


### metadataURI

Returns the metadata URI of the network.


```solidity
function metadataURI() external view returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|The metadata URI of the network.|


### initialize

Initializes the network.


```solidity
function initialize(NetworkInitParams memory networkInitParams) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`networkInitParams`|`NetworkInitParams`|The parameters for the initialization of the network.|


### updateDelay

Updates the delay for a given target and selector.

Can be reached only via scheduled calls.


```solidity
function updateDelay(address target, bytes4 selector, bool enabled, uint256 newDelay) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`target`|`address`|The target address the delay is for.|
|`selector`|`bytes4`|The function selector the delay is for.|
|`enabled`|`bool`|If to enable the delay.|
|`newDelay`|`uint256`|The new delay value.|


### updateName

Updates the name of the network.

The caller must have the name update role.


```solidity
function updateName(string memory name) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`name`|`string`|The new name.|


### updateMetadataURI

Updates the metadata URI of the network.

The caller must have the metadata URI update role.


```solidity
function updateMetadataURI(string memory metadataURI) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`metadataURI`|`string`|The new metadata URI.|


## Events
### MinDelayChange
Emitted when the minimum delay is changed.


```solidity
event MinDelayChange(
    address indexed target,
    bytes4 indexed selector,
    bool oldEnabledStatus,
    uint256 oldDelay,
    bool newEnabledStatus,
    uint256 newDelay
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`target`|`address`|The target address the delay is for.|
|`selector`|`bytes4`|The function selector the delay is for.|
|`oldEnabledStatus`|`bool`|The old enabled status.|
|`oldDelay`|`uint256`|The old delay value.|
|`newEnabledStatus`|`bool`|The new enabled status.|
|`newDelay`|`uint256`|The new delay value.|

### NameSet
Emitted when the name is set.


```solidity
event NameSet(string name);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`name`|`string`|The name of the network.|

### MetadataURISet
Emitted when the metadata URI is set.


```solidity
event MetadataURISet(string metadataURI);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`metadataURI`|`string`|The metadata URI of the network.|

## Errors
### InvalidDataLength
Reverts when the calldata length is invalid.


```solidity
error InvalidDataLength();
```

### InvalidNewDelay
Reverts when the new delay is non-zero but disabled.


```solidity
error InvalidNewDelay();
```

### InvalidTargetAndSelector
Reverts when the "recursive" delay update is attempted.


```solidity
error InvalidTargetAndSelector();
```

### NotMiddleware
Reverts when the caller is not the network's middleware.


```solidity
error NotMiddleware();
```

## Structs
### NetworkStorage
The storage of the Network contract.

**Note:**
storage-location: erc7201:symbiotic.storage.Network


```solidity
struct NetworkStorage {
    mapping(bytes32 id => uint256 minDelay) _minDelays;
    mapping(bytes32 => bool) _isMinDelayEnabled;
    string _name;
    string _metadataURI;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`_minDelays`|`mapping(bytes32 id => uint256 minDelay)`|The mapping from the id (derived from the target and the selector) to the minimum delay.|
|`_isMinDelayEnabled`|`mapping(bytes32 => bool)`|The mapping from the id (derived from the target and the selector) to the minimum delay enabled status.|
|`_name`|`string`|The name of the network.|
|`_metadataURI`|`string`|The metadata URI of the network.|

### NetworkInitParams
The parameters for the initialization of the Network contract.


```solidity
struct NetworkInitParams {
    uint256 globalMinDelay;
    DelayParams[] delayParams;
    address[] proposers;
    address[] executors;
    string name;
    string metadataURI;
    address defaultAdminRoleHolder;
    address nameUpdateRoleHolder;
    address metadataURIUpdateRoleHolder;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`globalMinDelay`|`uint256`|The global minimum delay.|
|`delayParams`|`DelayParams[]`|The delays.|
|`proposers`|`address[]`|The proposers.|
|`executors`|`address[]`|The executors.|
|`name`|`string`|The name of the network.|
|`metadataURI`|`string`|The metadata URI of the network.|
|`defaultAdminRoleHolder`|`address`|The address of the default admin role holder.|
|`nameUpdateRoleHolder`|`address`|The address of the name update role holder.|
|`metadataURIUpdateRoleHolder`|`address`|The address of the metadata URI update role holder.|

### DelayParams
The delay parameters.


```solidity
struct DelayParams {
    address target;
    bytes4 selector;
    uint256 delay;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`target`|`address`|The target address the delay is for.|
|`selector`|`bytes4`|The function selector the delay is for.|
|`delay`|`uint256`|The delay value.|

