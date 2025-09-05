// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {DeployNetworkBase} from "./DeployNetworkBase.sol";
import {Network} from "../../src/Network.sol";
import {INetwork} from "../../src/interfaces/INetwork.sol";

import {IVault} from "@symbioticfi/core/src/interfaces/vault/IVault.sol";
import {IBaseDelegator} from "@symbioticfi/core/src/interfaces/delegator/IBaseDelegator.sol";
import {IVetoSlasher} from "@symbioticfi/core/src/interfaces/slasher/IVetoSlasher.sol";
import {Subnetwork} from "@symbioticfi/core/src/contracts/libraries/Subnetwork.sol";

import {AccessControl} from "openzeppelin-contracts/contracts/access/AccessControl.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

contract DeployNetworkForVaultBase is DeployNetworkBase {
    using Subnetwork for address;

    struct DeployNetworkForVaultParams {
        DeployNetworkParams deployNetworkParams;
        address vault;
        uint96 subnetworkId;
        uint256 maxNetworkLimit;
        address resolver;
    }

    function run(
        DeployNetworkForVaultParams memory params
    ) public returns (address) {
        vm.startBroadcast();

        (,, address deployer) = vm.readCallers();

        bool isDeployerProposer;
        {
            address[] memory tempProposers = new address[](params.deployNetworkParams.proposers.length + 1);
            for (uint256 i; i < params.deployNetworkParams.proposers.length; ++i) {
                tempProposers[i] = params.deployNetworkParams.proposers[i];
                if (tempProposers[i] == deployer) {
                    isDeployerProposer = true;
                    break;
                }
            }
            if (!isDeployerProposer) {
                tempProposers[tempProposers.length - 1] = deployer;
                params.deployNetworkParams.proposers = tempProposers;
            }
        }

        bool isDeployerExecutor;
        {
            address[] memory tempExecutors = new address[](params.deployNetworkParams.executors.length + 1);
            for (uint256 i; i < params.deployNetworkParams.executors.length; ++i) {
                tempExecutors[i] = params.deployNetworkParams.executors[i];
                if (tempExecutors[i] == deployer) {
                    isDeployerExecutor = true;
                    break;
                }
            }
            if (!isDeployerExecutor) {
                tempExecutors[tempExecutors.length - 1] = deployer;
                params.deployNetworkParams.executors = tempExecutors;
            }
        }

        uint256 originalGlobalMinDelay = params.deployNetworkParams.globalMinDelay;
        params.deployNetworkParams.globalMinDelay = 0;
        uint256 originalSetMaxNetworkLimitMinDelay = params.deployNetworkParams.setMaxNetworkLimitMinDelay;
        params.deployNetworkParams.setMaxNetworkLimitMinDelay = 0;
        uint256 originalSetResolverMinDelay = params.deployNetworkParams.setResolverMinDelay;
        params.deployNetworkParams.setResolverMinDelay = 0;

        vm.stopBroadcast();

        address network = run(params.deployNetworkParams);

        vm.startBroadcast();

        {
            uint256 numCalls = 1;
            if (params.resolver != address(0)) ++numCalls;
            if (originalGlobalMinDelay > 0) ++numCalls;
            if (originalSetMaxNetworkLimitMinDelay > 0) ++numCalls;
            if (originalSetResolverMinDelay > 0) ++numCalls;
            if (!isDeployerProposer) ++numCalls;
            if (!isDeployerExecutor) ++numCalls;
            address[] memory targets = new address[](numCalls);
            uint256[] memory values = new uint256[](numCalls);
            bytes[] memory payloads = new bytes[](numCalls);

            uint256 index;
            targets[index] = IVault(params.vault).delegator();
            payloads[index] =
                abi.encodeCall(IBaseDelegator.setMaxNetworkLimit, (params.subnetworkId, params.maxNetworkLimit));

            if (params.resolver != address(0)) {
                targets[++index] = IVault(params.vault).slasher();
                payloads[index] =
                    abi.encodeCall(IVetoSlasher.setResolver, (params.subnetworkId, params.resolver, new bytes(0)));
            }

            if (originalGlobalMinDelay > 0) {
                targets[++index] = network;
                payloads[index] = abi.encodeCall(TimelockController.updateDelay, (originalGlobalMinDelay));
            }

            if (originalSetMaxNetworkLimitMinDelay > 0) {
                targets[++index] = network;
                payloads[index] = abi.encodeCall(
                    INetwork.updateDelay,
                    (address(0), IBaseDelegator.setMaxNetworkLimit.selector, true, originalSetMaxNetworkLimitMinDelay)
                );
            }

            if (originalSetResolverMinDelay > 0) {
                targets[++index] = network;
                payloads[index] = abi.encodeCall(
                    INetwork.updateDelay,
                    (address(0), IVetoSlasher.setResolver.selector, true, originalSetResolverMinDelay)
                );
            }

            if (!isDeployerProposer) {
                targets[++index] = network;
                payloads[index] =
                    abi.encodeCall(AccessControl.revokeRole, (Network(payable(network)).PROPOSER_ROLE(), deployer));
            }

            if (!isDeployerExecutor) {
                targets[++index] = network;
                payloads[index] =
                    abi.encodeCall(AccessControl.revokeRole, (Network(payable(network)).EXECUTOR_ROLE(), deployer));
            }

            Network(payable(network)).scheduleBatch(targets, values, payloads, bytes32(0), bytes32(0), 0);
            Network(payable(network)).executeBatch(targets, values, payloads, bytes32(0), bytes32(0));
        }

        string memory logMessage = string.concat(
            "Opted network into vault",
            "\n    network:",
            vm.toString(network),
            "\n    vault:",
            vm.toString(params.vault),
            "\n    subnetworkId:",
            vm.toString(params.subnetworkId),
            "\n    maxNetworkLimit:",
            vm.toString(params.maxNetworkLimit)
        );
        log(
            params.resolver != address(0)
                ? string.concat(logMessage, "\n    resolver:", vm.toString(params.resolver))
                : logMessage
        );

        vm.stopBroadcast();

        for (uint256 i; i < params.deployNetworkParams.proposers.length; ++i) {
            assert(AccessControl(network).hasRole(Network(payable(network)).PROPOSER_ROLE(), params.deployNetworkParams.proposers[i]));
        }
        for (uint256 i; i < params.deployNetworkParams.executors.length; ++i) {
            assert(AccessControl(network).hasRole(Network(payable(network)).EXECUTOR_ROLE(), params.deployNetworkParams.executors[i]));
        }
        if (!isDeployerProposer) {
            assert(!AccessControl(network).hasRole(Network(payable(network)).PROPOSER_ROLE(), deployer));
        }
        if (!isDeployerExecutor) {
            assert(!AccessControl(network).hasRole(Network(payable(network)).EXECUTOR_ROLE(), deployer));
        }
        if (params.resolver != address(0)) {
            assert(
                IVetoSlasher(IVault(params.vault).slasher()).resolver(
                    network.subnetwork(params.subnetworkId), bytes("")
                ) == params.resolver
            );
        }
        assert(
            IBaseDelegator(IVault(params.vault).delegator()).maxNetworkLimit(network.subnetwork(params.subnetworkId))
                == params.maxNetworkLimit
        );

        return network;
    }
}
