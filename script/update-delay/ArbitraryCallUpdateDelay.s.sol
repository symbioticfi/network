// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/ArbitraryCallUpdateDelayBase.sol";

contract ArbitraryCallUpdateDelay is ArbitraryCallUpdateDelayBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address NETWORK = address(0);
    // Address of the Target to set a delay for (0x0000000000000000000000000000000000000000 means "for any target")
    address TARGET = address(0);
    // Selector of the Target to set a delay for (0xEEEEEEEE means "for native asset transfers")
    bytes4 SELECTOR = bytes4(0);
    // New delay for arbitrary operations
    uint256 ARBITRARY_DELAY = 0;
    // Delay for the action to be executed
    uint256 DELAY = 0;

    // Optional

    // Salt for TimelockController operations
    bytes32 SALT = "ArbitraryCallUpdateDelay";

    constructor() ArbitraryCallUpdateDelayBase(NETWORK, TARGET, SELECTOR, ARBITRARY_DELAY, DELAY, SALT) {}

    /**
     * @notice Schedule an update of the arbitrary call delay through the timelock
     */
    function runS() public {
        runSchedule();
    }

    /**
     * @notice Execute an update of the arbitrary call delay through the timelock
     */
    function runE() public {
        runExecute();
    }

    /**
     * @notice Schedule and execute an update of the arbitrary call delay through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runScheduleAndExecute();
    }
}
