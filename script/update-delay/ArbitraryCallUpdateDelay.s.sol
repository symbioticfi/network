// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/ArbitraryCallUpdateDelayBase.sol";

contract ArbitraryCallUpdateDelay is ArbitraryCallUpdateDelayBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address constant NETWORK = 0x0000000000000000000000000000000000000000;
    // Address of the Target to set a delay for (0x0000000000000000000000000000000000000000 means "for any target")
    address constant TARGET = 0x0000000000000000000000000000000000000000;
    // Selector of the Target to set a delay for (0xEEEEEEEE means "for native asset transfers")
    bytes4 constant SELECTOR = 0x00000000;
    // New delay for arbitrary operations
    uint256 constant ARBITRARY_DELAY = 3 days;
    // Delay for the action to be executed
    uint256 constant DELAY = 3 days;

    // Optional

    // Salt for TimelockController operations
    bytes32 constant SALT = "ArbitraryCallUpdateDelay";

    constructor()
        ArbitraryCallUpdateDelayBase(ArbitraryCallUpdateDelayBase.ArbitraryCallUpdateDelayParams({
                network: NETWORK,
                enabled: true,
                target: TARGET,
                selector: SELECTOR,
                arbitraryCallDelay: ARBITRARY_DELAY,
                delay: DELAY,
                salt: SALT
            }))
    {}

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
