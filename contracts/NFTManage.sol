// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTManage is ERC721URIStorage{
    struct NFT{
        address owner;
        address minter;
        address previous_owner;
        uint256 token_ID;
        string name;
        bool onSale;
        string URI;
    }
    NFT[] public NFTs;
    uint ID_counter;

    constructor() ERC721("NFTManage", "NFT"){}

    event TokenCreated(address owner, uint256 token_ID);
    event TokenTransfered(uint256 token_ID, address from, address to);

    function createToken(address owner, string memory uri, string memory name) public{
        _safeMint(owner, ID_counter);
        _setTokenURI(ID_counter, uri);
        NFT memory newNFT = NFT(owner, owner, owner, ID_counter, name, false, uri);
        NFTs.push(newNFT);
        ID_counter += 1;
        emit TokenCreated(owner, ID_counter);
    }

    function transferToken(uint256 token_ID, address from, address to) public{
        if (token_ID > ID_counter) revert();
        safeTransferFrom(from, to, token_ID);
        NFTs[token_ID].previous_owner = NFTs[token_ID].owner;
        NFTs[token_ID].owner = to;
        NFTs[token_ID].onSale = false;
        emit TokenTransfered(token_ID, from, to);
    }

    function setOnSale(uint256 token_ID) public{
        if (token_ID > ID_counter) revert();
        if (msg.sender != NFTs[token_ID].owner) revert();
        NFTs[token_ID].onSale = true;
    }

    function setNotOnSale(uint256 token_ID) public{
        if (token_ID > ID_counter) revert();
        if (msg.sender != NFTs[token_ID].owner) revert();
        NFTs[token_ID].onSale = false;
    }

    function allNFTs() public view returns(NFT[] memory){
        return NFTs;
    }

    function LookUpURI(uint256 token_ID) public view returns(string memory){
        return NFTs[token_ID].URI;
    }

    function LookUpStatus(uint256 token_ID) public view returns(bool){
        return NFTs[token_ID].onSale;
    }
}