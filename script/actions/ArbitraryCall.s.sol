// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/ArbitraryCallBase.sol";

contract ArbitraryCall is ArbitraryCallBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address NETWORK = 0x0000000000000000000000000000000000000000;
    // Address of the Target
    address TARGET = 0x0000000000000000000000000000000000000000;
    // Data to pass to the Target
    bytes DATA = new bytes(0);
    // Delay for the action to be executed
    uint256 DELAY = 3 days;

    // Optional

    // Salt for TimelockController operations
    bytes32 SALT = "ArbitraryCall";

    /**
     * @notice Schedule an arbitrary function call through the timelock
     */
    function runS() public {
        runSchedule(NETWORK, TARGET, DATA, DELAY, SALT);
    }

    /**
     * @notice Execute an arbitrary function call immediately through the timelock
     */
    function runE() public {
        runExecute(NETWORK, TARGET, DATA, SALT);
    }

    /**
     * @notice Schedule and execute an arbitrary function call through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runScheduleAndExecute(NETWORK, TARGET, DATA, SALT);
    }
}
