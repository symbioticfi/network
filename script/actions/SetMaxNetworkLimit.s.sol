// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/SetMaxNetworkLimitBase.sol";

contract SetMaxNetworkLimit is SetMaxNetworkLimitBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address NETWORK = address(0);
    // Address of the Vault
    address VAULT = address(0);
    // Maximum amount of delegation that network is ready to receive
    uint256 MAX_NETWORK_LIMIT = 0;
    // Delay for the action to be executed
    uint256 DELAY = 0;

    // Optional

    // Subnetwork Identifier (multiple subnetworks can be used, e.g., to have different max network limits for the same network)
    uint96 SUBNETWORK_IDENTIFIER = 0;
    // Salt for TimelockController operations
    bytes32 SALT = "SetMaxNetworkLimit";

    /**
     * @notice Schedule a setMaxNetworkLimit through the timelock
     */
    function runS() public {
        runSchedule(NETWORK, VAULT, SUBNETWORK_IDENTIFIER, MAX_NETWORK_LIMIT, DELAY, SALT);
    }

    /**
     * @notice Execute a setMaxNetworkLimit immediately through the timelock
     */
    function runE() public {
        runExecute(NETWORK, VAULT, SUBNETWORK_IDENTIFIER, MAX_NETWORK_LIMIT, SALT);
    }

    /**
     * @notice Schedule and execute a setMaxNetworkLimit through the timelock
     * @dev It will succeed only if the delay is 0
     */
    function runSE() public {
        runScheduleAndExecute(NETWORK, VAULT, SUBNETWORK_IDENTIFIER, MAX_NETWORK_LIMIT, SALT);
    }
}
