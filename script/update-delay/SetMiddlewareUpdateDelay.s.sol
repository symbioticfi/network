// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/SetMiddlewareUpdateDelayBase.sol";

contract SetMiddlewareUpdateDelay is SetMiddlewareUpdateDelayBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address NETWORK = address(0);
    // Delay for setMiddleware operations
    uint256 SET_MIDDLEWARE_DELAY = 0;
    // Delay for the action to be executed
    uint256 DELAY = 0;
    // Salt for TimelockController operations
    bytes32 SALT = "SetMiddlewareUpdateDelay";

    constructor() SetMiddlewareUpdateDelayBase(NETWORK, SET_MIDDLEWARE_DELAY, DELAY, SALT) {}

    /**
     * @notice Schedule a setMiddlewareUpdateDelay through the timelock
     */
    function runS() public {
        runSchedule();
    }

    /**
     * @notice Execute a setMiddlewareUpdateDelay immediately through the timelock
     */
    function runE() public {
        runExecute();
    }

    /**
     * @notice Schedule and execute a setMiddlewareUpdateDelay through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runScheduleAndExecute();
    }
}
