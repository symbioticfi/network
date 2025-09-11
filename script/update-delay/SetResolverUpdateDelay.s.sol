// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/SetResolverUpdateDelayBase.sol";

contract SetResolverUpdateDelay is SetResolverUpdateDelayBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address constant NETWORK = 0x0000000000000000000000000000000000000000;
    // New delay for setResolver operations
    uint256 constant SET_RESOLVER_DELAY = 0;
    // Delay for the action to be executed
    uint256 constant DELAY = 0;

    // Optional

    // Salt for TimelockController operations
    bytes32 constant SALT = "SetResolverUpdateDelay";

    constructor()
        SetResolverUpdateDelayBase(
            SetResolverUpdateDelayBase.SetResolverUpdateDelayParams({
                network: NETWORK,
                setResolverDelay: SET_RESOLVER_DELAY,
                delay: DELAY,
                salt: SALT
            })
        )
    {}

    /**
     * @notice Schedule an update of the setResolver delay through the timelock
     */
    function runS() public {
        runSchedule();
    }

    /**
     * @notice Execute an update of the setResolver delay through the timelock
     */
    function runE() public {
        runExecute();
    }

    /**
     * @notice Schedule and execute an update of the setResolver delay through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runScheduleAndExecute();
    }
}
