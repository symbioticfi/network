// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {DeployNetworkBase} from "./base/DeployNetworkBase.sol";
import {INetwork} from "../src/interfaces/INetwork.sol";

/**
 * Deploys Network implementation and a TransparentUpgradeableProxy managed by ProxyAdmin.
 * Uses CREATE3 for deterministic proxy deployment.
 *
 * Configuration is handled entirely by inherited contract.
 */
contract DeployNetwork is DeployNetworkBase {
    // Configuration constants - UPDATE THESE BEFORE DEPLOYMENT
    string NAME = "My Network";
    string METADATA_URI = "";
    uint256 DEFAULT_MIN_DELAY = 3 days;
    uint256 COLD_ACTIONS_DELAY = 14 days;
    uint256 HOT_ACTIONS_DELAY = 0;
    address ADMIN = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    // Optional
    bytes11 SALT = "SymNetwork";

    function run() public {
        address[] memory proposers = new address[](1);
        proposers[0] = ADMIN;
        address[] memory executors = new address[](1);
        executors[0] = ADMIN;
        run(
            DeployNetworkParams({
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
            })
        );
    }
}
