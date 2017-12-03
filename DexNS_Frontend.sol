pragma solidity ^0.4.15;

import './DexNS_Storage.sol';
import './safeMath.sol';

 /*
 * The following is an implementation of the Naming Service that aims to boost
 * the usability of smart-contracts and provide a human-friendly utility
 * to work with low-level smart-contract interactions.
 * 
 * In addition it can be used as a central controlling unit of the system
 * with dynamically linked smart-contracts.
 * 
 * Current implementation aims to simplify searches by contract names
 * and automated loading of ABIs for smart-contracts. 
 * This can be used to provide an automated token adding
 * to the web wallet interfaces like ClassicEtherWallet as well.
 *
 *  Designed by Dexaran, dexaran@ethereumclassic.org
 * 
 */
 
 contract NameReceiver {
     function onNameOwnerChanged(string _name, address _sender, bytes _data);
 }
 
 contract DexNS_Abstract_Interface {
     function name(string)    constant returns (bytes32);
     function getName(string) constant returns (address _owner, address _associated, string _value, uint _end, bytes32 _sig);
     
     function ownerOf(string)   constant returns (address);
     function addressOf(string) constant returns (address);
     function valueOf(string)   constant returns (string);
     function endtimeOf(string) constant returns (uint);
     function updateName(string, string);
     function updateName(string, address);
     function updateName(string, address, string);
     function registerName(string) payable returns (bool);
     function registerAndUpdateName(string, address, address, string, bool) payable returns (bool);
     function changeNameOwner(string, address, bytes);
     function hideNameOwner(string);
     function extendNameBindingTime(string) payable;
     function appendNameMetadata(string, string);
 }
 
 
/** contract Test
 *  {
 *   address constant_name_service;
 *   function() payable
 *   {
 *        DexNS_Storage dexns = DexNS_Storage(constant_name_service);
 *        dexns.addressOf("Recipient name").send(msg.value);
 *   }
 *}
 */
 

/**
 * @title Frontend DexNS contract.
 * @dev The frontend contract is executed when a user wants to register new Name or adjust any parameter
 *      of the already existing Name.
 */
 contract DexNS_Frontend
 {
    using SafeMath for uint256;
    event Error(bytes32);
    event NamePriceChanged(uint indexed _price);
    event OwningTimeChanged(uint indexed _period);
    event DebugDisabled();
    event NameRegistered(string _name, address indexed _owner);
    event NameUpdated(bytes32 indexed _signature);
    event NameTransferred(address indexed _sender, address indexed _receiver, bytes32 indexed _signature, bytes _data);
    event Assignment(address indexed _owner, string _name);
    event Unassignment(string _name);
    
    DexNS_Storage public db;
    
    modifier only_owner
    {
        if ( msg.sender != owner )
            revert();
        _;
    }
    
    modifier only_name_owner(string _name)
    {
        if ( msg.sender != db.ownerOf(_name) )
            revert();
        _;
    }
    
    modifier only_debug
    {
        if ( !debug )
            revert();
        _;
    }
    
    address public owner;
    bool public debug      = true;
    uint public owningTime = 1 year;
    uint public namePrice  = 0;
    string public DexNSCommission = "DexNS commission";
    
    mapping (bytes32 => uint256) public expirations;
    
     /** 
     * @dev Constructor
     */
    function DexNS_Frontend()
    {
        owner             = msg.sender;
        db                = DexNS_Storage(0x50e1acbb41877652782b18a275774fa7efdb0b91);
        bytes32     _sig  = sha256(DexNSCommission);
        expirations[_sig] = 99999999999999999999;
    }
    
    /** 
    * @dev Returns keccak-256 hash of the Name.
    * 
    * @return hash The hash of the name.
    */
    function name(string _name) constant returns (bytes32 hash)
    {
        return bytes32(sha256(_name));
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
    * @param _assign      Assign Name to the _destination address after registration.
    * 
    * @return ok          True on successful Name registration, false in any other cases.
    */
    function registerAndUpdateName(string _name, address _owner, address _destination, string _metadata, bool _hideOwner, bool _assign) payable returns (bool ok)
    {
        if(!(msg.value < namePrice))
        {
            bytes32 _sig = sha256(_name);
            if(expirations[_sig] < now)
            {
                db.registerAndUpdateName(_name, _owner, _destination, _metadata, _hideOwner);
                if(_assign)
                {
                    db.assignName(_name, _destination);
                }
                expirations[_sig] = now.add(owningTime);
                if (db.addressOf(DexNSCommission).send(namePrice))
                {
                    if(msg.value.sub(namePrice) > 0)
                    {
                        msg.sender.transfer(msg.value.sub(namePrice));
                    }
                    NameRegistered(_name, _owner);
                    return true;
                }
            }
        }
        revert();
    }
    
    /** 
    * @dev Registers a new name with default content.
    *
    * @param _name  The name that the user wants to register.
    * 
    * @return ok    True on successful Name registration, false in any other cases.
    */
    function registerName(string _name) payable returns (bool ok)
    {
        if(!(msg.value < namePrice))
        {
            bytes32 _sig = sha256(_name);
            if(expirations[_sig] < now)
            {
                db.registerName(msg.sender, _name);
                expirations[_sig] = now.add(owningTime);
                if (db.addressOf(DexNSCommission).send(namePrice))
                {
                    if(msg.value.sub(namePrice ) > 0)
                    {
                        msg.sender.transfer(msg.value.sub(namePrice));
                    }
                    NameRegistered(_name, msg.sender);
                    return true;
                }
            }
        }
        revert();
    }
    
    /** 
    * @dev Returns the time when the ownership of the name expires (in Unix seconds).
    *
    * @param _name     Name the validity of which we are checking.
    * 
    * @return _expires The expiration date of the name in Unix seconds.
    */
    function endtimeOf(string _name) constant returns (uint _expires)
    {
        return expirations[sha256(_name)];
    }
    
    /** 
    * @dev Updates a content of the Name.
    * 
    * Function is overloaded to allow any configurations of Name updates
    * ie. update only destination address, only metadata or destination address and metadata.
    *
    * @param _name   Name that the user wants to update.
    * @param _addr   The address to which this name will be indicated.
    * @param _value  Metadata of the Name.
    */
    function updateName(string _name, address _addr, string _value) only_name_owner(_name)
    {
        db.updateName(_name, _addr, _value);
        NameUpdated(db.signatureOf(_name));
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
    function updateName(string _name, string _value) only_name_owner(_name)
    {
        db.updateName(_name, _value);
        NameUpdated(db.signatureOf(_name));
    }
    
    /** 
    * @dev Updates a content of the Name.
    * 
    * Function is overloaded to allow any configurations of Name updates
    * ie. update only destination address, only metadata or destination address and metadata.
    *
    * @param _name   Name that the user wants to update.
    * @param _addr   The address to which this name will be indicated.
    */
    function updateName(string _name, address _addr) only_name_owner(_name)
    {
        db.updateName(_name, _addr);
        NameUpdated(db.signatureOf(_name));
    }
    
    /** 
    * @dev Appends the characters to current metadata of the Name.
    *
    * @param _name   Name that the user wants to update.
    * @param _value  Characters to add to current metadata of the Name.
    */
    function appendNameMetadata(string _name, string _value) only_name_owner(_name)
    {
        db.appendNameMetadata(_name, _value);
        NameUpdated(db.signatureOf(_name));
    }
    
    /** 
    * @dev Transfer ownership of the Name.
    * 
    * If the user attempts to transfer the ownership of the Name
    * to the smart-contract then the `onNameOwnerChanged` function
    * of the receiver contract should be executed. If the receiver contract
    * does not implement the `onNameOwnerChanged` function then the fallback
    * function of the receiver contract will be invoked.
    * 
    * The execution will be thrown if the name owner is not accessible for
    * smart-contracts (hideNameOwner = true).
    *
    * @param _name      Name that the user wants to update.
    * @param _newOwner  Address to which a user want to transfer Name ownership.
    * @param _data      Additional transaction metadata.
    */
    function changeNameOwner(string _name, address _newOwner, bytes _data) only_name_owner(_name)
    {
        NameTransferred(msg.sender, _newOwner, sha256(_name), _data);
        db.changeNameOwner(_name, _newOwner);
        if(isContract(_newOwner))
        {
            NameReceiver(_newOwner).onNameOwnerChanged(_name, msg.sender, _data);
        }
    }
    
    /** 
    * @dev Force contract to throw if ownerOf function is executed.
    *
    * @param _name  Name that the user wants to update.
    * @param _hide  If true then contract will throw on `ownerOf`
    *               if false then contract will successfully return owner.
    */
    function hideNameOwner(string _name, bool _hide) only_name_owner(_name)
    {
        db.hideNameOwner(_name, _hide);
        NameUpdated(db.signatureOf(_name));
    }
    
    /** 
    * @dev Create the assignation between the Name and its owner's address.
    * 
    * This may be necessary for blockchain explorers to display a human-readable Name
    * instead of hex address.
    *
    * @param _name      Name that will be assigned to the _assignee's address
    *                   if the address is the owner of the Name.
    * @param _assignee  Address that will be assigned to this Name (this address
    *                   could be replaced with the Name).
    */
    function assignName(string _name, address _assignee) only_name_owner(_name)
    {
        db.assignName(_name, _assignee);
        Assignment(_assignee, _name);
    }
    
    /** 
    * @dev Destroy the assignation between the Name and its owner's address.
    *
    * @param _name  Name that will no longer be assigned to its owner's address.
    */
    function unassignName(string _name) only_name_owner(_name)
    {
        db.unassignName(_name);
        Unassignment(_name);
    }
    
    /** 
    * @dev Extends ownership of the Name for `owningTime` seconds from the current moment of time.
    *
    * @param _name  Name that will be extended.
    */
    function extend_Name_Binding_Time(string _name) payable
    {
        if(msg.value >= namePrice)
        {
           if(db.addressOf(DexNSCommission).send(namePrice))
           {
                expirations[sha256(_name)] = now.add(owningTime);
                if(msg.value.sub( namePrice ) > 0)
                {
                    msg.sender.transfer(msg.value.sub(namePrice));
                }
           }
        }
    }
    
    /** 
    * @dev Debugging function that changes the address of DexNS storage contract.
    *
    * @param _newStorage  Address to be considered a storage contract.
    */
    function change_Storage_Address(address _newStorage) only_owner
    {
        db = DexNS_Storage(_newStorage);
    }
    
    /** 
    * @dev Debugging function that changes the DexNS owner address.
    *
    * @param _newOwner  Address to be considered a new DexNS owner.
    */
    function change_Owner(address _newOwner) only_owner
    {
        owner = _newOwner;
    }
    
    /** 
    * @dev Debugging function that disables debugging mode of DexNS frontend contract.
    */
    function disable_Debug() only_owner only_debug
    {
        debug = false;
        DebugDisabled();
    }
    
    /** 
    * @dev Debugging function that changes default period of time of Name term of ownership.
    *
    * @param _newOwningTime  New period of time that will be considered a default Name term of ownership.
    */
    function set_Owning_Time(uint _newOwningTime) only_owner only_debug
    {
        owningTime = _newOwningTime;
        OwningTimeChanged(_newOwningTime);
    }
    
    /** 
    * @dev Debugging function that changes Name price.
    *
    * @param _newNamePrice  New Name price.
    */
    function change_Name_Price(uint _newNamePrice) only_owner only_debug
    {
        namePrice = _newNamePrice;
        NamePriceChanged(_newNamePrice);
    }
    
    /** 
    * @dev Debugging function that destroys the contract.
    */
    function dispose() only_owner only_debug
    {
        selfdestruct(owner);
    }
    
    /** 
    * @dev Assemble the code of the target contract to decide whether it is a contract or not.
    */
    function isContract(address _addr) private returns (bool is_contract) {
        uint length;
        assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return (length > 0);
    }
    
    /** 
    * @dev Debugging function that allows to send a custom call from this contract.
    *      For example extract stuck tokens.
    *
    * @param _target  Address that will be called from this contract.
    * @param _gas     gasLimit of the call.
    * @param _data    Execution data.
    */
    function debugCall(address _target, uint _gas, bytes _data) payable only_owner only_debug
    {
        if(!_target.call.gas(_gas).value(msg.value)(_data))
        {
            Error(0);
        }
    }
}
