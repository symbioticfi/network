// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./ActionBase.sol";
import {Network} from "../../../src/Network.sol";

import {IBaseDelegator} from "@symbioticfi/core/src/interfaces/delegator/IBaseDelegator.sol";
import {IVault} from "@symbioticfi/core/src/interfaces/vault/IVault.sol";
import {Subnetwork} from "@symbioticfi/core/src/contracts/libraries/Subnetwork.sol";
import {ITimelockAction} from "../interfaces/ITimelockAction.sol";

contract SetMaxNetworkLimitBase is ActionBase, ITimelockAction {
    using Subnetwork for address;

    address public network;
    address public vault;
    uint96 public subnetworkId;
    uint256 public maxNetworkLimit;
    uint256 public delay;
    bytes32 public salt;

    constructor(
        address network_,
        address vault_,
        uint96 subnetworkId_,
        uint256 maxNetworkLimit_,
        uint256 delay_,
        bytes32 salt_
    ) {
        network = network_;
        vault = vault_;
        subnetworkId = subnetworkId_;
        maxNetworkLimit = maxNetworkLimit_;
        delay = delay_;
        salt = salt_;
    }

    function runSchedule() public {
        (address delegator, bytes memory payload) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: network,
                isExecutionMode: false,
                target: delegator,
                data: payload,
                delay: delay,
                salt: salt
            })
        );

        log(
            string.concat(
                "Scheduled setMaxNetworkLimit for",
                "\n    network:",
                vm.toString(network),
                "\n    delegator:",
                vm.toString(delegator),
                "\n    subnetworkId:",
                vm.toString(subnetworkId),
                "\n    maxNetworkLimit ",
                vm.toString(maxNetworkLimit),
                "\n    delay:",
                vm.toString(delay),
                "\n    salt:",
                vm.toString(salt)
            )
        );
    }

    function runExecute() public {
        (address delegator, bytes memory payload) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: network,
                isExecutionMode: true,
                target: delegator,
                data: payload,
                delay: 0,
                salt: salt
            })
        );

        log(
            string.concat(
                "Executed setMaxNetworkLimit for",
                "\n    network:",
                vm.toString(network),
                "\n    delegator:",
                vm.toString(delegator),
                "\n    subnetworkId:",
                vm.toString(subnetworkId),
                "\n    maxNetworkLimit ",
                vm.toString(maxNetworkLimit),
                "\n    salt:",
                vm.toString(salt)
            )
        );

        assert(IBaseDelegator(delegator).maxNetworkLimit(network.subnetwork(subnetworkId)) == maxNetworkLimit);
    }

    function runScheduleAndExecute() public {
        runSchedule();
        runExecute();
    }

    function getTargetAndPayload() public view returns (address target, bytes memory payload) {
        target = IVault(vault).delegator();
        payload = abi.encodeCall(IBaseDelegator.setMaxNetworkLimit, (subnetworkId, maxNetworkLimit));
    }
}
