pragma solidity ^0.4.10;

 /**
 * Dexaran Naming Service
 * simple analogue of ENS or ECNS
 * WARNING! This is the very unfinished version!
 */
 
 contract DNS {
     function name(string) constant returns (bytes32);
     function getName(string) constant returns (address _owner, address _associated, string _value, uint _end);
     
     function ownerOf(string) constant returns (address);
     function addressOf(string) constant returns (address);
     function valueOf(string) constant returns (string);
     function endblockOf(string) constant returns (uint);
 }
 
 
/** contract Test {
 * 
 *   address disposableObject;
 *   address constant_name_service;
 *   function() payable {
 *         //disposableObject.call.value(25000)(msg.data);
 *         
 *        DNS a = DNS(constant_name_service);
 *        a.addressOf("ETC dev team").send(msg.value);
 *    }
 *}
 */
 
 contract DexaranNamingService {
     
    event NamePriceChanged(uint indexed _price);
    event OwningTimeChanged(uint indexed _blocks);
    event DebugDisabled();
    
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
    address owner;
    bool debug = true;
    uint owningTime = 1500000;
    uint namePrice = 1000000000000000000;
    
    struct Resolution {
        address  owner;
        address addr;
        string value;
        uint endblock;
        bool hideOwner;
        bytes32 signature;
    }
    
    mapping (bytes32 => Resolution) resolution;
    
    function DexaranNamingService() {
        owner=msg.sender;
        bytes32 sig = bytes32(sha256("DNS comission"));
        resolution[sig].owner = msg.sender;
        resolution[sig].addr = msg.sender;
        resolution[sig].endblock = block.number + 1500000;
        resolution[sig].signature = sig;
    }
    
    
    
    function name(string _name) constant returns (bytes32 hash) {
        return bytes32(sha256(_name));
    }
    
    function registerName(string _name) payable returns (bool ok) {
        if(!(msg.value < namePrice)) {
            bytes32 sig = bytes32(sha256(_name));
            if((resolution[sig].owner == 0x0) || (resolution[sig].endblock < block.number))
            {
                resolution[sig].owner = msg.sender;
                resolution[sig].addr = msg.sender;
                resolution[sig].value = "registered";
                resolution[sig].hideOwner = false;
                resolution[sig].endblock = block.number + owningTime;
                resolution[sig].signature = sig;
                if (resolution[bytes32(sha256("DNS comission"))].addr.send(msg.value)) {
                    return true;
                }
            }
        }
        throw;
    }
    
    function getName(string _name) constant returns (address _owner, address _associatedAddress, string _value, uint _endblock, bytes32 _signature) {
        bytes32 sig = bytes32(sha256(_name));
        if(resolution[sig].hideOwner) {
            return (0x0, resolution[sig].addr, resolution[sig].value, resolution[sig].endblock, resolution[sig].signature);
        }
        else {
            return (resolution[sig].owner, resolution[sig].addr, resolution[sig].value, resolution[sig].endblock, resolution[sig].signature);
        }
    }
    
    function valueOf(string _name) constant returns (string _value) {
        bytes32 sig = bytes32(sha256(_name));
        return resolution[sig].value;
    }
    
    function addressOf(string _name) constant returns (address _addr) {
        bytes32 sig = bytes32(sha256(_name));
        return resolution[sig].addr;
    }

    function ownerOf(string _name) constant returns (address _owner) {
        bytes32 sig = bytes32(sha256(_name));
        if(resolution[sig].hideOwner) {
            throw;
        }
        return resolution[sig].owner;
    }
    
    function endblockOf(string _name) constant returns (uint _endblock) {
        bytes32 sig = bytes32(sha256(_name));
        return resolution[sig].endblock;
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
    
    function updateName(string _name, string _value) {
        bytes32 sig = bytes32(sha256(_name));
        if(msg.sender == resolution[sig].owner) {
            resolution[sig].value = _value;
        }
        else {
            throw;
        }
    }
    
    function updateName(string _name, address _address) {
        bytes32 sig = bytes32(sha256(_name));
        if(msg.sender == resolution[sig].owner) {
            resolution[sig].addr = _address;
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
    
    function hideNameOwner(string _name, bool _hide) {
        bytes32 sig = bytes32(sha256(_name));
        if(msg.sender == resolution[sig].owner) {
            resolution[sig].hideOwner = _hide;
        }
        else {
            throw;
        }
    }
    function extendNameBindingTime(string _name) payable {
        bytes32 sig = bytes32(sha256(_name));
        if((msg.sender == resolution[sig].owner) && (msg.value >= namePrice)) {
            if(resolution[bytes32(sha256("DNS comission"))].addr.send(msg.value)) {
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
    
    function disableDebug_ONLYDEBUG(address _newOwner) onlyOwner onlyDebug {
        debug=false;
        DebugDisabled();
    }
    
    function setOwningTime_ONLYDEBUG(uint _newOwningTime) onlyOwner onlyDebug {
        owningTime = _newOwningTime;
        OwningTimeChanged(_newOwningTime);
    }
    
    function changeNamePrice_ONLYDEBUG(uint _newNamePrice) onlyOwner onlyDebug {
        namePrice = _newNamePrice;
        NamePriceChanged(_newNamePrice);
    }
    
    function dispose_ONLYDEBUG() onlyOwner onlyDebug {
        selfdestruct(owner);
    }
    
    function delegateCall(address _target, uint _gas, bytes _data) payable onlyOwner {
        _target.call.value(_gas)(_data);
    }
}
