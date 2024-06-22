// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BasicNft is ERC721 {
    string public constant TOKEN_URI =
        "ipfs://QmaU57Pd5wcN2JKLU5HmHxtJ136DaZchQJaVcBizSkBZRT";
    uint256 private s_tokenCounter;

    constructor() ERC721("Skully", "SKL") {
        s_tokenCounter = 0;
    }

    function mintNft() public{
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
     
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        return TOKEN_URI;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
