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
            new SetMaxNetworkLimitBase(NETWORK, VAULT1, SUBNETWORK_IDENTIFIER1, MAX_NETWORK_LIMIT1, DELAY, SALT)
        );
        actions.push(
            new SetMaxNetworkLimitBase(NETWORK, VAULT2, SUBNETWORK_IDENTIFIER2, MAX_NETWORK_LIMIT2, DELAY, SALT)
        );
        actions.push(new SetMiddlewareBase(NETWORK, MIDDLEWARE, DELAY, SALT));
        actions.push(new SetResolverBase(NETWORK, VAULT1, SUBNETWORK_IDENTIFIER1, RESOLVER, HINTS, DELAY, SALT));
        actions.push(new UpgradeProxyBase(NETWORK, NEW_IMPLEMENTATION, UPGRADE_DATA, DELAY, SALT));

        for (uint256 i = 0; i < actions.length; ++i) {
            (address target, bytes memory payload) = actions[i].getTargetAndPayload();
            targets.push(target);
            payloads.push(payload);
        }
    }

    function runS() public {
        TimelockBatchParams memory params = TimelockBatchParams({
            network: NETWORK,
            isExecutionMode: false,
            targets: targets,
            payloads: payloads,
            delay: DELAY,
            salt: SALT
        });

        callTimelockBatch(params);
    }

    function runE() public {
        TimelockBatchParams memory params = TimelockBatchParams({
            network: NETWORK,
            isExecutionMode: true,
            targets: targets,
            payloads: payloads,
            delay: 0,
            salt: SALT
        });

        callTimelockBatch(params);
    }
}
