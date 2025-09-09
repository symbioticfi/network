// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/SetMiddlewareBase.sol";

contract SetMiddleware is SetMiddlewareBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address NETWORK = 0x0000000000000000000000000000000000000000;
    // Address of the Middleware
    address MIDDLEWARE = 0x0000000000000000000000000000000000000000;
    // Delay for the action to be executed
    uint256 DELAY = 14 days;

    // Optional

    // Salt for TimelockController operations
    bytes32 SALT = "SetMiddleware";

    constructor() SetMiddlewareBase(NETWORK, MIDDLEWARE, DELAY, SALT) {}

    /**
     * @notice Schedule a setMiddleware through the timelock
     */
    function runS() public {
        runSchedule();
    }

    /**
     * @notice Execute a setMiddleware immediately through the timelock
     */
    function runE() public {
        runExecute();
    }

    /**
     * @notice Schedule and execute a setMiddleware through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runScheduleAndExecute();
    }
}
