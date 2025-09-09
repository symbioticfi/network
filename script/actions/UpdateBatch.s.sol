// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ITimelockAction} from "./interfaces/ITimelockAction.sol";
import {ActionBase} from "./base/ActionBase.sol";
import {SetMaxNetworkLimitBase} from "./base/SetMaxNetworkLimitBase.sol";
import {SetMiddlewareBase} from "./base/SetMiddlewareBase.sol";
import {SetResolverBase} from "./base/SetResolverBase.sol";
import {UpgradeProxyBase} from "./base/UpgradeProxyBase.sol";

contract UpdateBatch is ActionBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address NETWORK = address(0);
    // Delay for the action to be executed
    uint256 DELAY = 14 days;
    // Salt for TimelockController operations
    bytes32 SALT = "UpdateBatch";

    // Address of the Vault
    address VAULT1 = address(0);
    // Subnetwork Identifier (multiple subnetworks can be used, e.g., to have different resolvers for the same network)
    uint96 SUBNETWORK_IDENTIFIER1 = 0;
    // Maximum amount of delegation that network is ready to receive
    uint256 MAX_NETWORK_LIMIT1 = 0;

    // Address of the Vault
    address VAULT2 = address(0);
    // Subnetwork Identifier (multiple subnetworks can be used, e.g., to have different resolvers for the same network)
    uint96 SUBNETWORK_IDENTIFIER2 = 0;
    // Maximum amount of delegation that network is ready to receive
    uint256 MAX_NETWORK_LIMIT2 = 0;

    // Address of the Middleware
    address MIDDLEWARE = address(0);
    // Address of the Resolver
    address RESOLVER = address(0);
    // Address of the New Implementation
    address NEW_IMPLEMENTATION = address(0);
    // Data to pass to the new implementation after upgrade
    bytes UPGRADE_DATA = new bytes(0);

    // Hints for the Resolver
    bytes HINTS = new bytes(0);

    ITimelockAction[] public actions;
    address[] public targets;
    bytes[] public payloads;

    constructor() {
        // Add all actions needed for the update batch to the array
        actions.push(
            new SetMaxNetworkLimitBase(
                SetMaxNetworkLimitBase.SetMaxNetworkLimitParams({
                    network: NETWORK,
                    vault: VAULT1,
                    subnetworkId: SUBNETWORK_IDENTIFIER1,
                    maxNetworkLimit: MAX_NETWORK_LIMIT1,
                    delay: DELAY,
                    salt: SALT
                })
            )
        );
        actions.push(
            new SetMaxNetworkLimitBase(
                SetMaxNetworkLimitBase.SetMaxNetworkLimitParams({
                    network: NETWORK,
                    vault: VAULT2,
                    subnetworkId: SUBNETWORK_IDENTIFIER2,
                    maxNetworkLimit: MAX_NETWORK_LIMIT2,
                    delay: DELAY,
                    salt: SALT
                })
            )
        );
        actions.push(
            new SetMiddlewareBase(
                SetMiddlewareBase.SetMiddlewareParams({
                    network: NETWORK,
                    middleware: MIDDLEWARE,
                    delay: DELAY,
                    salt: SALT
                })
            )
        );
        actions.push(
            new SetResolverBase(
                SetResolverBase.SetResolverParams({
                    network: NETWORK,
                    vault: VAULT1,
                    identifier: SUBNETWORK_IDENTIFIER1,
                    resolver: RESOLVER,
                    hints: HINTS,
                    delay: DELAY,
                    salt: SALT
                })
            )
        );
        actions.push(
            new UpgradeProxyBase(
                UpgradeProxyBase.UpgradeProxyParams({
                    network: NETWORK,
                    newImplementation: NEW_IMPLEMENTATION,
                    upgradeData: UPGRADE_DATA,
                    delay: DELAY,
                    salt: SALT
                })
            )
        );

        for (uint256 i; i < actions.length; ++i) {
            (address target, bytes memory payload) = actions[i].getTargetAndPayload();
            targets.push(target);
            payloads.push(payload);
        }
    }

    function runS() public {
        callTimelockBatch(
            TimelockBatchParams({
                network: NETWORK,
                isExecutionMode: false,
                targets: targets,
                payloads: payloads,
                delay: DELAY,
                salt: SALT
            })
        );
    }

    function runE() public {
        callTimelockBatch(
            TimelockBatchParams({
                network: NETWORK,
                isExecutionMode: true,
                targets: targets,
                payloads: payloads,
                delay: 0,
                salt: SALT
            })
        );
    }

    function runSE() public {
        runS();
        runE();
    }
}
