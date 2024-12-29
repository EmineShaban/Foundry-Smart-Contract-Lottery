// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

/**
 * @title A simple Raffle contract
 * @author Emine Shaban
 * @notice This contract is for creating a simple ruffle
 * @dev Implements ChainLink VRFv2.5
 */

contract Raffle {
    error Raffle__SendMoreToEnterRaffle();

    uint256 private immutable i_EntranceFee;

    constructor(uint256 entranceFee) {
        i_EntranceFee = entranceFee;
    }

    function enterRaffle() public payable {


        if(msg.value < i_EntranceFee){
            revert Raffle__SendMoreToEnterRaffle();
        }
    }

    function pickWinner() public {}

    /**
     * Getter Functions
     */

    function getEntranceFee() external view returns (uint256) {
        return i_EntranceFee;
    }
}
