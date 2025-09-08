pragma solidity ^0.8.25;

import {ITimelockAction} from "../actions/interfaces/ITimelockAction.sol";
import {ActionBase} from "../actions/base/ActionBase.sol";
import {SetMiddlewareUpdateDelayBase} from "./base/SetMiddlewareUpdateDelayBase.sol";
import {UpgradeProxyUpdateDelayBase} from "./base/UpgradeProxyUpdateDelayBase.sol";

contract ColdActionsUpdateDelay is ActionBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address NETWORK = address(0);
    // Cold Actions Delay
    uint256 COLD_ACTIONS_DELAY = 14 days;
    // Delay for the action to be executed
    uint256 DELAY = 0;
    // Salt for TimelockController operations
    bytes32 SALT = "ColdActionsUpdateDelay";

    ITimelockAction[] public actions;
    address[] public targets;
    bytes[] public payloads;

    constructor() {
        actions.push(new SetMiddlewareUpdateDelayBase(NETWORK, COLD_ACTIONS_DELAY, DELAY, SALT));
        actions.push(new UpgradeProxyUpdateDelayBase(NETWORK, COLD_ACTIONS_DELAY, DELAY, SALT));

        for (uint256 i; i < actions.length; ++i) {
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
