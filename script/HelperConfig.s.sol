// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;


import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";


abstract contract CodeConstant {

    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
    uint96 public MOCK_BASE_FEE = 0.001 ether;
    uint96 public MOCK_GAS_PRICE_LINK = 1e9;
    int256 public MOCK_WEI_PER_UINT_LINK = 4e15; // Изменён тип


        address public FOUNDRY_DEFAULT_SENDER = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;

}


contract HelperConfig is Script, CodeConstant {
    error HelperConfig__InvalidErrorId();
    error HelperConfig__InvalidChainId();


    struct NetworkConfig {
        // uint256 entranceFee;
        // uint256 interval;
        // address vrfCoordinator;
        // bytes32 gasLine;
        // uint32 callbackGasLimit;
        // uint256 subscriptionId;
        // address link;
        // address vrfCoordinatorV2_5; // Добавлено поле
      



               uint256 subscriptionId;
        bytes32 gasLine;
        uint256 interval;
        uint256 entranceFee;
        uint32 callbackGasLimit;
        address vrfCoordinator;
        address link;
        address account;
    }


    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainID => NetworkConfig) public networkConfigs;


    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
    }


   function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (networkConfigs[chainId].vrfCoordinator != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }



    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

 function getSepoliaEthConfig() public pure returns (NetworkConfig memory sepoliaNetworkConfig) {
        sepoliaNetworkConfig = NetworkConfig({
            subscriptionId: 0, // If left as 0, our scripts will create one!
            gasLine: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            interval: 30, // 30 seconds
            entranceFee: 0.00001 ether,
            callbackGasLimit: 500000, // 500,000 gas
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            account: 0x643315C9Be056cDEA171F4e7b2222a4ddaB9F88D
        });
    }



 function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // Check to see if we set an active network config
        if (localNetworkConfig.vrfCoordinator != address(0)) {
            return localNetworkConfig;
        }

        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorV2_5Mock =
            new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE, MOCK_GAS_PRICE_LINK, MOCK_WEI_PER_UINT_LINK);


        LinkToken linkToken = new LinkToken(); 
      uint256 subscriptionId = vrfCoordinatorV2_5Mock.createSubscription();
        vm.stopBroadcast();
        
    localNetworkConfig = NetworkConfig({
            subscriptionId: subscriptionId,
            gasLine: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c, // doesn't really matter
            interval: 30, // 30 seconds
            entranceFee: 0.01 ether,
            callbackGasLimit: 500000, // 500,000 gas
            vrfCoordinator: address(vrfCoordinatorV2_5Mock),
            link: address(linkToken),
            account: 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38 
        });
         vm.deal(localNetworkConfig.account, 100 ether);

        return localNetworkConfig;
    }
}



