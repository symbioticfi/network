// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../../actions/base/ActionBase.sol";
import {Network} from "../../../src/Network.sol";
import {INetwork} from "../../../src/interfaces/INetwork.sol";

import {ITimelockAction} from "../../actions/interfaces/ITimelockAction.sol";

contract ArbitraryCallUpdateDelayBase is ActionBase, ITimelockAction {
    struct ArbitraryCallUpdateDelayParams {
        address network;
        bool enabled;
        address target;
        bytes4 selector;
        uint256 arbitraryCallDelay;
        uint256 delay;
        bytes32 salt;
    }

    ArbitraryCallUpdateDelayParams public params;

    constructor(ArbitraryCallUpdateDelayParams memory params_) {
        params = params_;
    }

    function runSchedule() public {
        (address target_, bytes memory payload) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: params.network,
                isExecutionMode: false,
                target: target_,
                data: payload,
                delay: params.delay,
                salt: params.salt
            })
        );

        log(
            string.concat(
                "Scheduled arbitraryCallUpdateDelay for",
                "\n    network:",
                vm.toString(params.network),
                "\n    target:",
                vm.toString(target_),
                "\n    selector:",
                vm.toString(params.selector),
                "\n    arbitraryCallDelay:",
                vm.toString(params.arbitraryCallDelay),
                "\n    delay:",
                vm.toString(params.delay),
                "\n    salt:",
                vm.toString(params.salt)
            )
        );
    }

    function runExecute() public {
        (address target_, bytes memory payload) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: params.network,
                isExecutionMode: true,
                target: target_,
                data: payload,
                delay: 0,
                salt: params.salt
            })
        );

        log(
            string.concat(
                "Executed arbitraryCallUpdateDelay for",
                "\n    network:",
                vm.toString(params.network),
                "\n    target:",
                vm.toString(target_),
                "\n    selector:",
                vm.toString(params.selector),
                "\n    arbitraryCallDelay:",
                vm.toString(params.arbitraryCallDelay),
                "\n    delay:",
                vm.toString(params.delay),
                "\n    salt:",
                vm.toString(params.salt)
            )
        );
    }

    function runScheduleAndExecute() public {
        runSchedule();
        runExecute();
    }

    function getTargetAndPayload() public view returns (address target_, bytes memory payload) {
        target_ = params.network;
        payload = abi.encodeCall(
            INetwork.updateDelay, (params.target, params.selector, params.enabled, params.arbitraryCallDelay)
        );
    }
}
