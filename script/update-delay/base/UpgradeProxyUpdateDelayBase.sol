// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../../actions/base/ActionBase.sol";
import {Network} from "../../../src/Network.sol";
import {INetwork} from "../../../src/interfaces/INetwork.sol";

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ITimelockAction} from "../../actions/interfaces/ITimelockAction.sol";

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
    }

    function runScheduleAndExecute() public {
        runSchedule();
        runExecute();
    }

    function getTargetAndPayload() public view returns (address target, bytes memory payload) {
        target = network;
        payload = abi.encodeCall(
            INetwork.updateDelay, (address(0), ProxyAdmin.upgradeAndCall.selector, true, upgradeProxyDelay)
        );
    }
}
