// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/SetMiddlewareUpdateDelayBase.sol";

contract SetMiddlewareUpdateDelay is SetMiddlewareUpdateDelayBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address constant NETWORK = 0x0000000000000000000000000000000000000000;
    // New delay for setMiddleware operations
    uint256 constant SET_MIDDLEWARE_DELAY = 14 days;
    // Delay for the action to be executed
    uint256 constant DELAY = 14 days;

    // Optional

    // Salt for TimelockController operations
    bytes32 constant SALT = "SetMiddlewareUpdateDelay";

    constructor()
        SetMiddlewareUpdateDelayBase(
            SetMiddlewareUpdateDelayBase.SetMiddlewareUpdateDelayParams({
                network: NETWORK,
                setMiddlewareDelay: SET_MIDDLEWARE_DELAY,
                delay: DELAY,
                salt: SALT
            })
        )
    {}

    /**
     * @notice Schedule an update of the setMiddleware delay through the timelock
     */
    function runS() public {
        runSchedule();
    }

    /**
     * @notice Execute an update of the setMiddleware delay through the timelock
     */
    function runE() public {
        runExecute();
    }

    /**
     * @notice Schedule and execute an update of the setMiddleware delay through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runScheduleAndExecute();
    }
}
