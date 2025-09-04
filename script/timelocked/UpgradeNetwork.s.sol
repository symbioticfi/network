pragma solidity ^0.8.25;

import {TimelockBase} from "./TimelockBase.sol";
import {Network} from "../../src/contracts/Network.sol";

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract UpgradeNetwork is TimelockBase {
    function runSchedule(
        address payable network,
        address newImplementation,
        uint256 delay,
        string memory seed
    ) public {
        address proxyAdmin = _getProxyAdmin(network);
        bytes memory upgradeData;
        bytes memory data = abi.encodeCall(
            ProxyAdmin(proxyAdmin).upgradeAndCall,
            (ITransparentUpgradeableProxy(network), newImplementation, upgradeData)
        );

        TimelockBase.TimelockParams memory params = TimelockBase.TimelockParams({
            network: network,
            isExecutionMode: false,
            target: proxyAdmin,
            data: data,
            delay: delay,
            seed: seed
        });

        callTimelock(params);

        string memory log = string.concat(
            "\nScheduled upgrade for",
            " network:",
            Strings.toHexString(network),
            " proxyAdmin:",
            Strings.toHexString(proxyAdmin),
            " newImplementation:",
            Strings.toHexString(newImplementation),
            " delay:",
            Strings.toString(delay),
            " seed:",
            seed
        );

        logCall(log);
    }

    function runExecute(
        address payable network,
        address newImplementation,
        bytes memory upgradeData,
        string memory seed
    ) public {
        address proxyAdmin = _getProxyAdmin(network);
        bytes memory upgradeData;
        bytes memory data = abi.encodeCall(
            ProxyAdmin(proxyAdmin).upgradeAndCall,
            (ITransparentUpgradeableProxy(network), newImplementation, upgradeData)
        );

        TimelockBase.TimelockParams memory params = TimelockBase.TimelockParams({
            network: network,
            isExecutionMode: true,
            target: proxyAdmin,
            data: data,
            delay: 0,
            seed: seed
        });

        callTimelock(params);

        string memory log = string.concat(
            "\nExecuted upgrade for",
            " network:",
            Strings.toHexString(network),
            " proxyAdmin:",
            Strings.toHexString(proxyAdmin),
            " newImplementation:",
            Strings.toHexString(newImplementation),
            " seed:",
            seed
        );

        logCall(log);
    }

    function _getProxyAdmin(
        address proxy
    ) internal view returns (address admin) {
        bytes32 adminSlot = vm.load(proxy, ERC1967Utils.ADMIN_SLOT);
        return address(uint160(uint256(adminSlot)));
    }
}
