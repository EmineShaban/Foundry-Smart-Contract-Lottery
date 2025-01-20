// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, CodeConstant} from "script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";


// C:\Users\offic\Documents\GitHub\Foundry-Smart-Contract-Lottery\lib\foundry-devops\src\DevOpsTools.sol
contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint256, address) {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfigByChainId(block.chainid).vrfCoordinator;
        (uint256 subId, ) = createSubscription(vrfCoordinator);
        return (subId, vrfCoordinator);
    }

    function createSubscription(
        address vrfCoordinator
    ) public returns (uint256, address) {
        console.log("Creating subscription on chain ID", block.chainid);
        vm.startBroadcast();
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator)
            .createSubscription();
        vm.stopBroadcast();
        console.log("Your subscription id is: ", subId);
        console.log(
            "Please update the subscription id in your HelperConfig.s.sol"
        );

        return (subId, vrfCoordinator);
    }

    function run() public {
        createSubscriptionUsingConfig();
    }
}
contract FundSubscription is Script, CodeConstant {
    uint256 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
        address linkToken = helperConfig.getConfig().link;
        address account = helperConfig.getConfig().account;

        fundSubscription(vrfCoordinator, subscriptionId, linkToken, account);
    }

    // function fundSubscription(
    //     address vrfCoordinator,
    //     uint256 subscriptionId,
    //     address linkToken
    // ) public {
    //     console.log("Funding subscription: ", subscriptionId);
    //     console.log("Using vrfCoordinator: ", vrfCoordinator);
    //     console.log("On chainId: ", block.chainid);

    //     if (block.chainid == LOCAL_CHAIN_ID) {
    //         vm.startBroadcast();
    //         VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(
    //             subscriptionId,
    //             FUND_AMOUNT * 100
    //         );
    //         vm.stopBroadcast();
    //     } else {
    //         vm.startBroadcast();
    //         LinkToken(linkToken).transferAndCall(
    //             vrfCoordinator,
    //             FUND_AMOUNT * 100,
    //             abi.encode(subscriptionId)
    //         );
    //         vm.stopBroadcast();
    //     }
    // }
function fundSubscription(address vrfCoordinator, uint256 subscriptionId, address linkToken, address account) public {
    console.log("Funding subscription:\t", subscriptionId);
    console.log("Using vrfCoordinator:\t\t\t", vrfCoordinator);
    console.log("On chainId: ", block.chainid);

    if(block.chainid == LOCAL_CHAIN_ID) {
        vm.startBroadcast(account);
        VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subscriptionId, FUND_AMOUNT * 100);
        vm.stopBroadcast();
    } else {
        console.log(LinkToken(linkToken).balanceOf(msg.sender));
        console.log(msg.sender);
        console.log(LinkToken(linkToken).balanceOf(address(this)));
        console.log(address(this));
        vm.startBroadcast(account);
        LinkToken(linkToken).transferAndCall(vrfCoordinator, FUND_AMOUNT, abi.encode(subscriptionId));
        vm.stopBroadcast();
    }

}


    
    function createSubscriptionUsingConfig()
        public
        returns (uint256, address)
    {}

    function run() public {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumerUsingConfig(address mostRecentlyDeployed) public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subId = helperConfig.getConfig().subscriptionId;
        addConsumer(mostRecentlyDeployed, vrfCoordinator, subId);
    }
    function addConsumer(
        address contractToAddToVrf,
        address vrfCoordinator,
        uint256 subId
    ) public {
        console.log("Adding consumer cotract: ", contractToAddToVrf);
        console.log("To vrfCoordinator: ", vrfCoordinator);
        console.log("On chainId: ", block.chainid);
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(
            subId,
            contractToAddToVrf
        );
        vm.stopBroadcast();
    }
    function run() public {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        addConsumerUsingConfig(mostRecentlyDeployed);
    }
}
