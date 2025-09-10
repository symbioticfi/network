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

contract DeployNetworkForVaultsBase is DeployNetworkBase {
    using Subnetwork for address;

    struct DeployNetworkForVaultsParams {
        DeployNetworkParams deployNetworkParams;
        address[] vaults;
        uint256[] maxNetworkLimits;
        address[] resolvers;
        uint96 subnetworkId;
    }

    function run(
        DeployNetworkForVaultsParams memory params
    ) public returns (address) {
        assert(params.vaults.length > 0);
        assert(params.vaults.length == params.maxNetworkLimits.length);
        assert(params.vaults.length == params.resolvers.length);

        // update deploy network params to include deployer as proposer and executor
        DeployNetworkParams memory updatedDeployNetworkParams =
            updateDeployParamsForDeployer(params.deployNetworkParams);
        // deploy network
        address network = run(updatedDeployNetworkParams);
        // update network for vaults
        updateNetworkForVaults(network, params, updatedDeployNetworkParams);

        return network;
    }

    function updateDeployParamsForDeployer(
        DeployNetworkParams memory deployNetworkParams
    ) public returns (DeployNetworkParams memory updatedDeployNetworkParams) {
        // clone the struct
        updatedDeployNetworkParams = abi.decode(abi.encode(deployNetworkParams), (DeployNetworkParams));
        updatedDeployNetworkParams.globalMinDelay = 0;
        updatedDeployNetworkParams.setMaxNetworkLimitMinDelay = 0;
        updatedDeployNetworkParams.setResolverMinDelay = 0;

        (,, address deployer) = vm.readCallers();

        bool isDeployerProposer;
        address[] memory tempProposers = new address[](deployNetworkParams.proposers.length + 1);
        for (uint256 i; i < deployNetworkParams.proposers.length; ++i) {
            tempProposers[i] = deployNetworkParams.proposers[i];
            if (tempProposers[i] == deployer) {
                isDeployerProposer = true;
                break;
            }
        }
        if (!isDeployerProposer) {
            tempProposers[tempProposers.length - 1] = deployer;
            updatedDeployNetworkParams.proposers = tempProposers;
        }

        bool isDeployerExecutor;
        address[] memory tempExecutors = new address[](deployNetworkParams.executors.length + 1);
        for (uint256 i; i < deployNetworkParams.executors.length; ++i) {
            tempExecutors[i] = deployNetworkParams.executors[i];
            if (tempExecutors[i] == deployer) {
                isDeployerExecutor = true;
                break;
            }
        }
        if (!isDeployerExecutor) {
            tempExecutors[tempExecutors.length - 1] = deployer;
            updatedDeployNetworkParams.executors = tempExecutors;
        }
    }

    function updateNetworkForVaults(
        address network,
        DeployNetworkForVaultsParams memory params,
        DeployNetworkParams memory updatedDeployNetworkParams
    ) public {
        vm.startBroadcast();

        (,, address deployer) = vm.readCallers();
        bool isDeployerProposer =
            params.deployNetworkParams.proposers.length == updatedDeployNetworkParams.proposers.length;
        bool isDeployerExecutor =
            params.deployNetworkParams.executors.length == updatedDeployNetworkParams.executors.length;

        {
            uint256 numCalls = params.vaults.length;
            for (uint256 i; i < params.resolvers.length; ++i) {
                if (params.resolvers[i] != address(0)) ++numCalls;
            }
            if (params.deployNetworkParams.globalMinDelay > 0) ++numCalls;
            if (params.deployNetworkParams.setMaxNetworkLimitMinDelay > 0) ++numCalls;
            if (params.deployNetworkParams.setResolverMinDelay > 0) ++numCalls;
            if (!isDeployerProposer) ++numCalls;
            if (!isDeployerExecutor) ++numCalls;
            address[] memory targets = new address[](numCalls);
            uint256[] memory values = new uint256[](numCalls);
            bytes[] memory payloads = new bytes[](numCalls);

            uint256 index;
            for (uint256 i; i < params.vaults.length; ++i) {
                targets[index] = IVault(params.vaults[i]).delegator();
                payloads[index++] =
                    abi.encodeCall(IBaseDelegator.setMaxNetworkLimit, (params.subnetworkId, params.maxNetworkLimits[i]));

                if (params.resolvers[i] != address(0)) {
                    targets[index] = IVault(params.vaults[i]).slasher();
                    payloads[index++] = abi.encodeCall(
                        IVetoSlasher.setResolver, (params.subnetworkId, params.resolvers[i], new bytes(0))
                    );
                }
            }

            if (params.deployNetworkParams.globalMinDelay > 0) {
                targets[index] = network;
                payloads[index++] =
                    abi.encodeCall(TimelockController.updateDelay, (params.deployNetworkParams.globalMinDelay));
            }

            if (params.deployNetworkParams.setMaxNetworkLimitMinDelay > 0) {
                targets[index] = network;
                payloads[index++] = abi.encodeCall(
                    INetwork.updateDelay,
                    (
                        address(0),
                        IBaseDelegator.setMaxNetworkLimit.selector,
                        true,
                        params.deployNetworkParams.setMaxNetworkLimitMinDelay
                    )
                );
            }

            if (params.deployNetworkParams.setResolverMinDelay > 0) {
                targets[index] = network;
                payloads[index++] = abi.encodeCall(
                    INetwork.updateDelay,
                    (
                        address(0),
                        IVetoSlasher.setResolver.selector,
                        true,
                        params.deployNetworkParams.setResolverMinDelay
                    )
                );
            }

            if (!isDeployerProposer) {
                targets[index] = network;
                payloads[index++] =
                    abi.encodeCall(AccessControl.revokeRole, (Network(payable(network)).PROPOSER_ROLE(), deployer));
            }

            if (!isDeployerExecutor) {
                targets[index] = network;
                payloads[index] =
                    abi.encodeCall(AccessControl.revokeRole, (Network(payable(network)).EXECUTOR_ROLE(), deployer));
            }

            Network(payable(network)).scheduleBatch(targets, values, payloads, bytes32(0), bytes32(0), 0);
            Network(payable(network)).executeBatch(targets, values, payloads, bytes32(0), bytes32(0));
        }

        for (uint256 i; i < params.vaults.length; ++i) {
            string memory logMessage = string.concat(
                "Opted network into vault",
                "\n    network:",
                vm.toString(network),
                "\n    vault:",
                vm.toString(params.vaults[i]),
                "\n    subnetworkId:",
                vm.toString(params.subnetworkId),
                "\n    maxNetworkLimit:",
                vm.toString(params.maxNetworkLimits[i])
            );
            log(
                params.resolvers[i] != address(0)
                    ? string.concat(logMessage, "\n    resolver:", vm.toString(params.resolvers[i]))
                    : logMessage
            );
        }

        vm.stopBroadcast();

        for (uint256 i; i < params.deployNetworkParams.proposers.length; ++i) {
            bool hasRole = AccessControl(network).hasRole(
                Network(payable(network)).PROPOSER_ROLE(), params.deployNetworkParams.proposers[i]
            );
            (params.deployNetworkParams.proposers[i] == deployer && !isDeployerProposer)
                ? assert(!hasRole)
                : assert(hasRole);
        }
        for (uint256 i; i < params.deployNetworkParams.executors.length; ++i) {
            bool hasRole = AccessControl(network).hasRole(
                Network(payable(network)).EXECUTOR_ROLE(), params.deployNetworkParams.executors[i]
            );
            (params.deployNetworkParams.executors[i] == deployer && !isDeployerExecutor)
                ? assert(!hasRole)
                : assert(hasRole);
        }
        for (uint256 i; i < params.resolvers.length; ++i) {
            if (params.resolvers[i] != address(0)) {
                assert(
                    IVetoSlasher(IVault(params.vaults[i]).slasher()).resolver(
                        network.subnetwork(params.subnetworkId), bytes("")
                    ) == params.resolvers[i]
                );
            }

            assert(
                IBaseDelegator(IVault(params.vaults[i]).delegator()).maxNetworkLimit(
                    network.subnetwork(params.subnetworkId)
                ) == params.maxNetworkLimits[i]
            );
        }
    }
}
