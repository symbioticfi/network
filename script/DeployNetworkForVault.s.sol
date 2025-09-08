// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {DeployNetworkForVaultBase} from "./base/DeployNetworkForVaultBase.sol";

/**
 * Deploys Network implementation and a TransparentUpgradeableProxy managed by ProxyAdmin.
 * Uses CREATE3 for deterministic proxy deployment.
 * Also, opt-ins the Network to the given Vault.
 *
 * Configuration is handled entirely by inherited contract.
 */
contract DeployNetworkForVault is DeployNetworkForVaultBase {
    // Configuration constants - UPDATE THESE BEFORE DEPLOYMENT

    // Name of the Network
    string NAME = "My Network";
    // Default minimum delay (will be applied for any action that doesn't have a specific delay yet)
    uint256 DEFAULT_MIN_DELAY = 3 days;
    // Cold actions delay (a delay that will be applied for major actions like upgradeProxy and setMiddleware)
    uint256 COLD_ACTIONS_DELAY = 14 days;
    // Hot actions delay (a delay that will be applied for minor actions like setMaxNetworkLimit and setResolver)
    uint256 HOT_ACTIONS_DELAY = 0;
    // Admin address (will become executor, proposer, and default admin by default)
    address ADMIN = 0x0000000000000000000000000000000000000000;
    // Vault address to opt-in to
    address VAULT = 0x0000000000000000000000000000000000000000;
    // Maximum amount of delegation that network is ready to receive
    uint256 MAX_NETWORK_LIMIT = 0;
    // Resolver address (optional, is applied only if VetoSlasher is used)
    address RESOLVER = 0x0000000000000000000000000000000000000000;

    // Optional

    // Subnetwork Identifier (multiple subnetworks can be used, e.g., to have different resolvers for the same network)
    uint96 SUBNETWORK_ID = 0;
    // Metadata URI of the Network
    string METADATA_URI = "";
    // Salt for deterministic deployment
    bytes11 SALT = "SymNetwork";

    function run() public {
        address[] memory proposers = new address[](1);
        proposers[0] = ADMIN;
        address[] memory executors = new address[](1);
        executors[0] = ADMIN;
        run(
            DeployNetworkForVaultParams({
                deployNetworkParams: DeployNetworkParams({
                    name: NAME,
                    metadataURI: METADATA_URI,
                    proposers: proposers,
                    executors: executors,
                    defaultAdminRoleHolder: ADMIN,
                    nameUpdateRoleHolder: ADMIN,
                    metadataURIUpdateRoleHolder: ADMIN,
                    globalMinDelay: DEFAULT_MIN_DELAY,
                    upgradeProxyMinDelay: COLD_ACTIONS_DELAY,
                    setMiddlewareMinDelay: COLD_ACTIONS_DELAY,
                    setMaxNetworkLimitMinDelay: HOT_ACTIONS_DELAY,
                    setResolverMinDelay: HOT_ACTIONS_DELAY,
                    salt: SALT
                }),
                vault: VAULT,
                subnetworkId: SUBNETWORK_ID,
                maxNetworkLimit: MAX_NETWORK_LIMIT,
                resolver: RESOLVER
            })
        );
    }
}
