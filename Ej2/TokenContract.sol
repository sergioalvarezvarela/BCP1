// SPDX-License-Identifier: Unlicenced
pragma solidity 0.8.18;

contract TokenContract {
    address public owner;
    uint256 public tokenPrice = 5 ether; // Precio de un token en Ether

    struct Receivers {
        string name;
        uint256 tokens;
    }

    mapping(address => Receivers) public users;

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    constructor(){
        owner = msg.sender;
        users[owner].tokens = 100;
    }

    function double(uint _value) public pure returns (uint){
        return _value * 2;
    }

    function register(string memory _name) public {
        users[msg.sender].name = _name;
    }

    function giveToken(address _receiver, uint256 _amount) onlyOwner public{
        require(users[owner].tokens >= _amount);
        users[owner].tokens -= _amount;
        users[_receiver].tokens += _amount;
    }

    function buyTokens(uint256 _tokenAmount) public payable {
        uint256 cost = _tokenAmount * tokenPrice;
        require(msg.value >= cost, "No has enviado suficiente Ether");
        require(users[owner].tokens >= _tokenAmount, "El propietario no tiene suficientes tokens disponibles");

        users[owner].tokens -= _tokenAmount;
        users[msg.sender].tokens += _tokenAmount;
        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }
    }

    function verSaldoETH() public view onlyOwner returns (uint256) {
            return address(this).balance;
    }

}