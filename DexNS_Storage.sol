pragma solidity ^0.4.15;

contract DexNS_Storage {
     
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
        address  owner;
        address  addr;
        string   metadata;
        bool     hideOwner; // do-not-return-owner variable
        bytes32  signature;
    }
    
    mapping (bytes32 => Resolution) public resolution;
    mapping (address => string)     public assignation;
    mapping (bytes32 => address)    public name_assignation;
    
     /** 
     * @dev Constructor
     */
    function DexNS_Storage()
    {
        owner                     = msg.sender;
        bytes32    sig            = bytes32(sha256("DexNS commission"));
        resolution[sig].owner     = msg.sender;
        resolution[sig].addr      = msg.sender;
        resolution[sig].signature = sig;
        resolution[sig].metadata  = "-ETC";
    }
    
    /** 
    * @dev Returns keccak-256 hash of the Name.
    * 
    * @return hash The hash of the name.
    */
    function name(string _name) constant returns (bytes32 _hash)
    {
        return bytes32(sha256(_name));
    }
    
    /** 
    * @dev Registers a new name with default content.
    * 
    * This function will return `true` in case of successful execution. It will revert() The
    * transaction in case of failure and thus send back money.
    * 
    * @param _from  Address that attempts to register this Name.
    * @param _name  The Name that the user wants to register.
    * 
    * @return ok    True on successful Name registration, false in any other cases.
    */
    function registerName(address _from, string _name) only_frontend returns (bool _ok)
    {
        bytes32 sig               = bytes32(sha256(_name));
        resolution[sig].owner     = _from;
        resolution[sig].addr      = _from;
        resolution[sig].metadata  = "-ETC";
        resolution[sig].hideOwner = false;
        resolution[sig].signature = sig;
        return true;
    }
    
    /** 
    * @dev Registers a new name with predefined content.
    * 
    * This function will return `true` in case of successful execution. It will revert() The
    * transaction in case of failure and thus send back money.
    * 
    * @param _name        The name that the user wants to register.
    * @param _owner       Address that will become the owner of the Name after the registration.
    * @param _destination The address to which this name will be indicated.
    * @param _metadata    Metadata of the Name.
    * @param _hideOwner   If true, then DexNS will throw on any attempt to access the name owner.
    * 
    * @return ok          True on successful Name registration, false in any other cases.
    */
    function registerAndUpdateName(string _name, address _owner, address _destination, string _metadata, bool _hideOwner) only_frontend returns (bool _ok)
    {
        bytes32 sig               = bytes32(sha256(_name));
        resolution[sig].owner     = _owner;
        resolution[sig].addr      = _destination;
        resolution[sig].metadata  = _metadata;
        resolution[sig].hideOwner = _hideOwner;
        resolution[sig].signature = sig;
        return true;
    }
    
    /** 
    * @dev Returns a content of the Name.
    * 
    * @param _name        The name that the user wants to inspect.
    * 
    * @return _owner       Address that has permission to change a content of the Name.
    *                     Returns 0 if `hideOwner` is set to true for this Name.
    * @return _associatedAddress The address that is indicated to this Name.
    * @return _value       Metadata of the Name.
    * @return _signature   keccak-256 hash of the Name.
    */
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
    
    /** 
    * @dev Returns metadata of the Name.
    * 
    * @param _name        The name that the user wants to inspect.
    * 
    * @return _value       Metadata of the Name.
    */
    function metadataOf(string _name) constant returns (string memory _value) 
    {
        bytes32 sig = bytes32(sha256(_name));
        return resolution[sig].metadata;
    }
    
    /** 
    * @dev Returns destination address of the Name.
    * 
    * @param _name        The name that the user wants to inspect.
    * 
    * @return _value       Metadata of the Name.
    */
    function addressOf(string _name) constant returns (address _addr) 
    {
        bytes32 sig = bytes32(sha256(_name));
        return resolution[sig].addr;
    }
    
    /** 
    * @dev Returns owner address of the Name or throws if the `hideOwner` is true for this name.
    * 
    * @param _name    The name that the user wants to inspect.
    * 
    * @return _owner  Address that has permission to change a content of this Name.
    */
    function ownerOf(string _name) constant returns (address _owner) 
    {
        bytes32 sig = bytes32(sha256(_name));
        if(resolution[sig].hideOwner) 
        {
            revert();
        }
        return resolution[sig].owner;
    }
    
    /** 
    * @dev Returns keccak-256 hash of the Name.
    * 
    * @param _name  The name that the user wants to inspect.
    * 
    * @return _sig  Keccak-256 hash of the Name.
    */
    function signatureOf(string _name) constant returns (bytes32 _sig) 
    {
        bytes32 sig = bytes32(sha256(_name));
        return sig;
    }
    
    /** 
    * @dev Updates a content of the Name.
    * 
    * Function is overloaded to allow any configurations of Name updates
    * ie. update only destination address, only metadata or destination address and metadata.
    *
    * @param _name   Name that the user wants to update.
    * @param _addr   The address to which this name will be resolved.
    * @param _value  Metadata of the Name.
    */
    function updateName(string _name, address _addr, string _value) only_frontend
    {
        bytes32    sig           = bytes32(sha256(_name));
        resolution[sig].addr     = _addr;
        resolution[sig].metadata = _value;
    }
    
    /** 
    * @dev Updates a content of the Name.
    * 
    * Function is overloaded to allow any configurations of Name updates
    * ie. update only destination address, only metadata or destination address and metadata.
    *
    * @param _name   Name that the user wants to update.
    * @param _value  Metadata of the Name.
    */
    function updateName(string _name, string _value) only_frontend
    {
        bytes32    sig           = bytes32(sha256(_name));
        resolution[sig].metadata = _value;
    }
    
    /** 
    * @dev Updates a content of the Name.
    * 
    * Function is overloaded to allow any configurations of Name updates
    * ie. update only destination address, only metadata or destination address and metadata.
    *
    * @param _name     Name that the user wants to update.
    * @param _address  The address to which this name will be resolved.
    */
    function updateName(string _name, address _address) only_frontend
    {
        bytes32    sig       = bytes32(sha256(_name));
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
    
    /** 
    * @dev Appends the characters to current metadata of the Name.
    *
    * @param _name   Name that the user wants to update.
    * @param _value  Characters to add to current metadata of the Name.
    */
    function appendNameMetadata(string _name, string _value) only_frontend
    {
        bytes32    sig           = bytes32(sha256(_name));
        resolution[sig].metadata = StringAppend(resolution[sig].metadata, _value);
    }
    
    /** 
    * @dev Transfer ownership of the Name.
    * 
    * Frontend contract will call the handler function of the receiver
    * if the receiver is a smart-contract.
    *
    * @param _name      Name that the user wants to update.
    * @param _newOwner  Address to which a user want to transfer Name ownership.
    */
    function changeNameOwner(string _name, address _newOwner) only_frontend
    {
        bytes32    sig        = bytes32(sha256(_name));
        resolution[sig].owner = _newOwner;
    }
    
    /** 
    * @dev Set throw mode of the getName and ownerOf functions.
    *
    * @param _name  Name that the user wants to update.
    * @param _hide  True will make contract throw, false will make it returning ower normally.
    */
    function hideNameOwner(string _name, bool _hide) only_frontend
    {
        bytes32    sig            = bytes32(sha256(_name));
        resolution[sig].hideOwner = _hide;
    }
    
    /** 
    * @dev Create the assignation between the Name and its owner's address.
    * 
    * This may be necessary for blockchain explorers to display a human-readable Name
    * instead of hex address.
    *
    * @param _name         Name that will be assigned to the _destination address
    *                      if the address is the owner of the Name.
    * @param _destination  Address that will be assigned with the Name.
    */
    function assignName(string _name, address _destination) only_frontend
    {
        assignation[_destination]       = _name;
        name_assignation[sha256(_name)] = _destination;
    }
    
    /** 
    * @dev Destroy the assignation between the Name and its owner's address.
    *
    * @param _name         Name that will no longer be assigned to its owner's address.
    */
    function unassignName(string _name) only_frontend
    {
        assignation[name_assignation[sha256(_name)]]       = "";
        name_assignation[sha256(_name)] = 0x0;
    }
    
    /** 
    * @dev Returns a Name that is assigned to the address.
    *
    * @param _assignee  Address that a user wants to inspect.
    * 
    * @return _name     Name that is assigned to this address.
    */
    function assignation(address _assignee) constant returns (string _name)
    {
        return assignation[_assignee];
    }
    
    /** 
    * @dev Returns an address that is assigned to the Name.
    *
    * @param _name       Name that a user wants to inspect.
    * 
    * @return _assignee  Address that is assigned to this Name.
    */
    function name_assignation(string _name) constant returns (address _assignee)
    {
        return name_assignation[sha256(_name)];
    }
    
    // Debug functions.
    
    function change_Owner(address _newOwner) only_owner {
        owner =_newOwner;
    }
    
    function change_FrontEnd_Address(address _newFrontEnd) only_owner {
        frontend_contract = _newFrontEnd;
    }
}
