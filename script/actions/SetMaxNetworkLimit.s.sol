// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/SetMaxNetworkLimitBase.sol";

contract SetMaxNetworkLimit is SetMaxNetworkLimitBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address constant NETWORK = 0x0000000000000000000000000000000000000000;
    // Address of the Vault
    address constant VAULT = 0x0000000000000000000000000000000000000000;
    // Maximum amount of delegation that network is ready to receive
    uint256 constant MAX_NETWORK_LIMIT = 0;
    // Delay for the action to be executed
    uint256 constant DELAY = 0;

    // Optional

    // Subnetwork Identifier (multiple subnetworks can be used, e.g., to have different max network limits for the same network)
    uint96 constant SUBNETWORK_IDENTIFIER = 0;
    // Salt for TimelockController operations
    bytes32 constant SALT = "SetMaxNetworkLimit";

    constructor()
        SetMaxNetworkLimitBase(
            SetMaxNetworkLimitBase.SetMaxNetworkLimitParams({
                network: NETWORK,
                vault: VAULT,
                subnetworkId: SUBNETWORK_IDENTIFIER,
                maxNetworkLimit: MAX_NETWORK_LIMIT,
                delay: DELAY,
                salt: SALT
            })
        )
    {}

    /**
     * @notice Schedule a setMaxNetworkLimit through the timelock
     */
    function runS() public {
        runSchedule();
    }

    /**
     * @notice Execute a setMaxNetworkLimit immediately through the timelock
     */
    function runE() public {
        runExecute();
    }

    /**
     * @notice Schedule and execute a setMaxNetworkLimit through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runScheduleAndExecute();
    }
}
