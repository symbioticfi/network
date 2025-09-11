// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ITimelockAction} from "../actions/interfaces/ITimelockAction.sol";
import {ActionBase} from "../actions/base/ActionBase.sol";
import {SetMiddlewareUpdateDelayBase} from "./base/SetMiddlewareUpdateDelayBase.sol";
import {UpgradeProxyUpdateDelayBase} from "./base/UpgradeProxyUpdateDelayBase.sol";

contract ColdActionsUpdateDelay is ActionBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address constant NETWORK = 0x0000000000000000000000000000000000000000;
    // New delay for cold actions
    uint256 constant COLD_ACTIONS_DELAY = 14 days;
    // Delay for the action to be executed
    uint256 constant DELAY = 14 days;

    // Optional

    // Salt for TimelockController operations
    bytes32 constant SALT = "ColdActionsUpdateDelay";

    ITimelockAction[] public actions;

    constructor() {
        actions.push(
            new SetMiddlewareUpdateDelayBase(
                SetMiddlewareUpdateDelayBase.SetMiddlewareUpdateDelayParams({
                    network: NETWORK,
                    setMiddlewareDelay: COLD_ACTIONS_DELAY,
                    delay: DELAY,
                    salt: SALT
                })
            )
        );
        actions.push(
            new UpgradeProxyUpdateDelayBase(
                UpgradeProxyUpdateDelayBase.UpgradeProxyUpdateDelayParams({
                    network: NETWORK,
                    upgradeProxyDelay: COLD_ACTIONS_DELAY,
                    delay: DELAY,
                    salt: SALT
                })
            )
        );
    }

    /**
     * @notice Schedule an update of the cold actions delay through the timelock
     */
    function runS() public {
        callTimelockBatch(
            TimelockBatchParams({network: NETWORK, isExecutionMode: false, actions: actions, delay: DELAY, salt: SALT})
        );
    }

    /**
     * @notice Execute an update of the cold actions delay through the timelock
     */
    function runE() public {
        callTimelockBatch(
            TimelockBatchParams({network: NETWORK, isExecutionMode: true, actions: actions, delay: 0, salt: SALT})
        );
    }

    /**
     * @notice Schedule and execute an update of the cold actions delay through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runS();
        runE();
    }
}
