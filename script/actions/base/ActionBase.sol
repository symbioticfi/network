// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";

import "../../base/Logs.sol";

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
        address[] targets;
        bytes[] payloads;
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
        bytes32 id = timelockController.hashOperation(params.target, 0, params.data, predecessor, params.salt);
        if (params.isExecutionMode) {
            assert(timelockController.isOperationDone(id) == true);
        } else {
            assert(timelockController.isOperationPending(id) == true);
        }
    }

    function callTimelockBatch(
        TimelockBatchParams memory params
    ) internal {
        // Validate that all arrays have the same length
        require(params.targets.length == params.payloads.length, "TimelockBatchParams: arrays length mismatch");
        require(params.targets.length > 0, "TimelockBatchParams: empty batch");

        vm.startBroadcast();

        bytes32 predecessor;

        // Create values array filled with zeros
        uint256[] memory values = new uint256[](params.targets.length);

        bytes memory callData = params.isExecutionMode
            ? abi.encodeCall(
                TimelockController.executeBatch, (params.targets, values, params.payloads, predecessor, params.salt)
            )
            : abi.encodeCall(
                TimelockController.scheduleBatch,
                (params.targets, values, params.payloads, predecessor, params.salt, params.delay)
            );
        params.network.functionCall(callData);

        log(
            string.concat(
                "Called network batch",
                "\n    network:",
                vm.toString(params.network),
                "\n    batch size:",
                vm.toString(params.targets.length),
                "\n    callData:",
                vm.toString(callData)
            )
        );

        vm.stopBroadcast();

        TimelockController timelockController = TimelockController(payable(params.network));
        bytes32 id =
            timelockController.hashOperationBatch(params.targets, values, params.payloads, predecessor, params.salt);
        if (params.isExecutionMode) {
            assert(timelockController.isOperationDone(id) == true);
        } else {
            assert(timelockController.isOperationPending(id) == true);
        }
    }
}
