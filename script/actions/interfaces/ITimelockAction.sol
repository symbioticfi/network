// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface ITimelockAction {
    /**
     * @notice Schedule the action through the timelock
     */
    function runSchedule() external;

    /**
     * @notice Execute the action immediately through the timelock
     */
    function runExecute() external;

    /**
     * @notice Schedule and execute the action through the timelock
     */
    function runScheduleAndExecute() external;

    /**
     * @notice Get the target and payload of the action
     */
    function getTargetAndPayload() external view returns (address, bytes memory);
}
