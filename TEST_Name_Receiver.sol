pragma solidity ^0.4.15;

// This contract is designed to illustrate a process of Name transfer handling
// by third party contract.
 
 contract NameReceiver {
     event I_have_received_a_name(address indexed _from);
     event InternalInvocation(uint256 indexed _test);
     
     function onNameOwnerChanged(string _name, address _sender, bytes _data) {
         I_have_received_a_name(_sender);
     }
     
     function internalInvocation(uint256 _num) {
         InternalInvocation(_num);
     }
 }
