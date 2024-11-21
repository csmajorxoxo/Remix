// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public creator;
    uint public goalAmount;
    uint public deadline;
    uint public totalFunds;
    bool public goalReached;
    bool public fundsWithdrawn;

    mapping(address => uint) public contributions;

    event ContributionReceived(address contributor, uint amount);
    event GoalReached(uint totalFunds);
    event FundsWithdrawn(address creator, uint amount);
    event RefundIssued(address contributor, uint amount);

    modifier onlyCreator() {
        require(msg.sender == creator, "Only the creator can call this");
        _;
    }

    modifier beforeDeadline() {
        require(block.timestamp < deadline, "Deadline has passed");
        _;
    }

    modifier afterDeadline() {
        require(block.timestamp >= deadline, "Deadline not reached yet");
        _;
    }

    modifier goalNotReached() {
        require(!goalReached, "Funding goal already reached");
        _;
    }

    constructor(uint _goalAmount, uint _durationInMinutes) {
        creator = msg.sender;
        goalAmount = _goalAmount;
        deadline = block.timestamp + (_durationInMinutes * 1 minutes);
        totalFunds = 0;
        goalReached = false;
        fundsWithdrawn = false;
    }

    function contribute() public payable beforeDeadline goalNotReached {
        require(msg.value > 0, "Contribution must be greater than zero");
        contributions[msg.sender] += msg.value;
        totalFunds += msg.value;

        emit ContributionReceived(msg.sender, msg.value);

        if (totalFunds >= goalAmount) {
            goalReached = true;
            emit GoalReached(totalFunds);
        }
    }

    function withdrawFunds() public onlyCreator afterDeadline {
        require(goalReached, "Funding goal not reached");
        require(!fundsWithdrawn, "Funds already withdrawn");

        fundsWithdrawn = true;
        payable(creator).transfer(totalFunds);

        emit FundsWithdrawn(creator, totalFunds);
    }

    function claimRefund() public afterDeadline {
        require(!goalReached, "Goal was reached; no refunds available");
        uint amount = contributions[msg.sender];
        require(amount > 0, "No contributions to refund");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit RefundIssued(msg.sender, amount);
    }

    function getRemainingTime() public view returns (uint) {
        if (block.timestamp >= deadline) {
            return 0;
        }
        return deadline - block.timestamp;
    }
}