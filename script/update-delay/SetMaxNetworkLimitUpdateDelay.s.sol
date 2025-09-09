// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/SetMaxNetworkLimitUpdateDelayBase.sol";

contract SetMaxNetworkLimitUpdateDelay is SetMaxNetworkLimitUpdateDelayBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address NETWORK = address(0);
    // New delay for setMaxNetworkLimit operations
    uint256 SET_MAX_NETWORK_LIMIT_DELAY = 0;
    // Delay for the action to be executed
    uint256 DELAY = 0;

    // Optional

    // Salt for TimelockController operations
    bytes32 SALT = "SetMaxNetworkLimitUpdateDelay";

    constructor()
        SetMaxNetworkLimitUpdateDelayBase(
            SetMaxNetworkLimitUpdateDelayBase.SetMaxNetworkLimitUpdateDelayParams({
                network: NETWORK,
                setMaxNetworkLimitDelay: SET_MAX_NETWORK_LIMIT_DELAY,
                delay: DELAY,
                salt: SALT
            })
        )
    {}

    /**
     * @notice Schedule an update of the setMaxNetworkLimit delay through the timelock
     */
    function runS() public {
        runSchedule();
    }

    /**
     * @notice Execute an update of the setMaxNetworkLimit delay through the timelock
     */
    function runE() public {
        runExecute();
    }

    /**
     * @notice Schedule and execute an update of the setMaxNetworkLimit delay through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runScheduleAndExecute();
    }
}
