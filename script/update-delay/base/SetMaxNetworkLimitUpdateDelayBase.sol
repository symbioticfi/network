// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../../actions/base/ActionBase.sol";
import {Network} from "../../../src/Network.sol";
import {INetwork} from "../../../src/interfaces/INetwork.sol";

import {IBaseDelegator} from "@symbioticfi/core/src/interfaces/delegator/IBaseDelegator.sol";
import {IVault} from "@symbioticfi/core/src/interfaces/vault/IVault.sol";
import {Subnetwork} from "@symbioticfi/core/src/contracts/libraries/Subnetwork.sol";
import {ITimelockAction} from "../../actions/interfaces/ITimelockAction.sol";

contract SetMaxNetworkLimitUpdateDelayBase is ActionBase, ITimelockAction {
    address public network;
    uint256 public setMaxNetworkLimitDelay;
    uint256 public delay;
    bytes32 public salt;

    constructor(address network_, uint256 setMaxNetworkLimitDelay_, uint256 delay_, bytes32 salt_) {
        network = network_;
        setMaxNetworkLimitDelay = setMaxNetworkLimitDelay_;
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
                "Scheduled setMaxNetworkLimitUpdateDelay for",
                "\n    network:",
                vm.toString(network),
                "\n    setMaxNetworkLimitDelay:",
                vm.toString(setMaxNetworkLimitDelay),
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
                "Executed setMaxNetworkLimitUpdateDelay for",
                "\n    network:",
                vm.toString(network),
                "\n    setMaxNetworkLimitDelay:",
                vm.toString(setMaxNetworkLimitDelay),
                "\n    delay:",
                vm.toString(delay),
                "\n    salt:",
                vm.toString(salt)
            )
        );

        assert(
            INetwork(network).getMinDelay(address(1), abi.encodePacked(IBaseDelegator.setMaxNetworkLimit.selector))
                == setMaxNetworkLimitDelay
        );
    }

    function runScheduleAndExecute() public {
        runSchedule();
        runExecute();
    }

    function getTargetAndPayload() public view returns (address target, bytes memory payload) {
        target = network;
        payload = abi.encodeCall(
            INetwork.updateDelay,
            (address(0), IBaseDelegator.setMaxNetworkLimit.selector, true, setMaxNetworkLimitDelay)
        );
    }
}
