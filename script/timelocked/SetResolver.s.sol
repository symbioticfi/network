pragma solidity ^0.8.25;

import {TimelockBase} from "./TimelockBase.sol";

import {IVetoSlasher} from "@symbioticfi/core/src/interfaces/slasher/IVetoSlasher.sol";
import {IVault} from "@symbioticfi/core/src/interfaces/vault/IVault.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract SetResolver is TimelockBase {
    function runSchedule(
        address network,
        address vault,
        uint96 identifier,
        address resolver,
        bytes memory hints,
        uint256 delay,
        string memory seed
    ) public {
        address slasher = IVault(vault).slasher();
        bytes memory data = abi.encodeCall(IVetoSlasher(slasher).setResolver, (identifier, resolver, hints));

        TimelockBase.TimelockParams memory params = TimelockBase.TimelockParams({
            network: network,
            isExecutionMode: false,
            target: slasher,
            data: data,
            delay: delay,
            seed: seed
        });

        callTimelock(params);

        string memory log = string.concat(
            "\nScheduled setResolver for",
            " network:",
            Strings.toHexString(network),
            " vault:",
            Strings.toHexString(vault),
            " identifier:",
            Strings.toString(identifier),
            " resolver:",
            Strings.toHexString(resolver),
            " delay:",
            Strings.toString(delay),
            " seed:",
            seed
        );

        logCall(log);
    }

    function runExecute(
        address network,
        address vault,
        uint96 identifier,
        address resolver,
        bytes memory hints,
        string memory seed
    ) public {
        address slasher = IVault(vault).slasher();
        bytes memory data = abi.encodeCall(IVetoSlasher(slasher).setResolver, (identifier, resolver, hints));

        TimelockBase.TimelockParams memory params = TimelockBase.TimelockParams({
            network: network,
            isExecutionMode: true,
            target: slasher,
            data: data,
            delay: 0,
            seed: seed
        });

        callTimelock(params);

        string memory log = string.concat(
            "\nExecuted setResolver for",
            " network:",
            Strings.toHexString(network),
            " vault:",
            Strings.toHexString(vault),
            " identifier:",
            Strings.toString(identifier),
            " resolver:",
            Strings.toHexString(resolver),
            " seed:",
            seed
        );

        logCall(log);
    }
}
