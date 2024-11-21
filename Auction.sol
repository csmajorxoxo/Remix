// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction {
    // State variables
    address public owner;
    address public highestBidder;
    uint public highestBid;
    uint public auctionEndTime;
    bool public auctionEnded;

    // Events
    event NewBid(address indexed bidder, uint amount);
    event AuctionEnded(address indexed winner, uint amount);

    // Constructor to initialize the auction
    constructor(uint _auctionDuration) {
        owner = msg.sender; // The creator of the contract is the owner
        auctionEndTime = block.timestamp + _auctionDuration; // Set auction duration
        auctionEnded = false;
        highestBid = 0;
    }

    // Function to place a bid
    function placeBid() public payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "There already is a higher bid");

        // Refund the previous highest bidder
        if (highestBidder != address(0)) {
            payable(highestBidder).transfer(highestBid); // Send the funds back
        }

        highestBidder = msg.sender; // Set the new highest bidder
        highestBid = msg.value; // Update the highest bid
        emit NewBid(msg.sender, msg.value); // Log the new bid
    }

    // Function to end the auction and transfer funds to the owner
    function endAuction() public {
        require(msg.sender == owner, "Only the owner can end the auction");
        require(block.timestamp >= auctionEndTime, "Auction not yet ended");
        require(!auctionEnded, "Auction already ended");

        auctionEnded = true; // Mark the auction as ended
        emit AuctionEnded(highestBidder, highestBid); // Log the winner

        // Transfer the funds to the owner
        payable(owner).transfer(highestBid);
    }

    // Function to get the current highest bid
    function getHighestBid() public view returns (uint) {
        return highestBid;
    }

    // Function to get the highest bidder
    function getHighestBidder() public view returns (address) {
        return highestBidder;
    }
}
