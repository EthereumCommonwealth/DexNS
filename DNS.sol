pragma solidity ^0.4.10;

 /**
 * Dexaran Naming Service
 * simple analogue of ENS or ECNS
 */
 
 contract DNS {
     function name(string) constant returns (bytes32);
     function getName(string) constant returns (address _owner, address _associated, string _value, uint _end);
     
     function ownerOf(string) constant returns (address);
     function addressOf(string) constant returns (address);
     function valueOf(string) constant returns (string);
     function endblockOf(string) constant returns (uint);
     
     function ownerByHash(bytes32) constant returns (address);
     function addressByHash(bytes32) constant returns (address);
     function valueByHash(bytes32) constant returns (string);
     function endblockByHash(bytes32) constant returns (uint);
 }
 
 contract DexaranNamingService {
     
    
    modifier onlyOwner {
        if (msg.sender!=owner)
            throw;
        _;
    }
    
    modifier onlyDebug {
        if (!debug)
            throw;
        _;
    }
    
    address public owner;
    bool public debug = true;
    uint public owningTime = 1500000;
    uint public namePrice = 1000000000000000000;
    
    struct Resolution {
        address  owner;
        address addr;
        string value;
        uint endblock;
    }
    
    mapping (bytes32 => Resolution) resolution;
    
    function DexaranNamingService() {
        owner=msg.sender;
    }
    
    
    
    function name(string _name) constant returns (bytes32 hash) {
        return bytes32(sha256(_name));
    }
    
    function registerName(string _name) payable returns (bool ok) {
        if(!(msg.value < namePrice)) {
            if((resolution[sig].owner == 0x0) || (resolution[sig].endblock < block.number))
            {
                bytes32 sig = bytes32(sha256(_name));
                resolution[sig].owner = msg.sender;
                resolution[sig].value = _name;
                resolution[sig].endblock = block.number + owningTime;
            }
            if (owner.send(msg.value)) {
                return true;
            }
        }
        throw;
    }
    
    function getName(string _name) constant returns (address _owner, address _associatedAddress, string _value, uint _endblock) {
        bytes32 sig = bytes32(sha256(_name));
        return (resolution[sig].owner, resolution[sig].addr, resolution[sig].value, resolution[sig].endblock);
    }
    
    
    function valueOf(string _name) constant returns (string _value) {
        bytes32 sig = bytes32(sha256(_name));
        return resolution[sig].value;
    }
    function valueOfByHash(bytes32 _name) constant returns (string _value) {
        return resolution[_name].value;
    }
    
    
    function addressOf(string _name) constant returns (address _addr) {
        bytes32 sig = bytes32(sha256(_name));
        return resolution[sig].addr;
    }
    function addressOfByHash(bytes32 _name) constant returns (address _addr) {
        return resolution[_name].addr;
    }
    
    

    function ownerOf(string _name) constant returns (address _owner) {
        bytes32 sig = bytes32(sha256(_name));
        return resolution[sig].owner;
    }    function ownerOfByHash(bytes32 _name) constant returns (address _owner) {
        return resolution[_name].owner;
    }
    
    
    function endblockOf(string _name) constant returns (uint _endblock) {
        bytes32 sig = bytes32(sha256(_name));
        return resolution[sig].endblock;
    }
    function endblockByHash(bytes32 _name) constant returns (uint _endblock) {
        return resolution[_name].endblock;
    }
    
    
    
    function updateName(string _name, address _addr, string _value) {
        bytes32 sig = bytes32(sha256(_name));
        if(msg.sender == resolution[sig].owner) {
            resolution[sig].addr = _addr;
            resolution[sig].value = _value;
        }
        else {
            throw;
        }
    }
    
    function changeNameOwner(string _name, address _newOwner) {
        bytes32 sig = bytes32(sha256(_name));
        if(msg.sender == resolution[sig].owner) {
            resolution[sig].owner = _newOwner;
        }
        else {
            throw;
        }
    }
    function updateBindingTime(string _name) payable {
        bytes32 sig = bytes32(sha256(_name));
        if((msg.sender == resolution[sig].owner) && (msg.value >= namePrice)) {
            if(owner.send(msg.value)) {
                resolution[sig].endblock = block.number + owningTime;
            }
        }
        else {
            throw;
        }
    }
    
    
    
    function changeOwner(address _newOwner) onlyOwner {
        owner=_newOwner;
    }
    
    function disableDebug(address _newOwner) onlyOwner onlyDebug {
        debug=false;
    }
    
    function changeOwningTime(uint _newOwningTime) onlyOwner onlyDebug {
        owningTime = _newOwningTime;
    }
    
    function changeNamePrice(uint _newNamePrice) onlyOwner onlyDebug {
        namePrice = _newNamePrice;
    }
    
    function dispose() onlyOwner onlyDebug {
        selfdestruct(owner);
    }
    
    function delegateCall(address _target, uint _gas, bytes _data) payable onlyOwner {
        _target.call.value(_gas)(_data);
    }
}