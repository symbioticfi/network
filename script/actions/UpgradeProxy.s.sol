// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/UpgradeProxyBase.sol";

contract UpgradeProxy is UpgradeProxyBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address constant NETWORK = 0x0000000000000000000000000000000000000000;
    // Address of the new implementation
    address constant NEW_IMPLEMENTATION = 0x0000000000000000000000000000000000000000;
    // Data to pass to the new implementation after upgrade
    bytes constant UPGRADE_DATA = hex"";
    // Delay for the action to be executed
    uint256 constant DELAY = 14 days;

    // Optional

    // Salt for TimelockController operations
    bytes32 constant SALT = "UpgradeProxy";

    constructor()
        UpgradeProxyBase(UpgradeProxyBase.UpgradeProxyParams({
                network: NETWORK,
                newImplementation: NEW_IMPLEMENTATION,
                upgradeData: UPGRADE_DATA,
                delay: DELAY,
                salt: SALT
            }))
    {}

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
