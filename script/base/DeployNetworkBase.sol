// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";

import "./Logs.sol";
import {Network} from "../../src/Network.sol";
import {INetwork} from "../../src/interfaces/INetwork.sol";

import {SymbioticCoreConstants} from "@symbioticfi/core/test/integration/SymbioticCoreConstants.sol";
import {INetworkMiddlewareService} from "@symbioticfi/core/src/interfaces/service/INetworkMiddlewareService.sol";
import {IBaseDelegator} from "@symbioticfi/core/src/interfaces/delegator/IBaseDelegator.sol";
import {IVetoSlasher} from "@symbioticfi/core/src/interfaces/slasher/IVetoSlasher.sol";

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {Hashes} from "@openzeppelin/contracts/utils/cryptography/Hashes.sol";

import {ICreateX} from "@createx/ICreateX.sol";

contract DeployNetworkBase is Script, Logs {
    address public constant CREATEX_FACTORY = 0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed;

    struct DeployNetworkParams {
        string name;
        string metadataURI;
        address[] proposers;
        address[] executors;
        address defaultAdminRoleHolder;
        address nameUpdateRoleHolder;
        address metadataURIUpdateRoleHolder;
        uint256 globalMinDelay;
        uint256 upgradeProxyMinDelay;
        uint256 setMiddlewareMinDelay;
        uint256 setMaxNetworkLimitMinDelay;
        uint256 setResolverMinDelay;
        bytes11 salt; // Salt for CREATE3 deterministic deployment
    }

    function run(
        DeployNetworkParams memory params
    ) public returns (address) {
        vm.startBroadcast();

        // Needed for permissioned deploy protection
        (,, address deployer) = vm.readCallers();
        // CreateX-specific salt generation
        bytes32 salt = bytes32(uint256(uint160(deployer)) << 96 | uint256(0x00) << 88 | uint256(uint88(params.salt)));
        bytes32 guardedSalt = Hashes.efficientKeccak256({a: bytes32(uint256(uint160(deployer))), b: salt});

        SymbioticCoreConstants.Core memory core = SymbioticCoreConstants.core();
        address implementation =
            address(new Network(address(core.networkRegistry), address(core.networkMiddlewareService)));

        address proxy;
        {
            address precomputedProxy = ICreateX(CREATEX_FACTORY).computeCreate3Address(guardedSalt);
            address precomputedProxyAdmin = ICreateX(CREATEX_FACTORY).computeCreateAddress(precomputedProxy, 1);

            INetwork.DelayParams[] memory delayParams = new INetwork.DelayParams[](4);
            delayParams[0] = INetwork.DelayParams({
                target: precomputedProxyAdmin,
                selector: ProxyAdmin.upgradeAndCall.selector,
                delay: params.upgradeProxyMinDelay
            });
            delayParams[1] = INetwork.DelayParams({
                target: address(core.networkMiddlewareService),
                selector: INetworkMiddlewareService.setMiddleware.selector,
                delay: params.setMiddlewareMinDelay
            });
            delayParams[2] = INetwork.DelayParams({
                target: address(0),
                selector: IBaseDelegator.setMaxNetworkLimit.selector,
                delay: params.setMaxNetworkLimitMinDelay
            });
            delayParams[3] = INetwork.DelayParams({
                target: address(0),
                selector: IVetoSlasher.setResolver.selector,
                delay: params.setResolverMinDelay
            });

            INetwork.NetworkInitParams memory initParams = INetwork.NetworkInitParams({
                globalMinDelay: params.globalMinDelay,
                delayParams: delayParams,
                proposers: params.proposers,
                executors: params.executors,
                name: params.name,
                metadataURI: params.metadataURI,
                defaultAdminRoleHolder: params.defaultAdminRoleHolder,
                nameUpdateRoleHolder: params.nameUpdateRoleHolder,
                metadataURIUpdateRoleHolder: params.metadataURIUpdateRoleHolder
            });

            // Create initialization code for TransparentUpgradeableProxy
            bytes memory proxyInitCode = abi.encodePacked(
                type(TransparentUpgradeableProxy).creationCode,
                abi.encode(implementation, precomputedProxy, abi.encodeCall(INetwork.initialize, (initParams)))
            );

            // Deploy proxy using CREATE3
            proxy = ICreateX(CREATEX_FACTORY).deployCreate3(salt, proxyInitCode);

            assert(proxy == precomputedProxy);
            assert(_getProxyAdmin(proxy) == precomputedProxyAdmin);
            assert(keccak256(bytes(Network(payable(proxy)).name())) == keccak256(bytes(params.name)));
            assert(keccak256(bytes(Network(payable(proxy)).metadataURI())) == keccak256(bytes(params.metadataURI)));
            assert(Network(payable(proxy)).getMinDelay() == params.globalMinDelay);
            for (uint256 i; i < delayParams.length; ++i) {
                // if target is address(0), it means that the delay is for the any address
                address target = delayParams[i].target == address(0) ? address(1) : delayParams[i].target;
                assert(
                    Network(payable(proxy)).getMinDelay(target, abi.encodePacked(delayParams[i].selector))
                        == delayParams[i].delay
                );
            }
            for (uint256 i; i < params.proposers.length; ++i) {
                address proposer = params.proposers[i];
                assert(Network(payable(proxy)).hasRole(Network(payable(proxy)).PROPOSER_ROLE(), proposer));
                assert(Network(payable(proxy)).hasRole(Network(payable(proxy)).CANCELLER_ROLE(), proposer));
            }
            for (uint256 i; i < params.executors.length; ++i) {
                address executor = params.executors[i];
                assert(Network(payable(proxy)).hasRole(Network(payable(proxy)).EXECUTOR_ROLE(), executor));
            }
            if (params.defaultAdminRoleHolder != address(0)) {
                assert(
                    Network(payable(proxy)).hasRole(
                        Network(payable(proxy)).DEFAULT_ADMIN_ROLE(), params.defaultAdminRoleHolder
                    )
                );
            }
            if (params.nameUpdateRoleHolder != address(0)) {
                assert(
                    Network(payable(proxy)).hasRole(
                        Network(payable(proxy)).NAME_UPDATE_ROLE(), params.nameUpdateRoleHolder
                    )
                );
            }
            if (params.metadataURIUpdateRoleHolder != address(0)) {
                assert(
                    Network(payable(proxy)).hasRole(
                        Network(payable(proxy)).METADATA_URI_UPDATE_ROLE(), params.metadataURIUpdateRoleHolder
                    )
                );
            }
        }

        log(
            string.concat(
                "Deployed network",
                "\n    network:",
                vm.toString(proxy),
                "\n    proxyAdminContract:",
                vm.toString(address(uint160(uint256(vm.load(proxy, ERC1967Utils.ADMIN_SLOT))))),
                "\n    newImplementation:",
                vm.toString(implementation),
                "\n    salt:",
                vm.toString(params.salt)
            )
        );

        vm.stopBroadcast();

        return proxy;
    }

    function _getProxyAdmin(
        address proxy
    ) internal view returns (address admin) {
        return address(uint160(uint256(vm.load(proxy, ERC1967Utils.ADMIN_SLOT))));
    }
}
