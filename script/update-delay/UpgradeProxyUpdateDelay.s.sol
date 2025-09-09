// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/UpgradeProxyUpdateDelayBase.sol";

contract UpgradeProxyUpdateDelay is UpgradeProxyUpdateDelayBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address NETWORK = address(0);
    // New delay for upgradeProxy operations
    uint256 UPGRADE_PROXY_DELAY = 0;
    // Delay for the action to be executed
    uint256 DELAY = 0;

    // Optional

    // Salt for TimelockController operations
    bytes32 SALT = "UpgradeProxyUpdateDelay";

    constructor() UpgradeProxyUpdateDelayBase(NETWORK, UPGRADE_PROXY_DELAY, DELAY, SALT) {}

    /**
     * @notice Schedule an update of the upgradeProxy delay through the timelock
     */
    function runS() public {
        runSchedule();
    }

    /**
     * @notice Execute an update of the upgradeProxy delay through the timelock
     */
    function runE() public {
        runExecute();
    }

    /**
     * @notice Schedule and execute an update of the upgradeProxy delay through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runScheduleAndExecute();
    }
}
