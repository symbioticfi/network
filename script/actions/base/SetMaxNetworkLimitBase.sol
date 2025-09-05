// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./ActionBase.sol";
import {Network} from "../../../src/Network.sol";

import {IBaseDelegator} from "@symbioticfi/core/src/interfaces/delegator/IBaseDelegator.sol";
import {IVault} from "@symbioticfi/core/src/interfaces/vault/IVault.sol";
import {Subnetwork} from "@symbioticfi/core/src/contracts/libraries/Subnetwork.sol";

contract SetMaxNetworkLimitBase is ActionBase {
    using Subnetwork for address;

    function runSchedule(
        address network,
        address vault,
        uint96 subnetworkId,
        uint256 maxNetworkLimit,
        uint256 delay,
        bytes32 salt
    ) public {
        address delegator = IVault(vault).delegator();
        callTimelock(
            ActionBase.TimelockParams({
                network: network,
                isExecutionMode: false,
                target: delegator,
                data: abi.encodeCall(IBaseDelegator.setMaxNetworkLimit, (subnetworkId, maxNetworkLimit)),
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

    function runExecute(
        address network,
        address vault,
        uint96 subnetworkId,
        uint256 maxNetworkLimit,
        bytes32 salt
    ) public {
        address delegator = IVault(vault).delegator();
        callTimelock(
            ActionBase.TimelockParams({
                network: network,
                isExecutionMode: true,
                target: delegator,
                data: abi.encodeCall(IBaseDelegator.setMaxNetworkLimit, (subnetworkId, maxNetworkLimit)),
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
}
