pragma solidity ^0.8.25;

import {ITimelockAction} from "./interfaces/ITimelockAction.sol";
import {ActionBase} from "./base/ActionBase.sol";
import {SetMaxNetworkLimit} from "./SetMaxNetworkLimit.s.sol";
import {SetMiddleware} from "./SetMiddleware.s.sol";
import {SetResolver} from "./SetResolver.s.sol";
import {UpgradeProxy} from "./UpgradeProxy.s.sol";

contract UpdateBatch is ActionBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address NETWORK = address(0);
    // Delay for the action to be executed
    uint256 DELAY = 14 days;
    // Salt for TimelockController operations
    bytes32 SALT = "UpdateBatch";

    ITimelockAction[] public actions;
    address[] public targets;
    bytes[] public payloads;

    constructor() {
        // Add all actions needed for the update batch to the array
        actions.push(new SetMaxNetworkLimit());
        actions.push(new SetMiddleware());
        actions.push(new SetResolver());
        actions.push(new UpgradeProxy());

        for (uint256 i = 0; i < actions.length; i++) {
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
