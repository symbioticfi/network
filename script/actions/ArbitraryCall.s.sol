// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/ArbitraryCallBase.sol";

contract ArbitraryCall is ArbitraryCallBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address constant NETWORK = 0x0000000000000000000000000000000000000000;
    // Address of the Target
    address constant TARGET = 0x0000000000000000000000000000000000000000;
    // Data to pass to the Target
    bytes constant DATA = hex"";
    // Delay for the action to be executed
    uint256 constant DELAY = 3 days;

    // Optional

    // Salt for TimelockController operations
    bytes32 constant SALT = "ArbitraryCall";

    constructor()
        ArbitraryCallBase(ArbitraryCallBase.ArbitraryCallParams({
                network: NETWORK, target: TARGET, data: DATA, delay: DELAY, salt: SALT
            }))
    {}

    /**
     * @notice Schedule an arbitrary function call through the timelock
     */
    function runS() public {
        runSchedule();
    }

    /**
     * @notice Execute an arbitrary function call immediately through the timelock
     */
    function runE() public {
        runExecute();
    }

    /**
     * @notice Schedule and execute an arbitrary function call through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runScheduleAndExecute();
    }
}
