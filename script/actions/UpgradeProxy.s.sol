// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/UpgradeProxyBase.sol";

contract UpgradeProxy is UpgradeProxyBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address NETWORK = 0x0000000000000000000000000000000000000000;
    // Address of the new implementation
    address NEW_IMPLEMENTATION = 0x0000000000000000000000000000000000000000;
    // Data to pass to the new implementation after upgrade
    bytes UPGRADE_DATA = new bytes(0);
    // Delay for the action to be executed
    uint256 DELAY = 14 days;

    // Optional

    // Salt for TimelockController operations
    bytes32 SALT = "UpgradeProxy";

    constructor() UpgradeProxyBase(NETWORK, NEW_IMPLEMENTATION, UPGRADE_DATA, DELAY, SALT) {}

    /**
     * @notice Schedule a network upgrade through the timelock
     */
    function runS() public {
        runSchedule();
    }

    /**
     * @notice Execute a network upgrade immediately through the timelock
     */
    function runE() public {
        runExecute();
    }

    /**
     * @notice Schedule and execute a network upgrade through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runScheduleAndExecute();
    }
}
