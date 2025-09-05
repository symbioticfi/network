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
    string NAME = "My Network";
    string METADATA_URI = "";
    uint256 DEFAULT_MIN_DELAY = 3 days;
    uint256 COLD_ACTIONS_DELAY = 14 days;
    uint256 HOT_ACTIONS_DELAY = 0;
    address ADMIN = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address VAULT = address(0);
    uint256 MAX_NETWORK_LIMIT = 0;
    address RESOLVER = address(0);

    // Optional
    uint96 SUBNETWORK_ID = 0;
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
                    proxyAdmin: ADMIN,
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
