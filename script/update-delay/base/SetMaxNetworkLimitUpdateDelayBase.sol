// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../../actions/base/ActionBase.sol";
import {Network} from "../../../src/Network.sol";
import {INetwork} from "../../../src/interfaces/INetwork.sol";

import {IBaseDelegator} from "@symbioticfi/core/src/interfaces/delegator/IBaseDelegator.sol";
import {ITimelockAction} from "../../actions/interfaces/ITimelockAction.sol";

contract SetMaxNetworkLimitUpdateDelayBase is ActionBase, ITimelockAction {
    struct SetMaxNetworkLimitUpdateDelayParams {
        address network;
        uint256 setMaxNetworkLimitDelay;
        uint256 delay;
        bytes32 salt;
    }

    SetMaxNetworkLimitUpdateDelayParams public params;

    constructor(SetMaxNetworkLimitUpdateDelayParams memory params_) {
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
                "Scheduled setMaxNetworkLimitUpdateDelay for",
                "\n    network:",
                vm.toString(params.network),
                "\n    setMaxNetworkLimitDelay:",
                vm.toString(params.setMaxNetworkLimitDelay),
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
                "Executed setMaxNetworkLimitUpdateDelay for",
                "\n    network:",
                vm.toString(params.network),
                "\n    setMaxNetworkLimitDelay:",
                vm.toString(params.setMaxNetworkLimitDelay),
                "\n    delay:",
                vm.toString(params.delay),
                "\n    salt:",
                vm.toString(params.salt)
            )
        );

        assert(
            INetwork(params.network)
                    .getMinDelay(address(1), abi.encodePacked(IBaseDelegator.setMaxNetworkLimit.selector))
                == params.setMaxNetworkLimitDelay
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
            (address(0), IBaseDelegator.setMaxNetworkLimit.selector, true, params.setMaxNetworkLimitDelay)
        );
    }
}
