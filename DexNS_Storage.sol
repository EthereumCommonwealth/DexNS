pragma solidity ^0.4.15;

import './strings.sol';

contract DexNS_Storage {
    using strings for *;
     
    event Error(bytes32);
    
    modifier only_owner
    {
        if ( msg.sender != owner )
        {
            revert();
        }
        _;
    }
    
    modifier only_frontend
    {
        if ( msg.sender != frontend_contract )
        {
            revert();
        }
        _;
    }
    
    address public owner;
    address public frontend_contract;
    
    struct Resolution
    {
        address   owner;
        address   addr;
        string    metadata;
        bool      hideOwner; // do-not-return-owner variable
        bytes32   signature;
    }
    
    mapping (bytes32 => Resolution) public resolution;
    mapping (address => string)     public assignation;
    mapping (bytes32 => address)    public name_assignation;
    
    function DexNS_Storage()
    {
        owner=msg.sender;
        bytes32    sig            = bytes32(sha256("DexNS commission"));
        resolution[sig].owner     = msg.sender;
        resolution[sig].addr      = msg.sender;
        resolution[sig].signature = sig;
        resolution[sig].metadata  = "-ETC";
    }
    
    
    
    function name(string _name) constant returns (bytes32 _hash)
    {
        return bytes32(sha256(_name));
    }
    
    function registerName(address _from, string _name) only_frontend returns (bool _ok)
    {
        bytes32    sig            = bytes32(sha256(_name));
        resolution[sig].owner     = _from;
        resolution[sig].addr      = _from;
        resolution[sig].metadata  = "-ETC";
        resolution[sig].hideOwner = false;
        resolution[sig].signature = sig;
        return true;
    }
    
    function getName(string _name) constant returns (address _owner, address _associatedAddress, string _value, bytes32 _signature)
    {
        bytes32 sig = bytes32(sha256(_name));
        if(resolution[sig].hideOwner) 
        {
            return (0x0, resolution[sig].addr, resolution[sig].metadata, resolution[sig].signature);
        }
        else 
        {
            return (resolution[sig].owner, resolution[sig].addr, resolution[sig].metadata, resolution[sig].signature);
        }
    }
    
    function metadataOf(string _name) constant returns (string memory _value) 
    {
        bytes32 sig = bytes32(sha256(_name));
        return resolution[sig].metadata;
    }
    
    function addressOf(string _name) constant returns (address _addr) 
    {
        bytes32 sig = bytes32(sha256(_name));
        return resolution[sig].addr;
    }

    function ownerOf(string _name) constant returns (address _owner) 
    {
        bytes32 sig = bytes32(sha256(_name));
        if(resolution[sig].hideOwner) 
        {
            revert();
        }
        return resolution[sig].owner;
    }

    function signatureOf(string _name) constant returns (bytes32 _sig) 
    {
        bytes32 sig = bytes32(sha256(_name));
        return sig;
    }
    
    
    function updateName(string _name, address _addr, string _value) only_frontend
    {
        bytes32    sig           = bytes32(sha256(_name));
        resolution[sig].addr     = _addr;
        resolution[sig].metadata = _value;
    }
    
    function updateName(string _name, string _value) only_frontend
    {
        bytes32 sig = bytes32(sha256(_name));
        resolution[sig].metadata = _value;
    }
    
    function updateName(string _name, address _address) only_frontend
    {
        bytes32 sig = bytes32(sha256(_name));
        resolution[sig].addr = _address;
    }
    
    
    // String functions
    
    struct slice
    {
        uint _len;
        uint _ptr;
    }
    
    function toSlice(string self) private returns (slice)
    {
        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }
    
    function memcpy(uint dest, uint src, uint len) private
    {
        // Copy word-length chunks while possible
        for(; len >= 32; len -= 32)
        {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }
    
    function concat(slice self, slice other) private returns (string)
    {
        var ret = new string(self._len + other._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }
    
    function toString(slice self) internal returns (string)
    {
        var ret = new string(self._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        memcpy(retptr, self._ptr, self._len);
        return ret;
    }
    
    function StringAppend(string _str1, string _str2) private constant returns (string)
    {
        return concat(toSlice(_str1), toSlice(_str2));
    }
    
    function appendNameMetadata(string _name, string _value) only_frontend
    {
        bytes32 sig = bytes32(sha256(_name));
        resolution[sig].metadata = StringAppend(resolution[sig].metadata, _value);
    }
    
    function changeNameOwner(string _name, address _newOwner) only_frontend
    {
        bytes32 sig = bytes32(sha256(_name));
        resolution[sig].owner = _newOwner;
    }
    
    
    // @dev do not return owner on getName()
    function hideNameOwner(string _name, bool _hide) only_frontend
    {
        bytes32 sig = bytes32(sha256(_name));
        resolution[sig].hideOwner = _hide;
    }
    
    function assignName(string _name) only_frontend
    {
        assignation[msg.sender] = _name;
        name_assignation[sha256(_name)] = msg.sender;
    }
    
    function unassignName(string _name) only_frontend
    {
        assignation[msg.sender] = "";
        name_assignation[sha256(_name)] =0x0;
    }
    
    function assignation(address _assignee) constant returns (string _name)
    {
        return assignation[_assignee];
    }
    
    function name_assignation(string _name) constant returns (address _assignee)
    {
        return name_assignation[sha256(_name)];
    }
    
    // DEBUG
    
    function change_Owner(address _newOwner) only_owner {
        owner=_newOwner;
    }
    
    function change_FrontEnd(address _newFrontEnd) only_owner {
        frontend_contract = _newFrontEnd;
    }
}
