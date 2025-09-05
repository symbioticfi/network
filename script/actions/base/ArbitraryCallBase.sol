// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./ActionBase.sol";

contract ArbitraryCallBase is ActionBase {
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

    function runScheduleAndExecute(address network, address target, bytes memory data, bytes32 salt) public {
        runSchedule(network, target, data, 0, salt);
        runExecute(network, target, data, salt);
    }
}
