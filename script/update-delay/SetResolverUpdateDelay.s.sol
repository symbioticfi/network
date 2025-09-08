// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/SetResolverUpdateDelayBase.sol";

contract SetResolverUpdateDelay is SetResolverUpdateDelayBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address NETWORK = address(0);
    // Delay for setResolver operations
    uint256 SET_RESOLVER_DELAY = 0;
    // Delay for the action to be executed
    uint256 DELAY = 0;
    // Salt for TimelockController operations
    bytes32 SALT = "SetResolverUpdateDelay";

    constructor() SetResolverUpdateDelayBase(NETWORK, SET_RESOLVER_DELAY, DELAY, SALT) {}

    /**
     * @notice Schedule a setResolverUpdateDelay through the timelock
     */
    function runS() public {
        runSchedule();
    }

    /**
     * @notice Execute a setResolverUpdateDelay immediately through the timelock
     */
    function runE() public {
        runExecute();
    }

    /**
     * @notice Schedule and execute a setResolverUpdateDelay through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runScheduleAndExecute();
    }
}
