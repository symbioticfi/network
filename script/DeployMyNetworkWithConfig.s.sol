    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {DeployNetwork} from "./DeployNetwork.s.sol";
import {INetwork} from "../src/interfaces/INetwork.sol";
import {Network} from "../src/contracts/Network.sol";

import {IVault} from "@symbioticfi/core/src/interfaces/vault/IVault.sol";
import {IVetoSlasher} from "@symbioticfi/core/src/interfaces/slasher/IVetoSlasher.sol";
import {IBaseDelegator} from "@symbioticfi/core/src/interfaces/delegator/IBaseDelegator.sol";
import {SymbioticCoreConstants} from "@symbioticfi/core/test/integration/SymbioticCoreConstants.sol";

import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {TimelockControllerUpgradeable} from
    "@openzeppelin/contracts-upgradeable/governance/TimelockControllerUpgradeable.sol";

import {ICreateX} from "@createx/ICreateX.sol";

contract DeployMyNetworkWithConfig is DeployNetwork {
    // Configuration constants - UPDATE THESE BEFORE DEPLOYMENT
    string public constant NAME = "My Network";
    string public constant METADATA_URI = "";
    uint256 public constant GLOBAL_MIN_DELAY = 4 hours;
    address public constant DEFAULT_ADMIN_ROLE_HOLDER = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public constant NAME_UPDATE_ROLE_HOLDER = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public constant METADATA_URI_UPDATE_ROLE_HOLDER = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public constant PROPOSER = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public constant EXECUTOR = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public constant PROXY_ADMIN = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public constant VAULT = 0x7b276aAD6D2ebfD7e270C5a2697ac79182D9550E;
    bytes32 public constant SALT = keccak256("Network");
    uint256 public constant COLD_ACTIONS_DELAY = 1 days;
    uint256 public constant HOT_ACTIONS_DELAY = 1 hours;
    uint256 public constant MAX_NETWORK_LIMIT = 1_000_000;
    address public constant RESOLVER = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint96 public constant SUBNETWORK_ID = 0;

    function run() public {
        address deployer = msg.sender;
        address[] memory proposers = new address[](2);
        proposers[0] = PROPOSER;
        proposers[1] = deployer;
        address[] memory executors = new address[](2);
        executors[0] = EXECUTOR;
        executors[1] = deployer;
        INetwork.DelayParams[] memory delayParams = new INetwork.DelayParams[](0);

        INetwork.NetworkInitParams memory initParams = INetwork.NetworkInitParams({
            globalMinDelay: 0,
            delayParams: delayParams,
            proposers: proposers,
            executors: executors,
            name: NAME,
            metadataURI: METADATA_URI,
            defaultAdminRoleHolder: DEFAULT_ADMIN_ROLE_HOLDER,
            nameUpdateRoleHolder: NAME_UPDATE_ROLE_HOLDER,
            metadataURIUpdateRoleHolder: METADATA_URI_UPDATE_ROLE_HOLDER
        });

        NetworkDeployParams memory params =
            NetworkDeployParams({initParams: initParams, proxyAdmin: PROXY_ADMIN, salt: SALT});

        vm.startBroadcast();
        // deploy network
        address network = super.run(params);

        uint256 numCalls = 7;
        if (VAULT != address(0) && RESOLVER != address(0)) {
            numCalls++;
        }
        if (VAULT != address(0) && MAX_NETWORK_LIMIT > 0) {
            numCalls++;
        }

        address[] memory targets = new address[](numCalls);
        uint256[] memory values = new uint256[](numCalls);
        bytes[] memory payloads = new bytes[](numCalls);

        // set delays
        address networkMiddlewareService = address(SymbioticCoreConstants.core().networkMiddlewareService);
        targets[0] = network;
        payloads[0] = abi.encodeCall(
            INetwork(network).updateDelay,
            (networkMiddlewareService, bytes4(keccak256("setMiddleware(address)")), true, COLD_ACTIONS_DELAY)
        );

        address proxyAdmin = _getProxyAdmin(network);
        targets[1] = network;
        payloads[1] = abi.encodeCall(
            INetwork(network).updateDelay,
            (proxyAdmin, bytes4(keccak256("upgradeAndCall(address,address,bytes)")), true, COLD_ACTIONS_DELAY)
        );

        targets[2] = network;
        payloads[2] = abi.encodeCall(
            INetwork(network).updateDelay,
            (network, bytes4(keccak256("setMaxNetworkLimit(uint96,uint256)")), true, HOT_ACTIONS_DELAY)
        );

        address slasher = IVault(VAULT).slasher();
        targets[3] = network;
        payloads[3] = abi.encodeCall(
            INetwork(network).updateDelay,
            (slasher, bytes4(keccak256("setResolver(uint96,address,bytes)")), true, HOT_ACTIONS_DELAY)
        );

        // update global delay
        targets[4] = network;
        payloads[4] = abi.encodeCall(TimelockControllerUpgradeable(payable(network)).updateDelay, (GLOBAL_MIN_DELAY));

        // revoke proposer role
        targets[5] = network;
        payloads[5] =
            abi.encodeCall(Network(payable(network)).revokeRole, (Network(payable(network)).PROPOSER_ROLE(), deployer));

        // revoke executor role
        targets[6] = network;
        payloads[6] =
            abi.encodeCall(Network(payable(network)).revokeRole, (Network(payable(network)).EXECUTOR_ROLE(), deployer));

        if (VAULT != address(0) && MAX_NETWORK_LIMIT > 0) {
            address delegator = IVault(VAULT).delegator();
            targets[7] = delegator;
            payloads[7] =
                abi.encodeCall(IBaseDelegator(delegator).setMaxNetworkLimit, (SUBNETWORK_ID, MAX_NETWORK_LIMIT));
        }

        if (VAULT != address(0) && RESOLVER != address(0)) {
            address slasher = IVault(VAULT).slasher();
            targets[8] = slasher;
            payloads[8] = abi.encodeCall(IVetoSlasher(slasher).setResolver, (SUBNETWORK_ID, RESOLVER, new bytes(0)));
        }

        Network(payable(network)).scheduleBatch(targets, values, payloads, bytes32(0), bytes32(0), 0);

        Network(payable(network)).executeBatch(targets, values, payloads, bytes32(0), bytes32(0));

        vm.stopBroadcast();
    }

    function _getProxyAdmin(
        address proxy
    ) internal view returns (address admin) {
        bytes32 adminSlot = vm.load(proxy, ERC1967Utils.ADMIN_SLOT);
        return address(uint160(uint256(adminSlot)));
    }
}
