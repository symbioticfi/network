// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./ActionBase.sol";
import {Network} from "../../../src/Network.sol";

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract UpgradeNetworkBase is ActionBase {
    function runSchedule(
        address network,
        address newImplementation,
        bytes memory upgradeData,
        uint256 delay,
        bytes32 salt
    ) public {
        address proxyAdmin = _getProxyAdmin(network);
        callTimelock(
            ActionBase.TimelockParams({
                network: network,
                isExecutionMode: false,
                target: proxyAdmin,
                data: abi.encodeCall(
                    ProxyAdmin.upgradeAndCall, (ITransparentUpgradeableProxy(network), newImplementation, upgradeData)
                ),
                delay: delay,
                salt: salt
            })
        );

        log(
            string.concat(
                "Scheduled upgrade for",
                "\n    network:",
                vm.toString(network),
                "\n    proxyAdmin:",
                vm.toString(proxyAdmin),
                "\n    newImplementation:",
                vm.toString(newImplementation),
                "\n    delay:",
                vm.toString(delay),
                "\n    salt:",
                vm.toString(salt)
            )
        );
    }

    function runExecute(address network, address newImplementation, bytes memory upgradeData, bytes32 salt) public {
        address proxyAdmin = _getProxyAdmin(network);
        callTimelock(
            ActionBase.TimelockParams({
                network: network,
                isExecutionMode: true,
                target: proxyAdmin,
                data: abi.encodeCall(
                    ProxyAdmin.upgradeAndCall, (ITransparentUpgradeableProxy(network), newImplementation, upgradeData)
                ),
                delay: 0,
                salt: salt
            })
        );

        log(
            string.concat(
                "Executed upgrade for",
                "\n    network:",
                vm.toString(network),
                "\n    proxyAdmin:",
                vm.toString(proxyAdmin),
                "\n    newImplementation:",
                vm.toString(newImplementation),
                "\n    salt:",
                vm.toString(salt)
            )
        );
    }

    function runScheduleAndExecute(
        address network,
        address newImplementation,
        bytes memory upgradeData,
        bytes32 salt
    ) public {
        runSchedule(network, newImplementation, upgradeData, 0, salt);
        runExecute(network, newImplementation, upgradeData, salt);
    }

    function _getProxyAdmin(
        address proxy
    ) internal view returns (address admin) {
        return address(uint160(uint256(vm.load(proxy, ERC1967Utils.ADMIN_SLOT))));
    }
}
