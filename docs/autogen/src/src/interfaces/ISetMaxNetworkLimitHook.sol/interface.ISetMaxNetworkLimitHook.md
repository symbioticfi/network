# ISetMaxNetworkLimitHook
[Git Source](https://github.com/symbioticfi/network/blob/b4466b71ea0c226fb5c856f8be51e34e294d6ef3/src/interfaces/ISetMaxNetworkLimitHook.sol)

Interface for the setMaxNetworkLimit hook.


## Functions
### setMaxNetworkLimit

Sets the maximum network limit for a delegator.

The caller must be the network's middleware.


```solidity
function setMaxNetworkLimit(address delegator, uint96 subnetworkId, uint256 maxNetworkLimit) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`delegator`|`address`|The address of the delegator.|
|`subnetworkId`|`uint96`|The identifier of the subnetwork.|
|`maxNetworkLimit`|`uint256`|The maximum network limit.|


