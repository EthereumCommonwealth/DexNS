# Decentralized Naming Service

DexNS 3.0 contracts would be deployed soon.


# Description

Service provides an opportunity to register a key-phrase 'Name' and associate one address (wallet or contract) and one string variable (metadata) with each key-phrase. External contracts can access Naming Service variables as follows:

```js

// The following will initiate a call of address,
// that is associated with "Bit Ether Coin" string.
NamingService ns= new NamingService();
ns.addressOf("Bit Ether Coin").call(_gas)(_data);
```

Addresses or data can be accessed from the external contract. 
Naming Service content can't be blocked, removed or censored in any other way. Everyone is allowed to do whatever he/she wants with it.

# Details 

- `Name` is a key-phrase that will be associated with name data. Each `Name` contains:
    - `owner`       the owner of Name.
    - `addr`        associated address.
    - `metadata`    stringified associated data.
    - `hideOwner`   If set to `true` then the contract will `throw` any attempt to access `ownerOf(Name)`.
    - `signature`   sha256 hash of this Name key-phrase.
    

You can register Name and became its owner. You will own the name before the expiry of the `nameOwning` time. If no one will claim your Name after `expiration[Name]`, then you will continue to be the Name owner. If the Name will be re-registered after the expiration, then you will lose control over this Name. You can extend the term of ownership of the Name before it expires.

### Functions

##### registerName

```js
function registerName(string _name) payable returns (bool ok)
```
Register a new name at Naming Service. `msg.sender` will become `owner` and `address` of this name. `metadata` will be set to "registered".

##### addressOf

```js
function addressOf(string _name) constant returns (address _addr)
```
Returns `address` of the destination of the name.

##### ownerOf
```js
function ownerOf(string _name) constant returns (address _owner)
```
Returns `owner` of the name.

#### endtimeOf
```js
function endtimeOf(string _name) constant returns (uint _expires)
```
Returns timestamp when the name will become free to re-register. Returns 0 for not registered names.

NOTE: `endtime` is stored at the logical contract. Not in storage. Logic of registering and freeing names is part of logical contract. Storage only accepts calls from it.

#### updateName
```js
function updateName(string _name, address _addr, string _value) { }
function updateName(string _name, address _addr) { }
function updateName(string _name, string _value) { }
```

Changes the contents of `_name` and sets the provided parameters.

#### appendNameMetadata
```js
 function appendNameMetadata(string _name, string _value)
```
Adds the provided `_value` to the end of the already-existing metadata string of the `_name`.

#### changeNameOwner
```js
function changeNameOwner(string _name, address _newOwner)
```
Changes `_name` owner to `_newOwner`.

#### hideNameOwner
```js
function hideNameOwner(string _name, bool _hide)
```
If `_hide` is true then `ownerOf(_name)` will `throw` whenever called. 

Rationale: add possibility to abort execution of transaction/call when someone is trying to interact with name `owner` from external contract. Address that is associated with each `_name` is `addressOf(_name)`, not `ownerOf(_name)` !

#### assignName
```js
function assignName(string _name)
```

Assigns `_name` to `msg.sender` if sender is an owner of the name.

#### unassignName
```js
function unassignName(string _name)
```

Clears `_name` ussignation if `msg.sender` is an owner of the name.

#### extendNameBindingTime
```js
function extendNameBindingTime(string _name) payable
```

Extends binding time of the `_name` by constant specified period if sender provided more funds that required to register/update name. (default 0, free names)

#### Debugging functions (for owner only)

#### change_Storage_Address
```js
function change_Storage_Address(address _newStorage)
```

Changes address of the storage to `_newStorage`.

#### change_Owner
```js
function change_Owner(address _newOwner)
```

Changes owner of the contract to `_newOwner`.

#### disable_Debug
```js
function disable_Debug()
```

Disables possibility to debug the contract.

#### set_Owning_Time
```js
function set_Owning_Time(uint _newOwningTime)
```

Sets the specified time period for the name binding.

#### change_Name_Price
```js
function change_Name_Price(uint _newNamePrice)
```

Sets the specified price for the name registering


## Events

#### Error

```js
event Error(bytes32)
```
Triggered when error occurs.

#### NamePriceChanged

```js
event NamePriceChanged(uint indexed _price)
```
Triggered when price of name is changed by the owner.

#### OwningTimeChanged

```js
event OwningTimeChanged(uint indexed _period)
```
Triggered when binding preiod of time is changed by the owner.

#### DebugDisabled

```js
event DebugDisabled()
```
Triggered when debug is disabled.


### Storage contract

#### functions that would be called from DexNS contract to modify state

```js
function registerName(string _name) payable returns (bool ok) { }
function updateName(string _name, address _addr, string _value) { }
function updateName(string _name, address _addr) { }
function updateName(string _name, string _value) { }
function appendNameMetadata(string _name, string _value) { }
function changeNameOwner(string _name, address _newOwner) { }
function hideNameOwner(string _name, bool _hide) { }
function assignName(string _name) { }
function unassignName(string _name) { }
```

### functions to return contract data state

#### addressOf

```js
function addressOf(string _name) constant returns (address _addr)
```
Returns `address` of the destination of the name.

#### ownerOf
```js
function ownerOf(string _name) constant returns (address _owner)
```
Returns `owner` of the name.

#### metadataOf
```js
function metadataOf(string _name) constant returns (string memory _value) 
```
Returns `owner` of the name.

#### assignation
```js
 function assignation(address _assignee) constant returns (string _name)
```
Returns `_name` that is currently assigned to `_assignee`.

#### name_assignation
```js
function name_assignation(string _name) constant returns (address _assignee)
```
Returns `_assignee` address that is currently assigned to `_name`.



#### Debugging functions (for owner only)

#### change_FrontEnd
```js
function change_FrontEnd(address _newFrontEnd)
```

Changes address of the storage to `_newFrontEnd`.

#### change_Owner
```js
function change_Owner(address _newOwner)
```

Changes owner of the contract to `_newOwner`.


## Events

#### Error

```js
event Error(bytes32)
```
Triggered when error occurs.

## Metadata specification

Use key flags before data chunks.
`-A ` for ABI.
`-L ` for attached link.
`-S ` for source code reference.

Example of metadata for DexNS contract:
`-L https://author.me/ -S https://github.com/source -A [{"constant":false,"inputs":[],"name":"foo","outputs":[],"payable":false,"type":"function"}]`

## Notes

`MyContract` / `      something        strange` / `%20%20%11` are valid names for DexNS. It has no checks for inputs. All names that you can imagine are valid.

It can be a good idea to use versions for testing contracts: `MyTest v1.0.0` / `MyTest v9.256.122` etc.
