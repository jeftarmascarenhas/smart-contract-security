// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/*
* Delegatecall é um chamada de mensagem que executa um código de um contrato dentro do outro
* Porem contexto da execução é o do contrato chamador, ou seja se você chama uma função
* Do Contrato A dentro do Contrato B a excursão e alterações de estado será feito no contrato B
* e não no contrato A.
*/

/*
* Delegatecall afeta as variáveis ​​de estado do contrato que chama uma função com delegadocall.
* As variáveis ​​de estado do contrato que contém as funções emprestadas não são lidas nem gravadas.
*/
contract CotractCalled {
  uint8 public num;
  address public owner;
  uint256 public time;
  string public message;
  bytes public data;

  function callOne() public{
      num = 100;
      owner = msg.sender;
      time = block.timestamp;
      message = "Darah";
      data = abi.encodePacked(num, msg.sender, block.timestamp);
  }
}


contract CallerContract {
  uint8 public num;
  address public owner;
  uint256 public time;
  string public message;
  bytes public data;

  function callTwo(address contractAddress) public returns(bool){
      (bool success,) = contractAddress.delegatecall(
          abi.encodeWithSignature("callOne()")
      );
      return success;
    }
}