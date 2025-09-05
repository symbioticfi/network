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
    address ADMIN = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    // Vault address to opt-in to
    address VAULT = 0x49fC19bAE549e0b5F99B5b42d7222Caf09E8d2a1;
    // Maximum amount of delegation that network is ready to receive
    uint256 MAX_NETWORK_LIMIT = 1000;
    // Resolver address (optional, is applied only if VetoSlasher is used)
    address RESOLVER = 0xbf616b04c463b818e3336FF3767e61AB44103243;

    // Optional

    // Subnetwork Identifier (multiple subnetworks can be used, e.g., to have different resolvers for the same network)
    uint96 SUBNETWORK_ID = 0;
    // Metadata URI of the Network
    string METADATA_URI = "";
    // Salt for deterministic deployment
    bytes11 SALT = "Test3";

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
