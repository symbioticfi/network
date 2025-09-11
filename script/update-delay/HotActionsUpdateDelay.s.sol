// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ITimelockAction} from "../actions/interfaces/ITimelockAction.sol";
import {ActionBase} from "../actions/base/ActionBase.sol";
import {SetMaxNetworkLimitUpdateDelayBase} from "./base/SetMaxNetworkLimitUpdateDelayBase.sol";
import {SetResolverUpdateDelayBase} from "./base/SetResolverUpdateDelayBase.sol";

contract HotActionsUpdateDelay is ActionBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address constant NETWORK = 0x0000000000000000000000000000000000000000;
    // New delay for hot actions
    uint256 constant HOT_ACTIONS_DELAY = 0;
    // Delay for the action to be executed
    uint256 constant DELAY = 0;

    // Optional

    // Salt for TimelockController operations
    bytes32 constant SALT = "HotActionsUpdateDelay";

    ITimelockAction[] public actions;

    constructor() {
        actions.push(
            new SetMaxNetworkLimitUpdateDelayBase(
                SetMaxNetworkLimitUpdateDelayBase.SetMaxNetworkLimitUpdateDelayParams({
                    network: NETWORK,
                    setMaxNetworkLimitDelay: HOT_ACTIONS_DELAY,
                    delay: DELAY,
                    salt: SALT
                })
            )
        );
        actions.push(
            new SetResolverUpdateDelayBase(
                SetResolverUpdateDelayBase.SetResolverUpdateDelayParams({
                    network: NETWORK,
                    setResolverDelay: HOT_ACTIONS_DELAY,
                    delay: DELAY,
                    salt: SALT
                })
            )
        );
    }

    /**
     * @notice Schedule an update of the hot actions delay through the timelock
     */
    function runS() public {
        callTimelockBatch(
            TimelockBatchParams({network: NETWORK, isExecutionMode: false, actions: actions, delay: DELAY, salt: SALT})
        );
    }

    /**
     * @notice Execute an update of the hot actions delay through the timelock
     */
    function runE() public {
        callTimelockBatch(
            TimelockBatchParams({network: NETWORK, isExecutionMode: true, actions: actions, delay: 0, salt: SALT})
        );
    }

    /**
     * @notice Schedule and execute an update of the hot actions delay through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runS();
        runE();
    }
}
