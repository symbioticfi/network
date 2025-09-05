// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./ActionBase.sol";

import {IVetoSlasher} from "@symbioticfi/core/src/interfaces/slasher/IVetoSlasher.sol";
import {IVault} from "@symbioticfi/core/src/interfaces/vault/IVault.sol";
import {Subnetwork} from "@symbioticfi/core/src/contracts/libraries/Subnetwork.sol";

contract SetResolverBase is ActionBase {
    using Subnetwork for address;

    function runSchedule(
        address network,
        address vault,
        uint96 identifier,
        address resolver,
        bytes memory hints,
        uint256 delay,
        bytes32 salt
    ) public {
        callTimelock(
            ActionBase.TimelockParams({
                network: network,
                isExecutionMode: false,
                target: IVault(vault).slasher(),
                data: abi.encodeCall(IVetoSlasher.setResolver, (identifier, resolver, hints)),
                delay: delay,
                salt: salt
            })
        );

        log(
            string.concat(
                "Scheduled setResolver for",
                "\n    network:",
                vm.toString(network),
                "\n    vault:",
                vm.toString(vault),
                "\n    identifier:",
                vm.toString(identifier),
                "\n    resolver:",
                vm.toString(resolver),
                "\n    delay:",
                vm.toString(delay),
                "\n    salt:",
                vm.toString(salt)
            )
        );
    }

    function runExecute(
        address network,
        address vault,
        uint96 identifier,
        address resolver,
        bytes memory hints,
        bytes32 salt
    ) public {
        callTimelock(
            ActionBase.TimelockParams({
                network: network,
                isExecutionMode: true,
                target: IVault(vault).slasher(),
                data: abi.encodeCall(IVetoSlasher.setResolver, (identifier, resolver, hints)),
                delay: 0,
                salt: salt
            })
        );

        log(
            string.concat(
                "Executed setResolver for",
                "\n    network:",
                vm.toString(network),
                "\n    vault:",
                vm.toString(vault),
                "\n    identifier:",
                vm.toString(identifier),
                "\n    resolver:",
                vm.toString(resolver),
                "\n    salt:",
                vm.toString(salt)
            )
        );

        assert(IVetoSlasher(IVault(vault).slasher()).resolver(network.subnetwork(identifier), bytes("")) == resolver);
    }

    function runScheduleAndExecute(
        address network,
        address vault,
        uint96 identifier,
        address resolver,
        bytes memory hints,
        bytes32 salt
    ) public {
        runSchedule(network, vault, identifier, resolver, hints, 0, salt);
        runExecute(network, vault, identifier, resolver, hints, salt);
    }
}
