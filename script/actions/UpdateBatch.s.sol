// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.25;

// import {ITimelockAction} from "./interfaces/ITimelockAction.sol";
// import {ActionBase} from "./base/ActionBase.sol";
// import {SetMaxNetworkLimitBase} from "./base/SetMaxNetworkLimitBase.sol";
// import {SetMiddlewareBase} from "./base/SetMiddlewareBase.sol";
// import {SetResolverBase} from "./base/SetResolverBase.sol";
// import {UpgradeProxyBase} from "./base/UpgradeProxyBase.sol";

// contract UpdateBatch is ActionBase {
//     // Configuration constants - UPDATE THESE BEFORE EXECUTING

//     // Address of the Network
//     address constant NETWORK = 0x0000000000000000000000000000000000000000;
//     // Delay for the action to be executed
//     uint256 constant DELAY = 14 days;
//     // Salt for TimelockController operations
//     bytes32 constant SALT = "UpdateBatch";

//     // Address of the Vault
//     address constant VAULT1 = 0x0000000000000000000000000000000000000000;
//     // Subnetwork Identifier (multiple subnetworks can be used, e.g., to have different resolvers for the same network)
//     uint96 constant SUBNETWORK_IDENTIFIER1 = 0;
//     // Maximum amount of delegation that network is ready to receive
//     uint256 constant MAX_NETWORK_LIMIT1 = 0;

//     // Address of the Vault
//     address constant VAULT2 = 0x0000000000000000000000000000000000000000;
//     // Subnetwork Identifier (multiple subnetworks can be used, e.g., to have different resolvers for the same network)
//     uint96 constant SUBNETWORK_IDENTIFIER2 = 0;
//     // Maximum amount of delegation that network is ready to receive
//     uint256 constant MAX_NETWORK_LIMIT2 = 0;

//     // Address of the Middleware
//     address constant MIDDLEWARE = 0x0000000000000000000000000000000000000000;
//     // Address of the Resolver
//     address constant RESOLVER = 0x0000000000000000000000000000000000000000;
//     // Address of the New Implementation
//     address constant NEW_IMPLEMENTATION = 0x0000000000000000000000000000000000000000;
//     // Data to pass to the new implementation after upgrade
//     bytes constant UPGRADE_DATA = hex"";

//     // Hints for the Resolver
//     bytes constant HINTS = hex"";

//     ITimelockAction[] public actions;

//     constructor() {
//         // Add all actions needed for the update batch to the array
//         actions.push(
//             new SetMaxNetworkLimitBase(
//                 SetMaxNetworkLimitBase.SetMaxNetworkLimitParams({
//                     network: NETWORK,
//                     vault: VAULT1,
//                     subnetworkId: SUBNETWORK_IDENTIFIER1,
//                     maxNetworkLimit: MAX_NETWORK_LIMIT1,
//                     delay: DELAY,
//                     salt: SALT
//                 })
//             )
//         );
//         actions.push(
//             new SetMaxNetworkLimitBase(
//                 SetMaxNetworkLimitBase.SetMaxNetworkLimitParams({
//                     network: NETWORK,
//                     vault: VAULT2,
//                     subnetworkId: SUBNETWORK_IDENTIFIER2,
//                     maxNetworkLimit: MAX_NETWORK_LIMIT2,
//                     delay: DELAY,
//                     salt: SALT
//                 })
//             )
//         );
//         actions.push(
//             new SetMiddlewareBase(
//                 SetMiddlewareBase.SetMiddlewareParams({
//                     network: NETWORK,
//                     middleware: MIDDLEWARE,
//                     delay: DELAY,
//                     salt: SALT
//                 })
//             )
//         );
//         actions.push(
//             new SetResolverBase(
//                 SetResolverBase.SetResolverParams({
//                     network: NETWORK,
//                     vault: VAULT1,
//                     identifier: SUBNETWORK_IDENTIFIER1,
//                     resolver: RESOLVER,
//                     hints: HINTS,
//                     delay: DELAY,
//                     salt: SALT
//                 })
//             )
//         );
//         actions.push(
//             new UpgradeProxyBase(
//                 UpgradeProxyBase.UpgradeProxyParams({
//                     network: NETWORK,
//                     newImplementation: NEW_IMPLEMENTATION,
//                     upgradeData: UPGRADE_DATA,
//                     delay: DELAY,
//                     salt: SALT
//                 })
//             )
//         );
//     }

//     function runS() public {
//         callTimelockBatch(
//             TimelockBatchParams({network: NETWORK, isExecutionMode: false, actions: actions, delay: DELAY, salt: SALT})
//         );
//     }

//     function runE() public {
//         callTimelockBatch(
//             TimelockBatchParams({network: NETWORK, isExecutionMode: true, actions: actions, delay: 0, salt: SALT})
//         );
//     }

//     function runSE() public {
//         runS();
//         runE();
//     }
// }
