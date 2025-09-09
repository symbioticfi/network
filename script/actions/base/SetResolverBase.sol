// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./ActionBase.sol";

import {IVetoSlasher} from "@symbioticfi/core/src/interfaces/slasher/IVetoSlasher.sol";
import {IVault} from "@symbioticfi/core/src/interfaces/vault/IVault.sol";
import {Subnetwork} from "@symbioticfi/core/src/contracts/libraries/Subnetwork.sol";
import {ITimelockAction} from "../interfaces/ITimelockAction.sol";

contract SetResolverBase is ActionBase, ITimelockAction {
    using Subnetwork for address;

    address public network;
    address public vault;
    uint96 public identifier;
    address public resolver;
    uint256 public delay;
    bytes32 public salt;
    bytes public hints;

    constructor(
        address network_,
        address vault_,
        uint96 identifier_,
        address resolver_,
        bytes memory hints_,
        uint256 delay_,
        bytes32 salt_
    ) {
        network = network_;
        vault = vault_;
        identifier = identifier_;
        resolver = resolver_;
        hints = hints_;
        delay = delay_;
        salt = salt_;
    }

    function runSchedule() public {
        (address target, bytes memory data) = getTargetAndPayload();
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

    function runExecute() public {
        (address target, bytes memory data) = getTargetAndPayload();
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

    function runScheduleAndExecute() public {
        runSchedule();
        runExecute();
    }

    function getTargetAndPayload() public view returns (address target, bytes memory payload) {
        target = IVault(vault).slasher();
        payload = abi.encodeCall(IVetoSlasher.setResolver, (identifier, resolver, hints));
    }
}
