// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./ActionBase.sol";
import {Network} from "../../../src/Network.sol";

import {INetworkMiddlewareService} from "@symbioticfi/core/src/interfaces/service/INetworkMiddlewareService.sol";
import {SymbioticCoreConstants} from "@symbioticfi/core/test/integration/SymbioticCoreConstants.sol";
import {ITimelockAction} from "../interfaces/ITimelockAction.sol";

contract SetMiddlewareBase is ActionBase, ITimelockAction {
    address public network;
    address public middleware;
    uint256 public delay;
    bytes32 public salt;

    constructor(address network_, address middleware_, uint256 delay_, bytes32 salt_) {
        network = network_;
        middleware = middleware_;
        delay = delay_;
        salt = salt_;
    }

    function runSchedule() public {
        (address target, bytes memory data) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: network,
                isExecutionMode: false,
                target: target,
                data: data,
                delay: delay,
                salt: salt
            })
        );

        log(
            string.concat(
                "Scheduled setMiddleware for",
                "\n    network:",
                vm.toString(network),
                "\n    middleware:",
                vm.toString(middleware),
                "\n    delay:",
                vm.toString(delay),
                "\n    salt:",
                vm.toString(salt)
            )
        );
    }

    function runExecute() public {
        (address target, bytes memory data) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: network,
                isExecutionMode: true,
                target: target,
                data: data,
                delay: 0,
                salt: salt
            })
        );

        log(
            string.concat(
                "Executed setMiddleware for",
                "\n    network:",
                vm.toString(network),
                "\n    middleware:",
                vm.toString(middleware),
                "\n    salt:",
                vm.toString(salt)
            )
        );

        assert(SymbioticCoreConstants.core().networkMiddlewareService.middleware(network) == middleware);
    }

    function runScheduleAndExecute() public {
        runSchedule();
        runExecute();
    }

    function getTargetAndPayload() public view returns (address target, bytes memory payload) {
        target = address(SymbioticCoreConstants.core().networkMiddlewareService);
        payload = abi.encodeCall(INetworkMiddlewareService.setMiddleware, (middleware));
    }
}
