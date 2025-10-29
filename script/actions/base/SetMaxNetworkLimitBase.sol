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

    struct SetMaxNetworkLimitParams {
        address network;
        address vault;
        uint96 subnetworkId;
        uint256 maxNetworkLimit;
        uint256 delay;
        bytes32 salt;
    }

    SetMaxNetworkLimitParams public params;

    constructor(SetMaxNetworkLimitParams memory params_) {
        params = params_;
    }

    function runSchedule() public {
        (address delegator, bytes memory payload) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: params.network,
                isExecutionMode: false,
                target: delegator,
                data: payload,
                delay: params.delay,
                salt: params.salt
            })
        );

        log(
            string.concat(
                "Scheduled setMaxNetworkLimit for",
                "\n    network:",
                vm.toString(params.network),
                "\n    delegator:",
                vm.toString(delegator),
                "\n    subnetworkId:",
                vm.toString(params.subnetworkId),
                "\n    maxNetworkLimit ",
                vm.toString(params.maxNetworkLimit),
                "\n    delay:",
                vm.toString(params.delay),
                "\n    salt:",
                vm.toString(params.salt)
            )
        );
    }

    function runExecute() public {
        (address delegator, bytes memory payload) = getTargetAndPayload();
        callTimelock(
            ActionBase.TimelockParams({
                network: params.network,
                isExecutionMode: true,
                target: delegator,
                data: payload,
                delay: 0,
                salt: params.salt
            })
        );

        log(
            string.concat(
                "Executed setMaxNetworkLimit for",
                "\n    network:",
                vm.toString(params.network),
                "\n    delegator:",
                vm.toString(delegator),
                "\n    subnetworkId:",
                vm.toString(params.subnetworkId),
                "\n    maxNetworkLimit ",
                vm.toString(params.maxNetworkLimit),
                "\n    salt:",
                vm.toString(params.salt)
            )
        );

        assert(
            IBaseDelegator(delegator).maxNetworkLimit(params.network.subnetwork(params.subnetworkId))
                == params.maxNetworkLimit
        );
    }

    function runScheduleAndExecute() public {
        runSchedule();
        runExecute();
    }

    function getTargetAndPayload() public view returns (address target, bytes memory payload) {
        target = IVault(params.vault).delegator();
        payload = abi.encodeCall(IBaseDelegator.setMaxNetworkLimit, (params.subnetworkId, params.maxNetworkLimit));
    }
}
