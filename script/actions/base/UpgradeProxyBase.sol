// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./ActionBase.sol";
import {Network} from "../../../src/Network.sol";

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ITimelockAction} from "../interfaces/ITimelockAction.sol";

contract UpgradeProxyBase is ActionBase, ITimelockAction {
    address public network;
    address public newImplementation;
    uint256 public delay;
    bytes32 public salt;
    bytes public upgradeData;

    constructor(
        address network_,
        address newImplementation_,
        bytes memory upgradeData_,
        uint256 delay_,
        bytes32 salt_
    ) {
        network = network_;
        newImplementation = newImplementation_;
        upgradeData = upgradeData_;
        delay = delay_;
        salt = salt_;
    }

    function runSchedule() public {
        (address target, bytes memory data) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: network,
                isExecutionMode: false,
                target: target,
                data: data,
                delay: delay,
                salt: salt
            })
        );

        log(
            string.concat(
                "Scheduled upgrade for",
                "\n    network:",
                vm.toString(network),
                "\n    upgradeData:",
                string(upgradeData),
                "\n    newImplementation:",
                vm.toString(newImplementation),
                "\n    delay:",
                vm.toString(delay),
                "\n    salt:",
                vm.toString(salt)
            )
        );
    }

    function runExecute() public {
        (address target, bytes memory data) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: network,
                isExecutionMode: true,
                target: target,
                data: data,
                delay: 0,
                salt: salt
            })
        );

        log(
            string.concat(
                "Executed upgrade for",
                "\n    network:",
                vm.toString(network),
                "\n    upgradeData:",
                string(upgradeData),
                "\n    newImplementation:",
                vm.toString(newImplementation),
                "\n    salt:",
                vm.toString(salt)
            )
        );

        assert(address(uint160(uint256(vm.load(network, ERC1967Utils.IMPLEMENTATION_SLOT)))) == newImplementation);
    }

    function runScheduleAndExecute() public {
        runSchedule();
        runExecute();
    }

    function _getProxyAdmin(
        address proxy
    ) internal view returns (address admin) {
        return address(uint160(uint256(vm.load(proxy, ERC1967Utils.ADMIN_SLOT))));
    }

    function getTargetAndPayload() public view returns (address target, bytes memory payload) {
        target = _getProxyAdmin(network);
        payload = abi.encodeCall(
            ProxyAdmin.upgradeAndCall, (ITransparentUpgradeableProxy(network), newImplementation, upgradeData)
        );
    }
}
