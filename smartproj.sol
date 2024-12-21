// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Insurance Pools for Educational Loan Defaults
 * @dev This contract allows contributors to pool funds and provides a mechanism for claims to assist with educational loan defaults.
 */
contract InsurancePoolsForEduLoanDefaults {
    // State variables
    address public owner;
    uint256 public totalPoolBalance;
    uint256 public totalClaimsPaid;

    mapping(address => uint256) public contributions;
    mapping(address => uint256) public claims;
    mapping(address => bool) public approvedClaimants;

    // Events
    event ContributionReceived(address indexed contributor, uint256 amount);
    event ClaimSubmitted(address indexed claimant, uint256 amount);
    event ClaimApproved(address indexed claimant, uint256 amount);
    event ClaimRejected(address indexed claimant, uint256 amount);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier validAmount(uint256 amount) {
        require(amount > 0, "Amount must be greater than zero");
        _;
    }

    // Constructor
    constructor() {
        owner = msg.sender;
    }

    // Function to contribute funds to the pool
    function contribute() public payable validAmount(msg.value) {
        contributions[msg.sender] += msg.value;
        totalPoolBalance += msg.value;
        emit ContributionReceived(msg.sender, msg.value);
    }

    // Function to submit a claim for loan default assistance
    function submitClaim(uint256 amount) public validAmount(amount) {
        require(claims[msg.sender] == 0, "Claim already submitted");
        claims[msg.sender] = amount;
        emit ClaimSubmitted(msg.sender, amount);
    }

    // Function for the owner to approve a claim
    function approveClaim(address claimant) public onlyOwner {
        uint256 claimAmount = claims[claimant];
        require(claimAmount > 0, "No claim found");
        require(totalPoolBalance >= claimAmount, "Insufficient pool balance");

        claims[claimant] = 0;
        approvedClaimants[claimant] = true;
        totalPoolBalance -= claimAmount;
        totalClaimsPaid += claimAmount;
        payable(claimant).transfer(claimAmount);

        emit ClaimApproved(claimant, claimAmount);
    }

    // Function for the owner to reject a claim
    function rejectClaim(address claimant) public onlyOwner {
        uint256 claimAmount = claims[claimant];
        require(claimAmount > 0, "No claim found");

        claims[claimant] = 0;
        emit ClaimRejected(claimant, claimAmount);
    }

    // Function to withdraw contract funds (only owner)
    function withdraw(uint256 amount) public onlyOwner validAmount(amount) {
        require(amount <= totalPoolBalance, "Insufficient pool balance");
        totalPoolBalance -= amount;
        payable(owner).transfer(amount);
    }

    // Fallback function to handle direct Ether transfers
    receive() external payable {
        contribute();
    }
}
