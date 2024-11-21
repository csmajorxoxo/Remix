// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PMCareFund {

    // State variables
    address public owner;
    address public charityAddress;
    uint public totalFunds;

    // Mapping to track donations made by each user
    mapping(address => uint) public donations;

    // Event to log donation details
    event DonationReceived(address indexed donor, uint amount);
    event FundsTransferred(address indexed charity, uint amount);

    // Modifier to ensure only the owner can call certain functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier charitySet() {
        require(charityAddress != address(0), "Charity address not set");
        _;
    }

    // Constructor to initialize the contract owner
    constructor() {
        owner = msg.sender;
        totalFunds = 0;
    }

    // Function to set the charity address, only accessible by owner
    function setCharityAddress(address _charityAddress) external onlyOwner {
        charityAddress = _charityAddress;
    }

    // Payable function to accept donations
    function donate() external payable {
        require(msg.value > 0, "Donation must be greater than 0");
        
        donations[msg.sender] += msg.value;
        totalFunds += msg.value;
        
        emit DonationReceived(msg.sender, msg.value);
    }

    // Function to transfer funds to charity
    function transferFundsToCharity() external onlyOwner charitySet {
        require(totalFunds > 0, "No funds available for transfer");
        
        uint amountToTransfer = totalFunds;
        totalFunds = 0;
        payable(charityAddress).transfer(amountToTransfer);

        emit FundsTransferred(charityAddress, amountToTransfer);
    }

    // Function to check the current donation balance of a donor
    function checkDonationBalance() external view returns (uint) {
        return donations[msg.sender];
    }
}
