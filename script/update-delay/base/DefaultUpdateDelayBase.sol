// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../../actions/base/ActionBase.sol";
import {Network} from "../../../src/Network.sol";

import {TimelockControllerUpgradeable} from
    "@openzeppelin/contracts-upgradeable/governance/TimelockControllerUpgradeable.sol";
import {ITimelockAction} from "../../actions/interfaces/ITimelockAction.sol";

contract DefaultUpdateDelayBase is ActionBase, ITimelockAction {
    struct DefaultUpdateDelayParams {
        address network;
        uint256 globalMinDelay;
        uint256 delay;
        bytes32 salt;
    }

    DefaultUpdateDelayParams public params;

    constructor(
        DefaultUpdateDelayParams memory params_
    ) {
        params = params_;
    }

    function runSchedule() public {
        (address delegator, bytes memory payload) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: params.network,
                isExecutionMode: false,
                target: delegator,
                data: payload,
                delay: params.delay,
                salt: params.salt
            })
        );

        log(
            string.concat(
                "Scheduled globalMinDelayUpdateDelay for",
                "\n    network:",
                vm.toString(params.network),
                "\n    globalMinDelay:",
                vm.toString(params.globalMinDelay),
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
                "Executed globalMinDelayUpdateDelay for",
                "\n    network:",
                vm.toString(params.network),
                "\n    globalMinDelay:",
                vm.toString(params.globalMinDelay),
                "\n    delay:",
                vm.toString(params.delay),
                "\n    salt:",
                vm.toString(params.salt)
            )
        );

        assert(TimelockControllerUpgradeable(payable(params.network)).getMinDelay() == params.globalMinDelay);
    }

    function runScheduleAndExecute() public {
        runSchedule();
        runExecute();
    }

    function getTargetAndPayload() public view returns (address target, bytes memory payload) {
        target = params.network;
        payload = abi.encodeCall(TimelockControllerUpgradeable.updateDelay, (params.globalMinDelay));
    }
}
