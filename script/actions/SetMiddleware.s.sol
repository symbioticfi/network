// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/SetMiddlewareBase.sol";
import {ITimelockAction} from "./interfaces/ITimelockAction.sol";

contract SetMiddleware is SetMiddlewareBase, ITimelockAction {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address NETWORK = address(0);
    // Address of the Middleware
    address MIDDLEWARE = address(0);
    // Delay for the action to be executed
    uint256 DELAY = 14 days;

    // Optional

    // Salt for TimelockController operations
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

    /**
     * @notice Get the target and payload of the setMiddleware
     */
    function getTargetAndPayload() public view returns (address, bytes memory) {
        return getTargetAndPayload(MIDDLEWARE);
    }
}
