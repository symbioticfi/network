// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Network} from "../src/contracts/Network.sol";

contract MyNetwork is Network {
    constructor(
        address networkRegistry,
        address networkMiddlewareService
    ) Network(networkRegistry, networkMiddlewareService) {}

    function initialize(
        NetworkInitParams memory networkInitParams
    ) public virtual initializer {
        __Network_init(networkInitParams);
    }
}
