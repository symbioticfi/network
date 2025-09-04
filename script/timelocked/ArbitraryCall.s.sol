// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {TimelockBase} from "./TimelockBase.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract ArbitraryCall is TimelockBase {
    /**
     * @notice Schedule an arbitrary function call through the timelock
     * @param network The network contract address
     * @param target The target contract address to call
     * @param data The encoded function call data
     * @param delay The delay before execution (in seconds)
     * @param seed A unique seed for the operation
     */
    function runSchedule(
        address network,
        address target,
        bytes memory data,
        uint256 delay,
        string memory seed
    ) public {
        TimelockBase.TimelockParams memory params = TimelockBase.TimelockParams({
            network: network,
            isExecutionMode: false,
            target: target,
            data: data,
            delay: delay,
            seed: seed
        });

        callTimelock(params);

        string memory log = string.concat(
            "\nScheduled arbitrary call for",
            " network:",
            Strings.toHexString(network),
            " target:",
            Strings.toHexString(target),
            " data:",
            string(data),
            " delay:",
            Strings.toString(delay),
            " seed:",
            seed
        );

        logCall(log);
    }

    /**
     * @notice Execute an arbitrary function call immediately through the timelock
     * @param network The network contract address
     * @param target The target contract address to call
     * @param data The encoded function call data
     * @param seed A unique seed for the operation
     */
    function runExecute(address network, address target, bytes memory data, string memory seed) public {
        TimelockBase.TimelockParams memory params = TimelockBase.TimelockParams({
            network: network,
            isExecutionMode: true,
            target: target,
            data: data,
            delay: 0,
            seed: seed
        });

        callTimelock(params);

        string memory log = string.concat(
            "\nExecuted arbitrary call for",
            " network:",
            Strings.toHexString(network),
            " target:",
            Strings.toHexString(target),
            " data:",
            string(data),
            " seed:",
            seed
        );

        logCall(log);
    }

    /**
     * @notice Schedule a function call with encoded parameters
     * @param network The network contract address
     * @param target The target contract address to call
     * @param functionSelector The function selector (4 bytes)
     * @param encodedParams The encoded function parameters
     * @param delay The delay before execution (in seconds)
     * @param seed A unique seed for the operation
     */
    function runScheduleWithParams(
        address network,
        address target,
        bytes4 functionSelector,
        bytes memory encodedParams,
        uint256 delay,
        string memory seed
    ) public {
        bytes memory data = abi.encodePacked(functionSelector, encodedParams);

        runSchedule(network, target, data, delay, seed);
    }

    /**
     * @notice Execute a function call with encoded parameters immediately
     * @param network The network contract address
     * @param target The target contract address to call
     * @param functionSelector The function selector (4 bytes)
     * @param encodedParams The encoded function parameters
     * @param seed A unique seed for the operation
     */
    function runExecuteWithParams(
        address network,
        address target,
        bytes4 functionSelector,
        bytes memory encodedParams,
        string memory seed
    ) public {
        bytes memory data = abi.encodePacked(functionSelector, encodedParams);

        runExecute(network, target, data, seed);
    }

    /**
     * @notice Helper function to encode a function call with parameters
     * @param functionSelector The function selector (4 bytes)
     * @param params The function parameters to encode
     * @return The encoded function call data
     */
    function encodeFunctionCall(bytes4 functionSelector, bytes memory params) public pure returns (bytes memory) {
        return abi.encodePacked(functionSelector, params);
    }
}
