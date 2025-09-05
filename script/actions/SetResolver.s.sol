// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/SetResolverBase.sol";

contract SetResolver is SetResolverBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address NETWORK = address(0);
    // Address of the Vault
    address VAULT = address(0);
    // Address of the Resolver
    address RESOLVER = address(0);
    // Delay for the action to be executed
    uint256 DELAY = 0;

    // Optional

    // Subnetwork Identifier (multiple subnetworks can be used, e.g., to have different resolvers for the same network)
    uint96 SUBNETWORK_IDENTIFIER = 0;
    // Hints for the Resolver
    bytes HINTS = new bytes(0);
    // Salt for TimelockController operations
    bytes32 SALT = "SetResolver";

    /**
     * @notice Schedule a setResolver through the timelock
     */
    function runS() public {
        runSchedule(NETWORK, VAULT, SUBNETWORK_IDENTIFIER, RESOLVER, HINTS, DELAY, SALT);
    }

    /**
     * @notice Execute a setResolver immediately through the timelock
     */
    function runE() public {
        runExecute(NETWORK, VAULT, SUBNETWORK_IDENTIFIER, RESOLVER, HINTS, SALT);
    }

    /**
     * @notice Schedule and execute a setResolver through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runScheduleAndExecute(NETWORK, VAULT, SUBNETWORK_IDENTIFIER, RESOLVER, HINTS, SALT);
    }
}
