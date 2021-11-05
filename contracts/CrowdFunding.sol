// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract CrowdFunding{
    mapping(address => uint) public contributors;
    address public admin;
    uint public numContributors;
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
        mapping(address => bool) voters;
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

    event ContributionEvent(address contributor, uint amount);
    event CreateRequestEvent(string description, address beneficiary, uint amount);
    event MakePaymentEvent(address contributor, uint amount);

    function contribute() public payable {
        require(block.timestamp < deadline, 'Campaign has ended!');
        require(msg.value >= minContribution, 'Contribution is less than minimum!');

        if(contributors[msg.sender] == 0){
            numContributors++;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;

        emit ContributionEvent(msg.sender, msg.value);
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

        emit CreateRequestEvent(_description, _beneficiary, _amount);
    }

    function voteRequest(uint _requestNum){
        require(contributors[msg.sender] > 0, 'You have not contributed!');
        require(block.timestamp < deadline, 'Campaign has ended!');

        Request storage request = requests[_requestNum];

        require(request.completed == false, 'Request has already been completed!');
        require(request.voters[msg.sender] == false, 'You have already voted!');

        request.voters[msg.sender] = true;
        request.numVotes++;
    }

    function makePayment(uint _requestNum) public onlyAdmin{
        require(raisedAmount >= goal, 'Campaign has not reached goal!');
        Request storage request = requests[_requestNum];

        require(request.completed == false, 'Request has already been completed!');
        require(request.numVotes  >= numContributors / 2, 'Not enough votes!');

        request.beneficiary.transfer(request.amount);
        request.completed = true;

        emit MakePaymentEvent(request.beneficiary, request.amount);
    }

    modifier onlyAdmin{
        require(msg.sender == admin, 'Only admin can call this function!');
        _;
    }
}