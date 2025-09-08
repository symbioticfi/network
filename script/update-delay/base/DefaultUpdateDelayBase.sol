// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../../actions/base/ActionBase.sol";
import {Network} from "../../../src/Network.sol";

import {TimelockControllerUpgradeable} from
    "@openzeppelin/contracts-upgradeable/governance/TimelockControllerUpgradeable.sol";
import {ITimelockAction} from "../../actions/interfaces/ITimelockAction.sol";

contract DefaultUpdateDelayBase is ActionBase, ITimelockAction {
    address public network;
    uint256 public globalMinDelay;
    uint256 public delay;
    bytes32 public salt;

    constructor(address network_, uint256 globalMinDelay_, uint256 delay_, bytes32 salt_) {
        network = network_;
        globalMinDelay = globalMinDelay_;
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
                "Scheduled globalMinDelayUpdateDelay for",
                "\n    network:",
                vm.toString(network),
                "\n    globalMinDelay:",
                vm.toString(globalMinDelay),
                "\n    delay:",
                vm.toString(delay),
                "\n    salt:",
                vm.toString(salt)
            )
        );
    }

    function runExecute() public {
        (address target, bytes memory payload) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: network,
                isExecutionMode: true,
                target: target,
                data: payload,
                delay: 0,
                salt: salt
            })
        );

        log(
            string.concat(
                "Executed globalMinDelayUpdateDelay for",
                "\n    network:",
                vm.toString(network),
                "\n    globalMinDelay:",
                vm.toString(globalMinDelay),
                "\n    delay:",
                vm.toString(delay),
                "\n    salt:",
                vm.toString(salt)
            )
        );

        assert(TimelockControllerUpgradeable(payable(network)).getMinDelay() == globalMinDelay);
    }

    function runScheduleAndExecute() public {
        runSchedule();
        runExecute();
    }

    function getTargetAndPayload() public view returns (address target, bytes memory payload) {
        target = network;
        payload = abi.encodeCall(TimelockControllerUpgradeable.updateDelay, (globalMinDelay));
    }
}
