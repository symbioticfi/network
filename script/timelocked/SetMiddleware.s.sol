pragma solidity ^0.8.25;

import {TimelockBase} from "./TimelockBase.sol";
import {Network} from "../../src/contracts/Network.sol";

import {INetworkMiddlewareService} from "@symbioticfi/core/src/interfaces/service/INetworkMiddlewareService.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract SetMiddleware is TimelockBase {
    function runSchedule(address network, address middleware, uint256 delay, string memory seed) public {
        address networkMiddlewareService = Network(payable(network)).NETWORK_MIDDLEWARE_SERVICE();
        bytes memory data =
            abi.encodeCall(INetworkMiddlewareService(networkMiddlewareService).setMiddleware, (middleware));

        TimelockBase.TimelockParams memory params = TimelockBase.TimelockParams({
            network: network,
            isExecutionMode: false,
            target: networkMiddlewareService,
            data: data,
            delay: delay,
            seed: seed
        });

        callTimelock(params);

        string memory log = string.concat(
            "\nScheduled setMiddleware for",
            " network:",
            Strings.toHexString(network),
            " middleware:",
            Strings.toHexString(middleware),
            " delay:",
            Strings.toString(delay),
            " seed:",
            seed
        );

        logCall(log);
    }

    function runExecute(address network, address middleware, string memory seed) public {
        address networkMiddlewareService = Network(payable(network)).NETWORK_MIDDLEWARE_SERVICE();
        bytes memory data =
            abi.encodeCall(INetworkMiddlewareService(networkMiddlewareService).setMiddleware, (middleware));

        TimelockBase.TimelockParams memory params = TimelockBase.TimelockParams({
            network: network,
            isExecutionMode: true,
            target: networkMiddlewareService,
            data: data,
            delay: 0,
            seed: seed
        });

        callTimelock(params);

        string memory log = string.concat(
            "\nExecuted setMiddleware for",
            " network:",
            Strings.toHexString(network),
            " middleware:",
            Strings.toHexString(middleware),
            " seed:",
            seed
        );

        logCall(log);
    }
}
