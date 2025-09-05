// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/SetMaxNetworkLimitBase.sol";

contract SetMaxNetworkLimit is SetMaxNetworkLimitBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING
    address NETWORK = address(0);
    address VAULT = address(0);
    uint256 MAX_NETWORK_LIMIT = 0;
    uint256 DELAY = 0;

    // Optional
    uint96 SUBNETWORK_IDENTIFIER = 0;
    bytes32 SALT = "SetMaxNetworkLimit";

    /**
     * @notice Schedule a setMaxNetworkLimit through the timelock
     */
    function runSchedule() public {
        runSchedule(NETWORK, VAULT, SUBNETWORK_IDENTIFIER, MAX_NETWORK_LIMIT, DELAY, SALT);
    }

    /**
     * @notice Execute a setMaxNetworkLimit immediately through the timelock
     */
    function runExecute() public {
        runExecute(NETWORK, VAULT, SUBNETWORK_IDENTIFIER, MAX_NETWORK_LIMIT, SALT);
    }
}
