// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";

import "../../base/Logs.sol";
import {ITimelockAction} from "../interfaces/ITimelockAction.sol";

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

contract ActionBase is Script, Logs {
    using Address for address;

    struct TimelockParams {
        address network;
        bool isExecutionMode;
        address target;
        bytes data;
        uint256 delay;
        bytes32 salt;
    }

    struct TimelockBatchParams {
        address network;
        bool isExecutionMode;
        ITimelockAction[] actions;
        uint256 delay;
        bytes32 salt;
    }

    function callTimelock(
        TimelockParams memory params
    ) internal {
        vm.startBroadcast();

        bytes32 predecessor;

        bytes memory callData = params.isExecutionMode
            ? abi.encodeCall(TimelockController.execute, (params.target, 0, params.data, predecessor, params.salt))
            : abi.encodeCall(
                TimelockController.schedule, (params.target, 0, params.data, predecessor, params.salt, params.delay)
            );
        params.network.functionCall(callData);

        log(
            string.concat(
                "Called network",
                "\n    network:",
                vm.toString(params.network),
                "\n    callData:",
                vm.toString(callData)
            )
        );

        vm.stopBroadcast();

        TimelockController timelockController = TimelockController(payable(params.network));
        try timelockController.hashOperation(params.target, 0, params.data, predecessor, params.salt) returns (
            bytes32 id
        ) {
            if (params.isExecutionMode) {
                assert(timelockController.isOperationDone(id) == true);
            } else {
                assert(timelockController.isOperationPending(id) == true);
            }
        } catch {}
    }

    function callTimelockBatch(
        TimelockBatchParams memory params
    ) internal {
        assert(params.actions.length > 0);
        address[] memory targets = new address[](params.actions.length);
        bytes[] memory payloads = new bytes[](params.actions.length);
        for (uint256 i; i < params.actions.length; ++i) {
            (address target, bytes memory payload) = params.actions[i].getTargetAndPayload();
            targets[i] = target;
            payloads[i] = payload;
        }

        vm.startBroadcast();

        bytes32 predecessor;

        // Create values array filled with zeros
        uint256[] memory values = new uint256[](targets.length);

        bytes memory callData = params.isExecutionMode
            ? abi.encodeCall(TimelockController.executeBatch, (targets, values, payloads, predecessor, params.salt))
            : abi.encodeCall(
                TimelockController.scheduleBatch, (targets, values, payloads, predecessor, params.salt, params.delay)
            );
        params.network.functionCall(callData);

        log(
            string.concat(
                "Called network batch",
                "\n    network:",
                vm.toString(params.network),
                "\n    batch size:",
                vm.toString(targets.length),
                "\n    callData:",
                vm.toString(callData)
            )
        );

        vm.stopBroadcast();

        TimelockController timelockController = TimelockController(payable(params.network));
        try timelockController.hashOperationBatch(targets, values, payloads, predecessor, params.salt) returns (
            bytes32 id
        ) {
            if (params.isExecutionMode) {
                assert(timelockController.isOperationDone(id) == true);
            } else {
                assert(timelockController.isOperationPending(id) == true);
            }
        } catch {}
    }
}
