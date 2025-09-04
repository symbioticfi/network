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

import {ICreateX} from "@createx/ICreateX.sol";
/**
 * Deploys Network implementation and a TransparentUpgradeableProxy managed by ProxyAdmin.
 * Uses CREATE3 for deterministic proxy deployment.
 *
 * Configuration is handled entirely by inherited contract.
 */

contract DeployNetwork is Script {
    address public constant CREATEX_FACTORY = 0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed;

    struct NetworkDeployParams {
        INetwork.NetworkInitParams initParams;
        address proxyAdmin;
        bytes32 salt; // Salt for CREATE3 deterministic deployment
    }

    function run(
        NetworkDeployParams memory params
    ) public returns (address) {
        address networkRegistry = address(SymbioticCoreConstants.core().networkRegistry);
        address networkMiddlewareService = address(SymbioticCoreConstants.core().networkMiddlewareService);

        Network implementation = new MyNetwork(networkRegistry, networkMiddlewareService);

        bytes memory initData = abi.encodeCall(MyNetwork.initialize, (params.initParams));

        // Create initialization code for TransparentUpgradeableProxy
        bytes memory proxyInitCode = abi.encodePacked(
            type(TransparentUpgradeableProxy).creationCode,
            abi.encode(address(implementation), params.proxyAdmin, initData)
        );

        // Deploy proxy using CREATE3
        address proxy = ICreateX(CREATEX_FACTORY).deployCreate3(params.salt, proxyInitCode);

        console.log("Network implementation:", address(implementation));
        console.log("Network proxy:", proxy);

        return proxy;
    }
}
