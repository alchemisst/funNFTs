// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error RandomNftIpfs_RangeOutOfBounds();
error RandomNftIpfs_NeedMoreEthToMint();
error RandomNftIpfs_TransferFailed();

contract RandomNftIpfs is
    VRFConsumerBaseV2,
    ERC721URIStorage,
    Ownable{
        
    enum Skully {
        KING,
        CHRISTMAS,
        CAP
    }

    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant num_words = 1;
    uint256 internal immutable i_mintFee;

    //NFT Variable
    uint256 public s_tokenCounter;
    uint256 internal constant MAX_CHANCE_VALUE = 100;
    string[3] internal s_skullyTokenUris;

    mapping(uint256 => address) public s_requestIdToSender;

    //Events
    event NftRequested(uint256 indexed requestId, address indexed requester);
    event NftMinted(uint256 indexed tokenId, Skully indexed Skully, address indexed minter);

    constructor(
        address vrfCoordinatorV2,
        uint64 subscriptionId,
        bytes32 gasLane,
        uint32 callbackGasLimit,
        string[3] memory skullyTokenUris,
        uint256 mintFee
    )
        VRFConsumerBaseV2(vrfCoordinatorV2)
        ERC721("Skully", "SKL")
    {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_subscriptionId = subscriptionId;
        i_gasLane = gasLane;

        i_callbackGasLimit = callbackGasLimit;

        s_skullyTokenUris = skullyTokenUris;
        i_mintFee = mintFee;
    }

    function requestNft() public payable returns (uint256 requestId) {
        if (msg.value < i_mintFee) {
            revert RandomNftIpfs_NeedMoreEthToMint();
        }
        requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,                             /*  asds address vrfCoordinatorV2,
        uint64 subscriptionId,
        bytes32 gasLane,
        uint32 callbackGasLimit,
        string[3] memory skullyTokenUris,
        uint256 mintFeea*/
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            num_words
        );

        s_requestIdToSender[requestId] = msg.sender;

        emit NftRequested(requestId, msg.sender);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        address skullyOwner = s_requestIdToSender[requestId];
        uint256 newTokenId = s_tokenCounter;
        _safeMint(skullyOwner, newTokenId);
        s_tokenCounter = s_tokenCounter + 1;

        uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE;

        Skully skullyType = getRarity(moddedRng);
        s_tokenCounter=s_tokenCounter + 1; 
        _safeMint(skullyOwner, newTokenId);
        _setTokenURI(newTokenId, s_skullyTokenUris[uint256(skullyType)]);

        emit NftMinted(newTokenId,skullyType , skullyOwner);
    }

    function withdraw() public onlyOwner{
        uint256 amount = address(this).balance;
        (bool success,) = payable(msg.sender).call{value:amount}("");

        if(!success){
            revert RandomNftIpfs_TransferFailed();
        }
    }

    function getRarity(uint256 moddedRng) public pure returns (Skully) {
        uint256 cumulativeSum = 0;
        uint256[3] memory chanceArray = getChanceArray();
        for (uint256 i = 0; i < chanceArray.length; i++) {
            if (moddedRng >= cumulativeSum && moddedRng < chanceArray[i]) {
                return Skully(i);
            }
            cumulativeSum = chanceArray[i];
        }
        revert RandomNftIpfs_RangeOutOfBounds();
    }

    function getChanceArray() public pure returns (uint256[3] memory) {
        return [10, 30, MAX_CHANCE_VALUE];
    }
        function getMintFee() public view returns (uint256) {
        return i_mintFee;
    }

    function getSkullyTokenUris(uint256 index) public view returns (string memory) {
        return s_skullyTokenUris[index];
    }

    // function getInitialized() public view returns (bool) {
    //     return s_initialized;
    // }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
