// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {console2 as console} from "forge-std/console2.sol";

import {Network} from "../src/contracts/Network.sol";
import {INetwork} from "../src/interfaces/INetwork.sol";
import {MyNetwork} from "../examples/MyNetwork.sol";

import {SymbioticCoreConstants} from "@symbioticfi/core/test/integration/SymbioticCoreConstants.sol";

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

/**
 * Deploys Network implementation and a TransparentUpgradeableProxy managed by ProxyAdmin.
 *
 * Configuration is handled entirely by inhired contract.
 */
contract DeployNetwork is Script {
    struct NetworkDeployParams {
        INetwork.NetworkInitParams initParams;
        address proxyAdmin;
    }

    function run(
        NetworkDeployParams memory params
    ) public {
        vm.startBroadcast();

        address networkRegistry = address(SymbioticCoreConstants.core().networkRegistry);
        address networkMiddlewareService = address(SymbioticCoreConstants.core().networkMiddlewareService);

        Network implementation = new MyNetwork(networkRegistry, networkMiddlewareService);
        ProxyAdmin proxyAdmin = new ProxyAdmin(params.proxyAdmin);
        bytes memory initData = abi.encodeCall(MyNetwork.initialize, (params.initParams));

        TransparentUpgradeableProxy proxy =
            new TransparentUpgradeableProxy(address(implementation), address(proxyAdmin), initData);

        console.log("Network implementation:", address(implementation));
        console.log("ProxyAdmin:", address(proxyAdmin));
        console.log("Network proxy:", address(proxy));

        vm.stopBroadcast();
    }
}
