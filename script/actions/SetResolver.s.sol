// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/SetResolverBase.sol";

contract SetResolver is SetResolverBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address NETWORK = 0x0000000000000000000000000000000000000000;
    // Address of the Vault
    address VAULT = 0x0000000000000000000000000000000000000000;
    // Address of the Resolver
    address RESOLVER = 0x0000000000000000000000000000000000000000;
    // Delay for the action to be executed
    uint256 DELAY = 0;

    // Optional

    // Subnetwork Identifier (multiple subnetworks can be used, e.g., to have different resolvers for the same network)
    uint96 SUBNETWORK_IDENTIFIER = 0;
    // Hints for the Resolver
    bytes HINTS = new bytes(0);
    // Salt for TimelockController operations
    bytes32 SALT = "SetResolver";

    constructor()
        SetResolverBase(
            SetResolverBase.SetResolverParams({
                network: NETWORK,
                vault: VAULT,
                identifier: SUBNETWORK_IDENTIFIER,
                resolver: RESOLVER,
                hints: HINTS,
                delay: DELAY,
                salt: SALT
            })
        )
    {}

    /**
     * @notice Schedule a setResolver through the timelock
     */
    function runS() public {
        runSchedule();
    }

    /**
     * @notice Execute a setResolver immediately through the timelock
     */
    function runE() public {
        runExecute();
    }

    /**
     * @notice Schedule and execute a setResolver through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runScheduleAndExecute();
    }
}
