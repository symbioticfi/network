// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/DefaultUpdateDelayBase.sol";

contract DefaultUpdateDelay is DefaultUpdateDelayBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address constant NETWORK = 0x0000000000000000000000000000000000000000;
    // New default delay
    uint256 constant GLOBAL_MIN_DELAY = 3 days;
    // Delay for the action to be executed
    uint256 constant DELAY = 3 days;

    // Optional

    // Salt for TimelockController operations
    bytes32 SALT = "DefaultUpdateDelay";

    constructor()
        DefaultUpdateDelayBase(
            DefaultUpdateDelayBase.DefaultUpdateDelayParams({
                network: NETWORK,
                globalMinDelay: GLOBAL_MIN_DELAY,
                delay: DELAY,
                salt: SALT
            })
        )
    {}

    /**
     * @notice Schedule an update of the default delay through the timelock
     */
    function runS() public {
        runSchedule();
    }

    /**
     * @notice Execute an update of the default delay through the timelock
     */
    function runE() public {
        runExecute();
    }

    /**
     * @notice Schedule and execute an update of the default delay through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runScheduleAndExecute();
    }
}
