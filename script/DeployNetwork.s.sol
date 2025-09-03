// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {console2 as console} from "forge-std/console2.sol";

import {Network} from "../src/contracts/Network.sol";
import {INetwork} from "../src/interfaces/INetwork.sol";
import {NetworkConfig} from "./NetworkConfig.sol";
import {MyNetwork} from "../examples/MyNetwork.sol";

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

/**
 * Deploys Network implementation and a TransparentUpgradeableProxy managed by ProxyAdmin.
 *
 * Configuration is handled entirely by NetworkConfig contract.
 * Update the constants in NetworkConfig.sol before deployment.
 */
contract DeployNetwork is Script, NetworkConfig {
    function run() external {
        vm.startBroadcast();

        // 1) Deploy implementation (immutables are set via constructor)
        Network implementation = new MyNetwork(NETWORK_REGISTRY, NETWORK_MIDDLEWARE_SERVICE);

        // 2) Deploy ProxyAdmin owned by deployer
        ProxyAdmin proxyAdmin = new ProxyAdmin(PROXY_ADMIN);

        // 3) Get initialization parameters
        INetwork.NetworkInitParams memory initParams = _getInitParams();

        bytes memory initData = abi.encodeCall(MyNetwork.initialize, (initParams));

        // 4) Deploy TransparentUpgradeableProxy and call initializer
        TransparentUpgradeableProxy proxy =
            new TransparentUpgradeableProxy(address(implementation), address(proxyAdmin), initData);

        console.log("Network implementation:", address(implementation));
        console.log("ProxyAdmin:", address(proxyAdmin));
        console.log("Network proxy:", address(proxy));

        vm.stopBroadcast();
    }

    /**
     * @notice Get initialization parameters
     * @return The initialization parameters
     */
    function _getInitParams() internal pure returns (INetwork.NetworkInitParams memory) {
        address[] memory proposers = new address[](1);
        proposers[0] = PROPOSER;

        address[] memory executors = new address[](1);
        executors[0] = EXECUTOR; // Open executor

        return INetwork.NetworkInitParams({
            globalMinDelay: GLOBAL_MIN_DELAY,
            delayParams: new INetwork.DelayParams[](0),
            proposers: proposers,
            executors: executors,
            name: NAME,
            metadataURI: METADATA_URI,
            defaultAdminRoleHolder: DEFAULT_ADMIN_ROLE_HOLDER,
            nameUpdateRoleHolder: NAME_UPDATE_ROLE_HOLDER,
            metadataURIUpdateRoleHolder: METADATA_URI_UPDATE_ROLE_HOLDER
        });
    }
}
