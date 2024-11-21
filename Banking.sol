// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BankingApp {
    struct Account {
        uint256 balance;
        bool isActive;
    }

    address public owner;
    mapping(address => Account) private accounts;

    event AccountCreated(address indexed user);
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event AccountClosed(address indexed user);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier accountExists() {
        require(accounts[msg.sender].isActive, "Account does not exist");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Create a new account
    function createAccount() public {
        require(!accounts[msg.sender].isActive, "Account already exists");
        accounts[msg.sender] = Account(0, true);
        emit AccountCreated(msg.sender);
    }

    // Deposit funds into the account
    function deposit() public payable accountExists {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        accounts[msg.sender].balance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Withdraw funds from the account
    function withdraw(uint256 amount) public accountExists {
        require(accounts[msg.sender].balance >= amount, "Insufficient balance");
        accounts[msg.sender].balance -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    // Check account balance
    function getBalance() public view accountExists returns (uint256) {
        return accounts[msg.sender].balance;
    }

    // Close the account
    function closeAccount() public accountExists {
        uint256 balance = accounts[msg.sender].balance;
        if (balance > 0) {
            payable(msg.sender).transfer(balance);
        }
        accounts[msg.sender].isActive = false;
        emit AccountClosed(msg.sender);
    }

    // Transfer funds between accounts
    function transferFunds(address to, uint256 amount) public accountExists {
        require(accounts[to].isActive, "Recipient account does not exist");
        require(accounts[msg.sender].balance >= amount, "Insufficient balance");

        accounts[msg.sender].balance -= amount;
        accounts[to].balance += amount;

        emit Transfer(msg.sender, to, amount);
    }

    // Transfer funds directly to a specified address (not an account in the system)
    function transferTo(address payable to, uint256 amount) public accountExists {
        require(to != address(0), "Invalid recipient address");
        require(accounts[msg.sender].balance >= amount, "Insufficient balance");

        accounts[msg.sender].balance -= amount;
        to.transfer(amount);

        emit Transfer(msg.sender, to, amount);
    }

    // Admin function to withdraw contract balance (owner only)
    function withdrawContractFunds(uint256 amount) public onlyOwner {
        require(address(this).balance >= amount, "Insufficient contract balance");
        payable(owner).transfer(amount);
    }

    // View contract balance (owner only)
    function getContractBalance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }
}
