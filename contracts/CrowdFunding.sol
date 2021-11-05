// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract CrowdFunding{
    mapping(address => uint) public contributors;
    address public admin;
    uint public noOfContributors;
    uint public minContribution;
    uint public deadline;
    uint public goal;
    uint public raisedAmount;

    constructor(address _admin, uint _minContribution, uint _deadline, uint _goal){
        admin = _admin;
        minContribution = _minContribution;
        deadline = block.timestamp + _deadline;
        goal = _goal;
        raisedAmount = 0;
    }
}