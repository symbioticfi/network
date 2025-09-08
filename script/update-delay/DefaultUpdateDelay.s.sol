// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/DefaultUpdateDelayBase.sol";

contract DefaultUpdateDelay is DefaultUpdateDelayBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address NETWORK = address(0);
    // Global minimum delay for all operations
    uint256 GLOBAL_MIN_DELAY = 0;
    // Delay for the action to be executed
    uint256 DELAY = 0;
    // Salt for TimelockController operations
    bytes32 SALT = "DefaultUpdateDelay";

    constructor() DefaultUpdateDelayBase(NETWORK, GLOBAL_MIN_DELAY, DELAY, SALT) {}

    /**
     * @notice Schedule a globalMinDelayUpdateDelay through the timelock
     */
    function runS() public {
        runSchedule();
    }

    /**
     * @notice Execute a globalMinDelayUpdateDelay immediately through the timelock
     */
    function runE() public {
        runExecute();
    }

    /**
     * @notice Schedule and execute a globalMinDelayUpdateDelay through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runScheduleAndExecute();
    }
}
