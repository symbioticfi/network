// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ActionBase} from "../../actions/base/ActionBase.sol";
import {Network} from "../../../src/Network.sol";
import {INetwork} from "../../../src/interfaces/INetwork.sol";
import {ITimelockAction} from "../../actions/interfaces/ITimelockAction.sol";

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";

contract UpgradeProxyUpdateDelayBase is ActionBase, ITimelockAction {
    struct UpgradeProxyUpdateDelayParams {
        address network;
        uint256 upgradeProxyDelay;
        uint256 delay;
        bytes32 salt;
    }

    UpgradeProxyUpdateDelayParams public params;

    constructor(
        UpgradeProxyUpdateDelayParams memory params_
    ) {
        params = params_;
    }

    function runSchedule() public {
        (address target, bytes memory payload) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: params.network,
                isExecutionMode: false,
                target: target,
                data: payload,
                delay: params.delay,
                salt: params.salt
            })
        );

        log(
            string.concat(
                "Scheduled upgradeProxyUpdateDelay for",
                "\n    network:",
                vm.toString(params.network),
                "\n    upgradeProxyDelay:",
                vm.toString(params.upgradeProxyDelay),
                "\n    delay:",
                vm.toString(params.delay),
                "\n    salt:",
                vm.toString(params.salt)
            )
        );
    }

    function runExecute() public {
        (address target, bytes memory payload) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: params.network,
                isExecutionMode: true,
                target: target,
                data: payload,
                delay: 0,
                salt: params.salt
            })
        );

        log(
            string.concat(
                "Executed upgradeProxyUpdateDelay for",
                "\n    network:",
                vm.toString(params.network),
                "\n    upgradeProxyDelay:",
                vm.toString(params.upgradeProxyDelay),
                "\n    delay:",
                vm.toString(params.delay),
                "\n    salt:",
                vm.toString(params.salt)
            )
        );

        assert(
            INetwork(params.network).getMinDelay(
                _getProxyAdmin(params.network), abi.encodePacked(ProxyAdmin.upgradeAndCall.selector)
            ) == params.upgradeProxyDelay
        );
    }

    function runScheduleAndExecute() public {
        runSchedule();
        runExecute();
    }

    function getTargetAndPayload() public view returns (address target, bytes memory payload) {
        target = params.network;
        payload = abi.encodeCall(
            INetwork.updateDelay,
            (_getProxyAdmin(params.network), ProxyAdmin.upgradeAndCall.selector, true, params.upgradeProxyDelay)
        );
    }

    function _getProxyAdmin(
        address proxy
    ) internal view returns (address admin) {
        return address(uint160(uint256(vm.load(proxy, ERC1967Utils.ADMIN_SLOT))));
    }
}
