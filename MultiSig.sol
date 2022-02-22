// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

contract MultiSigWallet {
    address principalAdmin;
    address[] otherAdmin;
    uint quorum;
    constructor(address _principalAdmin, uint _quorum) {
        principalAdmin = _principalAdmin;
        quorum = _quorum;
    }

    modifier onlyPrincipalAdmin() {
        require(msg.sender == principalAdmin, "Not Principal Owner");
        _;
    }

    struct Transaction {
        uint id;
        uint amount;
        address payable to;
        bool status;
        uint approval;
    }
    mapping(uint => Transaction) transaction;
    mapping(address => mapping(uint => bool)) certifyAddr;
    Transaction[] transactions; 

    function setApproverAddr(address _addr) public onlyPrincipalAdmin {
        otherAdmin.push(_addr);
    }

    function getApproverAddr() public view returns (address[] memory) {
        return otherAdmin;
    }

    function makeTransaction(uint _amount, address payable _to) public {
        transactions.push(Transaction(
            transactions.length,
            _amount,
            _to,
            false,
            0
        ));
    }

    function getTransaction() public view returns(Transaction[] memory) {
        return transactions;
    }

    function approveTransaction(uint _id) public onlyApprovers {
        require(transactions[_id].status == false, "Transaction has been sent");
        require(certifyAddr[msg.sender][_id] == false, "Canot Approve Twice");

        certifyAddr[msg.sender][_id] = true;
        transactions[_id].approval++;

        if(transactions[_id].approval >= quorum) {
            address payable to =  transactions[_id].to;
            uint amount =  transactions[_id].amount;

            to.transfer(amount);
             transactions[_id].status = true;
        }        
    }

    modifier onlyApprovers() {
        bool allowed = false;
        for(uint i = 0; i < otherAdmin.length; i++) {
            if(msg.sender == otherAdmin[i]) {
                allowed = true;
            }
        }

        require(allowed == true, "Not an approver");
        _;
    }

    receive() external payable {}


}
