// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/UpgradeProxyBase.sol";

contract UpgradeProxy is UpgradeProxyBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address NETWORK = address(0);
    // Address of the new implementation
    address NEW_IMPLEMENTATION = address(0);
    // Data to pass to the new implementation after upgrade
    bytes UPGRADE_DATA = new bytes(0);
    // Delay for the action to be executed
    uint256 DELAY = 14 days;

    // Optional

    // Salt for TimelockController operations
    bytes32 SALT = "UpgradeProxy";

    /**
     * @notice Schedule a network upgrade through the timelock
     */
    function runS() public {
        runSchedule(NETWORK, NEW_IMPLEMENTATION, UPGRADE_DATA, DELAY, SALT);
    }

    /**
     * @notice Execute a network upgrade immediately through the timelock
     */
    function runE() public {
        runExecute(NETWORK, NEW_IMPLEMENTATION, UPGRADE_DATA, SALT);
    }

    /**
     * @notice Schedule and execute a network upgrade through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runScheduleAndExecute(NETWORK, NEW_IMPLEMENTATION, UPGRADE_DATA, SALT);
    }
}
