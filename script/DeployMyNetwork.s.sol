    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {DeployNetwork} from "./DeployNetwork.s.sol";
import {INetwork} from "../src/interfaces/INetwork.sol";

contract DeployMyNetwork is DeployNetwork {
    // Configuration constants - UPDATE THESE BEFORE DEPLOYMENT
    string public constant NAME = "";
    string public constant METADATA_URI = "";
    uint256 public constant GLOBAL_MIN_DELAY = 0;
    address public constant DEFAULT_ADMIN_ROLE_HOLDER = 0x0000000000000000000000000000000000000000;
    address public constant NAME_UPDATE_ROLE_HOLDER = 0x0000000000000000000000000000000000000000;
    address public constant METADATA_URI_UPDATE_ROLE_HOLDER = 0x0000000000000000000000000000000000000000;
    address public constant PROPOSER = 0x0000000000000000000000000000000000000000;
    address public constant EXECUTOR = 0x0000000000000000000000000000000000000000;
    address public constant PROXY_ADMIN = 0x0000000000000000000000000000000000000000;

    function run() public {
        address[] memory proposers = new address[](1);
        proposers[0] = PROPOSER;
        address[] memory executors = new address[](1);
        executors[0] = EXECUTOR;
        INetwork.DelayParams[] memory delayParams = new INetwork.DelayParams[](0);

        INetwork.NetworkInitParams memory initParams = INetwork.NetworkInitParams({
            globalMinDelay: GLOBAL_MIN_DELAY,
            delayParams: delayParams,
            proposers: proposers,
            executors: executors,
            name: NAME,
            metadataURI: METADATA_URI,
            defaultAdminRoleHolder: DEFAULT_ADMIN_ROLE_HOLDER,
            nameUpdateRoleHolder: NAME_UPDATE_ROLE_HOLDER,
            metadataURIUpdateRoleHolder: METADATA_URI_UPDATE_ROLE_HOLDER
        });

        NetworkDeployParams memory params = NetworkDeployParams({initParams: initParams, proxyAdmin: PROXY_ADMIN});
        super.run(params);
    }
}
