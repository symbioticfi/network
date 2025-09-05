// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface ITimelockAction {
    /**
     * @notice Schedule the action through the timelock
     */
    function runS() external;

    /**
     * @notice Execute the action immediately through the timelock
     */
    function runE() external;

    /**
     * @notice Schedule and execute the action through the timelock
     */
    function runSE() external;

    /**
     * @notice Get the target and payload of the action
     */
    function getTargetAndPayload() external view returns (address, bytes memory);
}
