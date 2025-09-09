// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../../actions/base/ActionBase.sol";
import {Network} from "../../../src/Network.sol";
import {INetwork} from "../../../src/interfaces/INetwork.sol";
import {ITimelockAction} from "../../actions/interfaces/ITimelockAction.sol";

import {SymbioticCoreConstants} from "@symbioticfi/core/test/integration/SymbioticCoreConstants.sol";
import {INetworkMiddlewareService} from "@symbioticfi/core/src/interfaces/service/INetworkMiddlewareService.sol";

contract SetMiddlewareUpdateDelayBase is ActionBase, ITimelockAction {
    struct SetMiddlewareUpdateDelayParams {
        address network;
        uint256 setMiddlewareDelay;
        uint256 delay;
        bytes32 salt;
    }

    SetMiddlewareUpdateDelayParams public params;

    constructor(
        SetMiddlewareUpdateDelayParams memory params_
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
                "Scheduled setMiddlewareUpdateDelay for",
                "\n    network:",
                vm.toString(params.network),
                "\n    setMiddlewareDelay:",
                vm.toString(params.setMiddlewareDelay),
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
                "Executed setMiddlewareUpdateDelay for",
                "\n    network:",
                vm.toString(params.network),
                "\n    setMiddlewareDelay:",
                vm.toString(params.setMiddlewareDelay),
                "\n    delay:",
                vm.toString(params.delay),
                "\n    salt:",
                vm.toString(params.salt)
            )
        );

        assert(
            INetwork(params.network).getMinDelay(
                address(SymbioticCoreConstants.core().networkMiddlewareService),
                abi.encodePacked(INetworkMiddlewareService.setMiddleware.selector)
            ) == params.setMiddlewareDelay
        );
    }

    function runScheduleAndExecute() public {
        runSchedule();
        runExecute();
    }

    function getTargetAndPayload() public view returns (address target, bytes memory payload) {
        target = params.network;

        SymbioticCoreConstants.Core memory core = SymbioticCoreConstants.core();
        payload = abi.encodeCall(
            INetwork.updateDelay,
            (
                address(core.networkMiddlewareService),
                INetworkMiddlewareService.setMiddleware.selector,
                true,
                params.setMiddlewareDelay
            )
        );
    }
}
