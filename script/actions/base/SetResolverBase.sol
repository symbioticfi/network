// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./ActionBase.sol";

import {IVetoSlasher} from "@symbioticfi/core/src/interfaces/slasher/IVetoSlasher.sol";
import {IVault} from "@symbioticfi/core/src/interfaces/vault/IVault.sol";
import {Subnetwork} from "@symbioticfi/core/src/contracts/libraries/Subnetwork.sol";
import {ITimelockAction} from "../interfaces/ITimelockAction.sol";

contract SetResolverBase is ActionBase, ITimelockAction {
    using Subnetwork for address;

    struct SetResolverParams {
        address network;
        address vault;
        uint96 identifier;
        address resolver;
        bytes hints;
        uint256 delay;
        bytes32 salt;
    }

    SetResolverParams public params;

    constructor(SetResolverParams memory params_) {
        params = params_;
    }

    function runSchedule() public {
        (address target, bytes memory data) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: params.network,
                isExecutionMode: false,
                target: target,
                data: data,
                delay: params.delay,
                salt: params.salt
            })
        );

        log(
            string.concat(
                "Scheduled setResolver for",
                "\n    network:",
                vm.toString(params.network),
                "\n    vault:",
                vm.toString(params.vault),
                "\n    identifier:",
                vm.toString(params.identifier),
                "\n    resolver:",
                vm.toString(params.resolver),
                "\n    delay:",
                vm.toString(params.delay),
                "\n    salt:",
                vm.toString(params.salt)
            )
        );
    }

    function runExecute() public {
        (address target, bytes memory data) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: params.network, isExecutionMode: true, target: target, data: data, delay: 0, salt: params.salt
            })
        );

        log(
            string.concat(
                "Executed setResolver for",
                "\n    network:",
                vm.toString(params.network),
                "\n    vault:",
                vm.toString(params.vault),
                "\n    identifier:",
                vm.toString(params.identifier),
                "\n    resolver:",
                vm.toString(params.resolver),
                "\n    salt:",
                vm.toString(params.salt)
            )
        );

        assert(
            IVetoSlasher(IVault(params.vault).slasher())
                    .resolver(params.network.subnetwork(params.identifier), bytes("")) == params.resolver
        );
    }

    function runScheduleAndExecute() public {
        runSchedule();
        runExecute();
    }

    function getTargetAndPayload() public view returns (address target, bytes memory payload) {
        target = IVault(params.vault).slasher();
        payload = abi.encodeCall(IVetoSlasher.setResolver, (params.identifier, params.resolver, params.hints));
    }
}
