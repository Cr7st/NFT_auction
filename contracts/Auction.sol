// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.7.0;
import "NFT_manage.sol"

contract Auction{
    address public owner;
    uint public end_time;
    uint public least_increment;
    bool public canceled;
    bool ended;
    address public highest_bidder;
    uint public highest_bid;
    mapping(address => uint256) funds_of_bidder;

    function Auction(address _owner, uint _duration, uint _least_increment){
        if (duration == 0) throw;
        if (_owner == 0 || _least_increment == 0) throw;
        owner = _owner;
        end_time = block.timestamp + _duration;
        least_increment = _least_increment;
    }

    event HighestBidChanged(address bidder, uint bid);
    event AuctionEnded(address winner, uint price);
    event AUctionCanceled();

    modifier onlyNotOwner{
        if (msg.sender == owner) throw;
        _;
    }

    modifier onlyBeforeEnd{
        if (now > end_time || ended) throw;
        _;
    }

    modifer onlyOwner{
        if (msg.sender != owner) throw;
        _;
    }

    modifer onlyNotCanceled{
        if (canceled) throw;
        _;
    }

    function Bid() payable onlyNotOwner onlyBeforeEnd onlyNotCanceled{
        if (msg.value <= highest_bid){
            revert();
        }

        funds_of_bidder[highest_bidder] += msg.value;
        highest_bidder = msg.sender;
        highest_bid = msg.value;
        
        emit HighestBidChanged(highest_bidder, highest_bid);
    }

    function AuctionEnd() onlyNotCanceled{
        if (now < end_time) revert();
        if (ended) revert();

        ended = true;
        emit AuctionEnded(highest_bidder, highest_bid);
        owner.transfer(highest_bid);
    }

    fuction Withdraw() returns (bool){
        uint amount = fund_of_bidder[msg.sender];
        if (amount > 0){
            fund_of_bidder[msg.sender] = 0;
            if (!payable(msg.sender).send(amount)){
                fund_of_bidder[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function Cancel() onlyOwner OnlyBeforeEnd{
        fund_of_bidder[highest_bidder] = highest_bid;
        canceled = true;
        emit AuctionCanceled();
    }
}