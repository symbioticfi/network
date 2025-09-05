// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./ActionBase.sol";

contract ArbitraryCallBase is ActionBase {
    /**
     * @notice Schedule an arbitrary function call through the timelock
     * @param network The network contract address
     * @param target The target contract address to call
     * @param data The encoded function call data
     * @param delay The delay before execution (in seconds)
     * @param salt A unique salt for the operation
     */
    function runSchedule(address network, address target, bytes memory data, uint256 delay, bytes32 salt) public {
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
                "Scheduled arbitrary call for",
                "\n    network:",
                vm.toString(network),
                "\n    target:",
                vm.toString(target),
                "\n    data:",
                vm.toString(data),
                "\n    delay:",
                vm.toString(delay),
                "\n    salt:",
                vm.toString(salt)
            )
        );
    }

    /**
     * @notice Execute an arbitrary function call immediately through the timelock
     * @param network The network contract address
     * @param target The target contract address to call
     * @param data The encoded function call data
     * @param salt A unique salt for the operation
     */
    function runExecute(address network, address target, bytes memory data, bytes32 salt) public {
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
                "Executed arbitrary call for",
                "\n    network:",
                vm.toString(network),
                "\n    target:",
                vm.toString(target),
                "\n    data:",
                vm.toString(data),
                "\n    salt:",
                vm.toString(salt)
            )
        );
    }

    /**
     * @notice Schedule a function call with encoded parameters
     * @param network The network contract address
     * @param target The target contract address to call
     * @param functionSelector The function selector (4 bytes)
     * @param encodedParams The encoded function parameters
     * @param delay The delay before execution (in seconds)
     * @param salt A unique salt for the operation
     */
    function runScheduleWithParams(
        address network,
        address target,
        bytes4 functionSelector,
        bytes memory encodedParams,
        uint256 delay,
        bytes32 salt
    ) public {
        bytes memory data = abi.encodePacked(functionSelector, encodedParams);

        runSchedule(network, target, data, delay, salt);
    }

    /**
     * @notice Execute a function call with encoded parameters immediately
     * @param network The network contract address
     * @param target The target contract address to call
     * @param functionSelector The function selector (4 bytes)
     * @param encodedParams The encoded function parameters
     * @param salt A unique salt for the operation
     */
    function runExecuteWithParams(
        address network,
        address target,
        bytes4 functionSelector,
        bytes memory encodedParams,
        bytes32 salt
    ) public {
        bytes memory data = abi.encodePacked(functionSelector, encodedParams);

        runExecute(network, target, data, salt);
    }
}
