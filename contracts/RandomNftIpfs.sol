// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


import "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error RandomNftIpfs_RangeOutOfBounds();
error RandomNftIpfs_NeedMoreEthToMint();
error RandomNftIpfs_TransferFailed();

contract RandomNftIpfs is VRFConsumerBaseV2Plus, ERC721URIStorage {
    enum Skully {
        KING,
        CHRISTMAS,
        CAP
    }

  
    uint256 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 internal immutable i_mintFee;

    uint256 public s_tokenCounter;
    uint256 internal constant MAX_CHANCE_VALUE = 100;
    string[3] internal s_skullyTokenUris;

    mapping(uint256 => address) public s_requestIdToSender;

    event NftRequested(uint256 indexed requestId, address indexed requester);
    event NftMinted(
        uint256 indexed tokenId,
        Skully indexed skullyType,
        address indexed minter
    );

    constructor(
        address vrfCoordinatorV2,
        uint256 subscriptionId,
        bytes32 gasLane,
        uint32 callbackGasLimit,
        string[3] memory skullyTokenUris,
        uint256 mintFee
    ) VRFConsumerBaseV2Plus(vrfCoordinatorV2) ERC721("Skully", "SKL") {
       
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

        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_gasLane,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );

        s_requestIdToSender[requestId] = msg.sender;
        emit NftRequested(requestId, msg.sender);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {
        address skullyOwner = s_requestIdToSender[requestId];
        uint256 newTokenId = s_tokenCounter;
        uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE;
        Skully skullyType = getRarity(moddedRng);

        s_tokenCounter += 1;
        _safeMint(skullyOwner, newTokenId);
        _setTokenURI(newTokenId, s_skullyTokenUris[uint256(skullyType)]);

        emit NftMinted(newTokenId, skullyType, skullyOwner);
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");

        if (!success) {
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

    function getSkullyTokenUris(
        uint256 index
    ) public view returns (string memory) {
        return s_skullyTokenUris[index];
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
