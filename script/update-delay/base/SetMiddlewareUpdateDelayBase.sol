// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../../actions/base/ActionBase.sol";
import {Network} from "../../../src/Network.sol";
import {INetwork} from "../../../src/interfaces/INetwork.sol";
import {ITimelockAction} from "../../actions/interfaces/ITimelockAction.sol";

import {SymbioticCoreConstants} from "@symbioticfi/core/test/integration/SymbioticCoreConstants.sol";
import {INetworkMiddlewareService} from "@symbioticfi/core/src/interfaces/service/INetworkMiddlewareService.sol";

contract SetMiddlewareUpdateDelayBase is ActionBase, ITimelockAction {
    address public network;
    uint256 public setMiddlewareDelay;
    uint256 public delay;
    bytes32 public salt;

    constructor(address network_, uint256 setMiddlewareDelay_, uint256 delay_, bytes32 salt_) {
        network = network_;
        setMiddlewareDelay = setMiddlewareDelay_;
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
                "Scheduled setMiddlewareUpdateDelay for",
                "\n    network:",
                vm.toString(network),
                "\n    setMiddlewareDelay:",
                vm.toString(setMiddlewareDelay),
                "\n    delay:",
                vm.toString(delay),
                "\n    salt:",
                vm.toString(salt)
            )
        );
    }

    function runExecute() public {
        (address delegator, bytes memory payload) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: network,
                isExecutionMode: true,
                target: delegator,
                data: payload,
                delay: 0,
                salt: salt
            })
        );

        log(
            string.concat(
                "Executed setMiddlewareUpdateDelay for",
                "\n    network:",
                vm.toString(network),
                "\n    setMiddlewareDelay:",
                vm.toString(setMiddlewareDelay),
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

    function getTargetAndPayload() public view returns (address target, bytes memory payload) {
        target = network;

        SymbioticCoreConstants.Core memory core = SymbioticCoreConstants.core();
        payload = abi.encodeCall(
            INetwork.updateDelay,
            (
                address(core.networkMiddlewareService),
                INetworkMiddlewareService.setMiddleware.selector,
                true,
                setMiddlewareDelay
            )
        );
    }
}
