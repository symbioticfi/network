// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ActionBase} from "../../actions/base/ActionBase.sol";
import {Network} from "../../../src/Network.sol";
import {INetwork} from "../../../src/interfaces/INetwork.sol";
import {ITimelockAction} from "../../actions/interfaces/ITimelockAction.sol";

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";

contract UpgradeProxyUpdateDelayBase is ActionBase, ITimelockAction {
    address public network;
    uint256 public upgradeProxyDelay;
    uint256 public delay;
    bytes32 public salt;

    constructor(address network_, uint256 upgradeProxyDelay_, uint256 delay_, bytes32 salt_) {
        network = network_;
        upgradeProxyDelay = upgradeProxyDelay_;
        delay = delay_;
        salt = salt_;
    }

    function runSchedule() public {
        (address delegator, bytes memory payload) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: network,
                isExecutionMode: false,
                target: delegator,
                data: payload,
                delay: delay,
                salt: salt
            })
        );

        log(
            string.concat(
                "Scheduled upgradeProxyUpdateDelay for",
                "\n    network:",
                vm.toString(network),
                "\n    upgradeProxyDelay:",
                vm.toString(upgradeProxyDelay),
                "\n    delay:",
                vm.toString(delay),
                "\n    salt:",
                vm.toString(salt)
            )
        );
    }

    function runExecute() public {
        (address delegator, bytes memory payload) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: network,
                isExecutionMode: true,
                target: delegator,
                data: payload,
                delay: 0,
                salt: salt
            })
        );

        log(
            string.concat(
                "Executed upgradeProxyUpdateDelay for",
                "\n    network:",
                vm.toString(network),
                "\n    upgradeProxyDelay:",
                vm.toString(upgradeProxyDelay),
                "\n    delay:",
                vm.toString(delay),
                "\n    salt:",
                vm.toString(salt)
            )
        );

        assert(
            INetwork(network).getMinDelay(_getProxyAdmin(network), abi.encodePacked(ProxyAdmin.upgradeAndCall.selector))
                == upgradeProxyDelay
        );
    }

    function runScheduleAndExecute() public {
        runSchedule();
        runExecute();
    }

    function getTargetAndPayload() public view returns (address target, bytes memory payload) {
        target = network;
        payload = abi.encodeCall(
            INetwork.updateDelay, (_getProxyAdmin(network), ProxyAdmin.upgradeAndCall.selector, true, upgradeProxyDelay)
        );
    }

    function _getProxyAdmin(
        address proxy
    ) internal view returns (address admin) {
        return address(uint160(uint256(vm.load(proxy, ERC1967Utils.ADMIN_SLOT))));
    }
}
