// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {Network} from "../../src/contracts/Network.sol";

contract TimelockBase is Script {
    string internal constant LOG_FILE = "script/timelocked/callLog.txt";

    struct TimelockParams {
        address network;
        bool isExecutionMode;
        address target;
        bytes data;
        uint256 delay;
        string seed;
    }

    function callTimelock(
        TimelockParams memory params
    ) internal {
        bytes32 salt = keccak256(abi.encode(params.seed));
        bytes32 predecessor;
        vm.startBroadcast();

        if (params.isExecutionMode) {
            Network(payable(params.network)).execute(params.target, 0, params.data, predecessor, salt);
        } else {
            Network(payable(params.network)).schedule(params.target, 0, params.data, predecessor, salt, params.delay);
        }

        vm.stopBroadcast();
    }

    function logCall(
        string memory data
    ) internal {
        string memory log = vm.readFile(LOG_FILE);
        log = string.concat(log, data);
        vm.writeFile(LOG_FILE, log);
    }
}
