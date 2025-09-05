// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/UpgradeNetworkBase.sol";

contract UpgradeNetwork is UpgradeNetworkBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING
    address NETWORK = address(0);
    address NEW_IMPLEMENTATION = address(0);
    bytes UPGRADE_DATA = new bytes(0);

    // Optional
    uint256 DELAY = 0;
    bytes32 SALT = "UpgradeNetwork";

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
