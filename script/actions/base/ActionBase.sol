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
    }
}
