// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Auction } from './Auction.sol';

contract AuctionFactory {
    address[] public auctions;
    event AuctionCreated(address auctionContract, address owner, uint numAuctions, address[] allAuctions);

    function createAuction(uint duration, uint256 token_ID) public {
        Auction newAuction = new Auction(payable(msg.sender), duration, token_ID);
        auctions.push(address(newAuction));

        emit AuctionCreated(address(newAuction), msg.sender, auctions.length, auctions);
    }

    function allAuctions() public view returns (address[] memory){
        return auctions;
    }
}