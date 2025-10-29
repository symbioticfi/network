// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./ActionBase.sol";
import {Network} from "../../../src/Network.sol";

import {INetworkMiddlewareService} from "@symbioticfi/core/src/interfaces/service/INetworkMiddlewareService.sol";
import {SymbioticCoreConstants} from "@symbioticfi/core/test/integration/SymbioticCoreConstants.sol";
import {ITimelockAction} from "../interfaces/ITimelockAction.sol";

contract SetMiddlewareBase is ActionBase, ITimelockAction {
    struct SetMiddlewareParams {
        address network;
        address middleware;
        uint256 delay;
        bytes32 salt;
    }

    SetMiddlewareParams public params;

    constructor(SetMiddlewareParams memory params_) {
        params = params_;
    }

    function runSchedule() public {
        (address target, bytes memory data) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: params.network,
                isExecutionMode: false,
                target: target,
                data: data,
                delay: params.delay,
                salt: params.salt
            })
        );

        log(
            string.concat(
                "Scheduled setMiddleware for",
                "\n    network:",
                vm.toString(params.network),
                "\n    middleware:",
                vm.toString(params.middleware),
                "\n    delay:",
                vm.toString(params.delay),
                "\n    salt:",
                vm.toString(params.salt)
            )
        );
    }

    function runExecute() public {
        (address target, bytes memory data) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: params.network, isExecutionMode: true, target: target, data: data, delay: 0, salt: params.salt
            })
        );

        log(
            string.concat(
                "Executed setMiddleware for",
                "\n    network:",
                vm.toString(params.network),
                "\n    middleware:",
                vm.toString(params.middleware),
                "\n    salt:",
                vm.toString(params.salt)
            )
        );

        assert(SymbioticCoreConstants.core().networkMiddlewareService.middleware(params.network) == params.middleware);
    }

    function runScheduleAndExecute() public {
        runSchedule();
        runExecute();
    }

    function getTargetAndPayload() public view returns (address target, bytes memory payload) {
        target = address(SymbioticCoreConstants.core().networkMiddlewareService);
        payload = abi.encodeCall(INetworkMiddlewareService.setMiddleware, (params.middleware));
    }
}
