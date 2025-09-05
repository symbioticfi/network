// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./ActionBase.sol";
import {Network} from "../../../src/Network.sol";

import {INetworkMiddlewareService} from "@symbioticfi/core/src/interfaces/service/INetworkMiddlewareService.sol";
import {SymbioticCoreConstants} from "@symbioticfi/core/test/integration/SymbioticCoreConstants.sol";

contract SetMiddlewareBase is ActionBase {
    function runSchedule(address network, address middleware, uint256 delay, bytes32 salt) public {
        (address target, bytes memory data) = getTargetAndPayload(middleware);
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
                "    network:",
                vm.toString(network),
                "    middleware:",
                vm.toString(middleware),
                "    delay:",
                vm.toString(delay),
                "    salt:",
                vm.toString(salt)
            )
        );
    }

    function runExecute(address network, address middleware, bytes32 salt) public {
        (address target, bytes memory data) = getTargetAndPayload(middleware);
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

    function runScheduleAndExecute(address network, address middleware, bytes32 salt) public {
        runSchedule(network, middleware, 0, salt);
        runExecute(network, middleware, salt);
    }

    function getTargetAndPayload(
        address middleware
    ) public view returns (address target, bytes memory payload) {
        target = address(SymbioticCoreConstants.core().networkMiddlewareService);
        payload = abi.encodeCall(INetworkMiddlewareService.setMiddleware, (middleware));
    }
}
