// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/SetMiddlewareBase.sol";

contract SetMiddleware is SetMiddlewareBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING
    address NETWORK = address(0);
    address MIDDLEWARE = address(0);
    uint256 DELAY = 0;

    // Optional
    bytes32 SALT = "SetMiddleware";

    /**
     * @notice Schedule a setMiddleware through the timelock
     */
    function runS() public {
        runSchedule(NETWORK, MIDDLEWARE, DELAY, SALT);
    }

    /**
     * @notice Execute a setMiddleware immediately through the timelock
     */
    function runE() public {
        runExecute(NETWORK, MIDDLEWARE, SALT);
    }

    /**
     * @notice Schedule and execute a setMiddleware through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runScheduleAndExecute(NETWORK, MIDDLEWARE, SALT);
    }
}
