// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//import "./NFT_manage.sol";

contract Auction{
    address payable public owner;
    uint public end_time;
    uint256 public token_ID;
    bool public canceled;
    bool ended;
    address public highest_bidder;
    uint public highest_bid;
    mapping(address => uint256) funds_of_bidder;

    constructor(address payable _owner, uint _end_time, uint256 _token_ID){
        if (_end_time < block.timestamp) revert();
        owner = _owner;
        end_time = _end_time;
        token_ID = _token_ID;
        highest_bid = 0;
        ended = false;
    }

    event HighestBidChanged(address bidder, uint bid);
    event AuctionEnded(address winner, uint price);
    event AuctionCanceled();

    modifier onlyNotOwner{
        require(msg.sender != owner);
        _;
    }

    modifier onlyBeforeEnd{
        if (block.timestamp * 1000 < end_time && !ended) _;
        else {
            revert();
        }
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    modifier onlyNotCanceled{
        require(!canceled);
        _;
    }

    function Bid() public payable onlyNotOwner onlyBeforeEnd onlyNotCanceled{
        if (msg.sender == highest_bidder){
            if (msg.value + highest_bid <= highest_bid){
                revert();
            }
        }
        else{
            if (msg.value + funds_of_bidder[msg.sender] <= highest_bid){
                revert();
            }
        }

        if (highest_bid == 0){
            funds_of_bidder[msg.sender] = 0;
            highest_bid = msg.value;
            highest_bidder = msg.sender;
        }
        else {
            funds_of_bidder[highest_bidder] += highest_bid;
            highest_bidder = msg.sender;
            highest_bid = msg.value + funds_of_bidder[msg.sender];
            funds_of_bidder[msg.sender] = 0;
        }
        funds_of_bidder[owner] = highest_bid;
        
        emit HighestBidChanged(highest_bidder, highest_bid);
    }

    function AuctionEnd() public payable onlyNotCanceled{
        if (block.timestamp * 1000 < end_time) revert();
        if (ended) revert();

        ended = true;
        emit AuctionEnded(highest_bidder, highest_bid);
        owner.transfer(highest_bid);
        funds_of_bidder[owner] = 0;
    }

    function Withdraw() public returns (bool){
        uint amount = funds_of_bidder[msg.sender];
        if (amount > 0){
            funds_of_bidder[msg.sender] = 0;
            if (!payable(msg.sender).send(amount)){
                funds_of_bidder[msg.sender] = amount;
                return false;
            }
        }
        else {
            return false;
        }
        return true;
    }

    function Cancel() public onlyOwner onlyBeforeEnd{
        funds_of_bidder[highest_bidder] = highest_bid;
        canceled = true;
        emit AuctionCanceled();
    }

    function LookUpBid() public view returns (uint){
        if (msg.sender == owner) {
            return 0;
        }
        else if (msg.sender == highest_bidder){
            return highest_bid;
        }
        else {
            return funds_of_bidder[msg.sender];
        }
    }

    function LookUpFund() public view returns (uint){
        return funds_of_bidder[msg.sender];
    }
}