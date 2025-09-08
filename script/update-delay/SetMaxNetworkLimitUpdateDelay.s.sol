// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/SetMaxNetworkLimitUpdateDelayBase.sol";

contract SetMaxNetworkLimitUpdateDelay is SetMaxNetworkLimitUpdateDelayBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address NETWORK = address(0);
    // Maximum amount of delegation that network is ready to receive
    uint256 SET_MAX_NETWORK_LIMIT_DELAY = 0;
    // Delay for the action to be executed
    uint256 DELAY = 0;
    // Salt for TimelockController operations
    bytes32 SALT = "SetMaxNetworkLimitUpdateDelay";

    constructor() SetMaxNetworkLimitUpdateDelayBase(NETWORK, SET_MAX_NETWORK_LIMIT_DELAY, DELAY, SALT) {}

    /**
     * @notice Schedule a setMaxNetworkLimit through the timelock
     */
    function runS() public {
        runSchedule();
    }

    /**
     * @notice Execute a setMaxNetworkLimit immediately through the timelock
     */
    function runE() public {
        runExecute();
    }

    /**
     * @notice Schedule and execute a setMaxNetworkLimit through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runScheduleAndExecute();
    }
}
