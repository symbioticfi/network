// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./ActionBase.sol";
import {Network} from "../../../src/Network.sol";

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ITimelockAction} from "../interfaces/ITimelockAction.sol";

contract UpgradeProxyBase is ActionBase, ITimelockAction {
    struct UpgradeProxyParams {
        address network;
        address newImplementation;
        bytes upgradeData;
        uint256 delay;
        bytes32 salt;
    }

    UpgradeProxyParams public params;

    constructor(UpgradeProxyParams memory params_) {
        params = params_;
    }

    function runSchedule() public {
        (address target, bytes memory data) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: params.network,
                isExecutionMode: false,
                target: target,
                data: data,
                delay: params.delay,
                salt: params.salt
            })
        );

        log(
            string.concat(
                "Scheduled upgrade for",
                "\n    network:",
                vm.toString(params.network),
                "\n    upgradeData:",
                string(params.upgradeData),
                "\n    newImplementation:",
                vm.toString(params.newImplementation),
                "\n    delay:",
                vm.toString(params.delay),
                "\n    salt:",
                vm.toString(params.salt)
            )
        );
    }

    function runExecute() public {
        (address target, bytes memory data) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: params.network, isExecutionMode: true, target: target, data: data, delay: 0, salt: params.salt
            })
        );

        log(
            string.concat(
                "Executed upgrade for",
                "\n    network:",
                vm.toString(params.network),
                "\n    upgradeData:",
                string(params.upgradeData),
                "\n    newImplementation:",
                vm.toString(params.newImplementation),
                "\n    salt:",
                vm.toString(params.salt)
            )
        );

        assert(
            address(uint160(uint256(vm.load(params.network, ERC1967Utils.IMPLEMENTATION_SLOT))))
                == params.newImplementation
        );
    }

    function runScheduleAndExecute() public {
        runSchedule();
        runExecute();
    }

    function _getProxyAdmin(address proxy) internal view returns (address admin) {
        return address(uint160(uint256(vm.load(proxy, ERC1967Utils.ADMIN_SLOT))));
    }

    function getTargetAndPayload() public view returns (address target, bytes memory payload) {
        target = _getProxyAdmin(params.network);
        payload = abi.encodeCall(
            ProxyAdmin.upgradeAndCall,
            (ITransparentUpgradeableProxy(params.network), params.newImplementation, params.upgradeData)
        );
    }
}
