# ISetMaxNetworkLimitHook
[Git Source](https://github.com/symbioticfi/network/blob/6baebf59702197b6a66a690e6780ea5a5f42de5e/src/interfaces/ISetMaxNetworkLimitHook.sol)

**Title:**
ISetMaxNetworkLimitHook

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


