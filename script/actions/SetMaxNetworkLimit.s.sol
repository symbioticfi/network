// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./base/SetMaxNetworkLimitBase.sol";

contract SetMaxNetworkLimit is SetMaxNetworkLimitBase {
    // Configuration constants - UPDATE THESE BEFORE EXECUTING

    // Address of the Network
    address NETWORK = 0xFCD714bC06f20B4877A83aC579F8800D5662aa19;
    // Address of the Vault
    address VAULT = 0x49fC19bAE549e0b5F99B5b42d7222Caf09E8d2a1;
    // Maximum amount of delegation that network is ready to receive
    uint256 MAX_NETWORK_LIMIT = 0;
    // Delay for the action to be executed
    uint256 DELAY = 0;

    // Optional

    // Subnetwork Identifier (multiple subnetworks can be used, e.g., to have different max network limits for the same network)
    uint96 SUBNETWORK_IDENTIFIER = 0;
    // Salt for TimelockController operations
    bytes32 SALT = "SetMaxNetworkLimit";

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
