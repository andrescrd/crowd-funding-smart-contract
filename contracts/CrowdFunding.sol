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

    struct Request {
        string description;
        address payable beneficiary;
        uint amount;
        bool completed;
        uint numVotes;
        mapping(address => bool) voted;
    }

    uint numRequests;   
    mapping(uint => Request) public requests;

    constructor(address _admin, uint _minContribution, uint _deadline, uint _goal){
        admin = _admin;
        minContribution = _minContribution;
        deadline = block.timestamp + _deadline;
        goal = _goal;
        raisedAmount = 0;
    }

    function contribute() public payable {
        require(block.timestamp < deadline, 'Campaign has ended!');
        require(msg.value >= minContribution, 'Contribution is less than minimum!');

        if(contributors[msg.sender] == 0){
            noOfContributors++;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    receive() payable external{
        contribute();
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function getRefaund() public {
        require(block.timestamp > deadline && raisedAmount < goal, 'Campaign has ended!');
        require(contributors[msg.sender] > 0, 'You have not contributed!');

        address payable recipient = payable(msg.sender);
        uint refund = contributors[msg.sender];
        recipient.transfer(refund);

        contributors[msg.sender] = 0;
    }

    function createRequest(string memory _description, address payable _beneficiary, uint _amount) public onlyAdmin {
        Request storage request = requests[numRequests];
        numRequests++;

        request.description = _description;
        request.beneficiary = _beneficiary;
        request.amount = _amount;
        request.completed = false;
        request.numVotes = 0;
    }

    modifier onlyAdmin{
        require(msg.sender == admin, 'Only admin can call this function!');
        _;
    }
}