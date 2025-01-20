// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;


import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";


abstract contract CodeConstant {
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
    uint96 public MOCK_BASE_FEE = 0.25 ether;
    uint96 public MOCK_GAS_PRICE_LINK = 1e9;
    int256 public MOCK_WEI_PER_UINT_LINK = 4e15; // Изменён тип
}


contract HelperConfig is Script, CodeConstant {
    error HelperConfig__InvalidErrorId();


    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLine;
        uint32 callbackGasLimit;
        uint256 subscriptionId;
        address link;
        address vrfCoordinatorV2_5; // Добавлено поле
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
            revert HelperConfig__InvalidErrorId();
        }
    }


    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }


    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30,
                vrfCoordinator: 0xDB8cFf278adCCF9E9b5da745B44E754fC4EE3C76,
                gasLine: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                callbackGasLimit: 50000,
                vrfCoordinatorV2_5: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B, // Добавлено поле
                subscriptionId: 0,
                link: 0xDB8cFf278adCCF9E9b5da745B44E754fC4EE3C76
            });
    }


    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (localNetworkConfig.vrfCoordinator != address(0)) {
            return localNetworkConfig;
        }


        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorV2_5Mock =
            new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE, MOCK_GAS_PRICE_LINK, MOCK_WEI_PER_UINT_LINK);


        LinkToken linkToken = new LinkToken(); 
 
        vm.stopBroadcast();
        

        localNetworkConfig = NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: address(vrfCoordinatorV2_5Mock), // Исправлено
            gasLine: 0x027f94ff1465b3525f9fc03e9ff7d6d2c0953482246dd6ae07570c45d6631414,
            callbackGasLimit: 50000,
            vrfCoordinatorV2_5: address(vrfCoordinatorV2_5Mock), // Добавлено поле
            subscriptionId: 0,
            link: address(linkToken)
        });
        return localNetworkConfig;
    }
}



