// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./ActionBase.sol";

contract ArbitraryCallBase is ActionBase {
    struct ArbitraryCallParams {
        address network;
        address target;
        bytes data;
        uint256 delay;
        bytes32 salt;
    }

    ArbitraryCallParams public params;

    constructor(
        ArbitraryCallParams memory params_
    ) {
        params = params_;
    }

    function runSchedule() public {
        callTimelock(
            ActionBase.TimelockParams({
                network: params.network,
                isExecutionMode: false,
                target: params.target,
                data: params.data,
                delay: params.delay,
                salt: params.salt
            })
        );

        log(
            string.concat(
                "Scheduled arbitrary call for",
                "\n    network:",
                vm.toString(params.network),
                "\n    target:",
                vm.toString(params.target),
                "\n    data:",
                vm.toString(params.data),
                "\n    delay:",
                vm.toString(params.delay),
                "\n    salt:",
                vm.toString(params.salt)
            )
        );
    }

    function runExecute() public {
        callTimelock(
            ActionBase.TimelockParams({
                network: params.network,
                isExecutionMode: true,
                target: params.target,
                data: params.data,
                delay: 0,
                salt: params.salt
            })
        );

        log(
            string.concat(
                "Executed arbitrary call for",
                "\n    network:",
                vm.toString(params.network),
                "\n    target:",
                vm.toString(params.target),
                "\n    data:",
                vm.toString(params.data),
                "\n    salt:",
                vm.toString(params.salt)
            )
        );
    }

    function runScheduleAndExecute() public {
        runSchedule();
        runExecute();
    }
}
