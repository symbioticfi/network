// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../../actions/base/ActionBase.sol";
import {Network} from "../../../src/Network.sol";
import {INetwork} from "../../../src/interfaces/INetwork.sol";

import {IVetoSlasher} from "@symbioticfi/core/src/interfaces/slasher/IVetoSlasher.sol";
import {ITimelockAction} from "../../actions/interfaces/ITimelockAction.sol";

contract SetResolverUpdateDelayBase is ActionBase, ITimelockAction {
    address public network;
    uint256 public setResolverDelay;
    uint256 public delay;
    bytes32 public salt;

    constructor(address network_, uint256 setResolverDelay_, uint256 delay_, bytes32 salt_) {
        network = network_;
        setResolverDelay = setResolverDelay_;
        delay = delay_;
        salt = salt_;
    }

    function runSchedule() public {
        (address target, bytes memory payload) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: network,
                isExecutionMode: false,
                target: target,
                data: payload,
                delay: delay,
                salt: salt
            })
        );

        log(
            string.concat(
                "Scheduled setResolverUpdateDelay for",
                "\n    network:",
                vm.toString(network),
                "\n    setResolverDelay:",
                vm.toString(setResolverDelay),
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
                "Executed setResolverUpdateDelay for",
                "\n    network:",
                vm.toString(network),
                "\n    setResolverDelay:",
                vm.toString(setResolverDelay),
                "\n    delay:",
                vm.toString(delay),
                "\n    salt:",
                vm.toString(salt)
            )
        );

        assert(
            INetwork(network).getMinDelay(address(1), abi.encodePacked(IVetoSlasher.setResolver.selector))
                == setResolverDelay
        );
    }

    function runScheduleAndExecute() public {
        runSchedule();
        runExecute();
    }

    function getTargetAndPayload() public view returns (address target, bytes memory payload) {
        target = network;
        payload = abi.encodeCall(
            INetwork.updateDelay, (address(0), IVetoSlasher.setResolver.selector, true, setResolverDelay)
        );
    }
}
