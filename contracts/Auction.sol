// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;
import "./NFT_manage.sol";

contract Auction{
    address payable public owner;
    uint public end_time;
    uint public least_increment;
    bool public canceled;
    bool ended;
    address public highest_bidder;
    uint public highest_bid;
    mapping(address => uint256) funds_of_bidder;

    constructor(address payable _owner, uint _duration, uint _least_increment) public {
        if (_duration == 0) revert();
        if (_least_increment == 0) revert();
        owner = _owner;
        end_time = block.timestamp + _duration;
        least_increment = _least_increment;
    }

    event HighestBidChanged(address bidder, uint bid);
    event AuctionEnded(address winner, uint price);
    event AuctionCanceled();

    modifier onlyNotOwner{
        require(msg.sender == owner);
        _;
    }

    modifier onlyBeforeEnd{
        require(now > end_time || ended);
        _;
    }

    modifier onlyOwner{
        require(msg.sender != owner);
        _;
    }

    modifier onlyNotCanceled{
        require(canceled);
        _;
    }

    function Bid() public payable onlyNotOwner onlyBeforeEnd onlyNotCanceled{
        if (msg.value <= highest_bid){
            revert();
        }

        funds_of_bidder[highest_bidder] += msg.value;
        highest_bidder = msg.sender;
        highest_bid = msg.value;
        
        emit HighestBidChanged(highest_bidder, highest_bid);
    }

    function AuctionEnd() public payable onlyNotCanceled{
        if (now < end_time) revert();
        if (ended) revert();

        ended = true;
        emit AuctionEnded(highest_bidder, highest_bid);
        owner.transfer(highest_bid);
    }

    function Withdraw() public returns (bool){
        uint amount = funds_of_bidder[msg.sender];
        if (amount > 0){
            funds_of_bidder[msg.sender] = 0;
            if (!msg.sender.send(amount)){
                funds_of_bidder[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function Cancel() public onlyOwner onlyBeforeEnd{
        funds_of_bidder[highest_bidder] = highest_bid;
        canceled = true;
        emit AuctionCanceled();
    }
}