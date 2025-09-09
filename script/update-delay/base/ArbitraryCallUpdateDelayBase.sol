// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../../actions/base/ActionBase.sol";
import {Network} from "../../../src/Network.sol";
import {INetwork} from "../../../src/interfaces/INetwork.sol";

import {ITimelockAction} from "../../actions/interfaces/ITimelockAction.sol";

contract ArbitraryCallUpdateDelayBase is ActionBase, ITimelockAction {
    address public network;
    bool public enabled;
    address public target;
    bytes4 public selector;
    uint256 public arbitraryCallDelay;
    uint256 public delay;
    bytes32 public salt;

    constructor(
        address network_,
        address target_,
        bytes4 selector_,
        uint256 arbitraryCallDelay_,
        uint256 delay_,
        bytes32 salt_
    ) {
        network = network_;
        enabled = true;
        target = target_;
        selector = selector_;
        arbitraryCallDelay = arbitraryCallDelay_;
        delay = delay_;
        salt = salt_;
    }

    function runSchedule() public {
        (address target_, bytes memory payload) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: network,
                isExecutionMode: false,
                target: target_,
                data: payload,
                delay: delay,
                salt: salt
            })
        );

        log(
            string.concat(
                "Scheduled arbitraryCallUpdateDelay for",
                "\n    network:",
                vm.toString(network),
                "\n    target:",
                vm.toString(target_),
                "\n    selector:",
                vm.toString(selector),
                "\n    arbitraryCallDelay:",
                vm.toString(arbitraryCallDelay),
                "\n    delay:",
                vm.toString(delay),
                "\n    salt:",
                vm.toString(salt)
            )
        );
    }

    function runExecute() public {
        (address target_, bytes memory payload) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: network,
                isExecutionMode: true,
                target: target_,
                data: payload,
                delay: 0,
                salt: salt
            })
        );

        log(
            string.concat(
                "Executed arbitraryCallUpdateDelay for",
                "\n    network:",
                vm.toString(network),
                "\n    target:",
                vm.toString(target_),
                "\n    selector:",
                vm.toString(selector),
                "\n    arbitraryCallDelay:",
                vm.toString(arbitraryCallDelay),
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

    function getTargetAndPayload() public view returns (address target_, bytes memory payload) {
        target_ = network;
        payload = abi.encodeCall(INetwork.updateDelay, (target, selector, enabled, arbitraryCallDelay));
    }
}
