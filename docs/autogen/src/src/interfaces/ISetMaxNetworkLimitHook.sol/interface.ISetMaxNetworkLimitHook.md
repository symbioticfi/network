# ISetMaxNetworkLimitHook
[Git Source](https://github.com/symbioticfi/network/blob/1a314887f73072e0142044a67db9f47cd58d670c/src/interfaces/ISetMaxNetworkLimitHook.sol)


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


