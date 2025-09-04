pragma solidity ^0.8.25;

import {TimelockBase} from "./TimelockBase.sol";
import {Network} from "../../src/contracts/Network.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract SetMaxNetworkLimit is TimelockBase {
    function runSchedule(
        address payable network,
        address delegator,
        uint96 subnetworkId,
        uint256 maxNetworkLimit,
        uint256 delay,
        string memory seed
    ) public {
        bytes memory data =
            abi.encodeCall(Network(network).setMaxNetworkLimit, (delegator, subnetworkId, maxNetworkLimit));

        TimelockBase.TimelockParams memory params = TimelockBase.TimelockParams({
            network: Network(network),
            isExecutionMode: false,
            target: network,
            data: data,
            delay: delay,
            seed: seed
        });

        callTimelock(params);

        string memory log = string.concat(
            "\nScheduled setMaxNetworkLimit for",
            " network:",
            Strings.toHexString(network),
            " delegator:",
            Strings.toHexString(delegator),
            " subnetworkId:",
            Strings.toString(subnetworkId),
            " maxNetworkLimit ",
            Strings.toString(maxNetworkLimit),
            " delay:",
            Strings.toString(delay),
            " seed:",
            seed
        );

        logCall(log);
    }

    function runExecute(
        address payable network,
        address delegator,
        uint96 subnetworkId,
        uint256 maxNetworkLimit,
        string memory seed
    ) public {
        bytes memory data =
            abi.encodeCall(Network(network).setMaxNetworkLimit, (delegator, subnetworkId, maxNetworkLimit));

        TimelockBase.TimelockParams memory params = TimelockBase.TimelockParams({
            network: Network(network),
            isExecutionMode: true,
            target: network,
            data: data,
            delay: 0,
            seed: seed
        });

        vm.warp(block.timestamp + 100);
        callTimelock(params);

        string memory log = string.concat(
            "\nExecuted setMaxNetworkLimit for",
            " network:",
            Strings.toHexString(network),
            " delegator:",
            Strings.toHexString(delegator),
            " subnetworkId:",
            Strings.toString(subnetworkId),
            " maxNetworkLimit ",
            Strings.toString(maxNetworkLimit),
            " seed:",
            seed
        );

        logCall(log);
    }
}
