# Decentralized Naming Service

## Overview

DexNS allows to register human-readable names that could be resolved into Ethereum hex-addresses. Currently, names are free. You can own your name within 1 year after the moment of registration. You can extend name ownership after the certain amount of time will pass. DexNS provides names in human-readable text format. DexNS contract allows any names of any lengths and any characters, but third party services such as ClassicEtherWallet may filter confusing characters and weird names. As the result, it is not recommended to register names with whitespaces and names ending in ENS tld resolutions ( .eth / .etc / .reverse ). You can register your e-mail address as Name for example ( `dexaran@ethereumclassic.org` ). Any user will be able to send ETH, ETC, EXP, UBQ, MUSICOIN and testnet Ether to your address that is assigned to the registered name via ClassicEtherWallet. 

(1) Yes, you can use one DexNS Name on multiple chains to receive different currencies such are ETH, ETC, EXP, UBQ.

(2) Yes, you can store multiple currencies in one Ethereum wallet address.

## Contracts

DexNS 3.0 contracts are currently deployed on ETC mainnet.

#### DexNS_Frontend.sol

This contract serves to register and manage Names.
DexNS frontend contract: [0x101f1920e4cD9c7e2aF056E2cB1954d0DD9647b9](https://gastracker.io/addr/0x101f1920e4cD9c7e2aF056E2cB1954d0DD9647b9)

#### DexNS_Storage.sol

This contract serves to access content of the already-registered Names.
DexNS storage contract: [0x28fc417c046d409c14456cec0fc6f9cde46cc9f3](https://gastracker.io/addr/0x28fc417c046d409c14456cec0fc6f9cde46cc9f3)

# How do I register a name?

1. Navigate to ClassicEtherWallet [contracts tab](https://ethereumproject.github.io/etherwallet/?network=ETC#contracts).

2. Choose DexNS Frontend Contract from default contracts list and click the "ACCESS" button. (make sure that contract address is `0x101f1920e4cD9c7e2aF056E2cB1954d0DD9647b9`)

3. (OPTIONAL: check name availability) Choose `endtimeOf` function name to check whether the name is available or not. 

3.1 (OPTIONAL: check name availability) Type the desired name into `_name string` input box. You should just type Name in text format. For example `dexaran@ethereumclassic.org`.

3.2 (OPTIONAL: check name availability) Click "READ" button and check if the ` _expires uint256` field is equal to 0 or not. As you can see for `dexaran@ethereumclassic.org` it is not equal to zero which means that this name is already owned. You can not register a name that is already owned. You should pick an another name in this case.

4. Choose `registerName` function from the functions dropdown menu.

5. Type the desired Name into `_name string` input box. You should enter the name in text format. You must enter a name in text format as it will be available to others.

6. Unlock your wallet and click "WRITE" button. Make sure that you have provided enough gas for transaction to execute. You should keep in mind that longer Names will require more gas. 200 000 GAS is enough for most names.

7. Wait for transaction to submit. You will immediately become the owner of the name after the transaction is successfully submitted to the block. You will own this Name for 1 year. After 1 year you should visit DexNS contract again if you would like to extend Name ownership.

## Interaction with DexNS

To register or manage names you should call the [DexNS frontend contract](https://github.com/EthereumCommonwealth/DexNS/blob/master/DexNS_Frontend.sol) contract (0x5e9b151eb9742c20679e1d96e5c3633678cab724).

To interact with the contents of already registered names, you should call [DexNS state storage contract](https://github.com/EthereumCommonwealth/DexNS/blob/master/DexNS_Storage.sol) (0x429611c633806a03447391026a538a022e1e2731).

DexNS can also be used as a control unit for dynamically linking contracts in a contract system. You should interact with state storage contract to access names.
Example:

```js
 // This will send 100 WEI to the "My Friend" address.
    DexNS_Storage dexns = DexNS_Storage(0x429611c633806a03447391026a538a022e1e2731);
    dexns.addressOf("My Friend").transfer(100);
```

DexNS contracts are deployed on **Ethereum CLassic mainnet**. You should connect to ETC network to work with DexNS contracts even if you want to access a data of the contract that is deployed on any of the alternative chains.

# Description

Service provides an opportunity to register a key-phrase 'Name' and associate one address (wallet or contract) and one string variable (metadata) with each key-phrase. External contracts can access Naming Service variables as follows:

Addresses or data can be accessed from the external contract. 
Naming Service content can't be blocked, removed or censored in any other way. Everyone is allowed to do whatever he/she wants with it.

# How do I register my ERC20/ERC223 token on DexNS?

Coming soon ...

### Metadata specification

As DexNS is planned to be used as crosschain smart-contract naming service, I advise to use the first flag for chain identifier. User interface that will work with DexNS **MUST** warn user if he is trying to send a transaction by the DexNS name that doesn't match the currently selected network.

Use the following chain identifier flags:

`-ETC` for Ethereum CLassic chain.

`-ETH` for Ethereum chain.

`-UBQ` for Ubiq chain.

`-EXP` for Expanse chain.

`-ROP` for Ropsten.

`-RIN` for Rinkeby.

`-KOV` for Kovan.

Use the following key flags before data chunks:

`-A ` for ABI.

`-L ` for attached link.

`-S ` for source code reference.

`-i`  for informational data chunk.

Example of metadata for DexNS contract:
`-ETC -L https://author.me/ -S https://github.com/source -A [{"constant":false,"inputs":[],"name":"foo","outputs":[],"payable":false,"type":"function"}]`

# Details 

- `Name` is a key-phrase that will be associated with name data. Each `Name` contains:
    - `owner`       the owner of Name.
    - `addr`        associated address.
    - `metadata`    stringified associated data.
    - `hideOwner`   If set to `true` then the contract will `throw` any attempt to access `ownerOf(Name)`.
    - `signature`   sha256 hash of this Name key-phrase.
    

You can register Name and became its owner. You will own the name before the expiry of the `nameOwning` time. If no one will claim your Name after `expiration[Name]`, then you will continue to be the Name owner. If the Name will be re-registered after the expiration, then you will lose control over this Name. You can extend the term of ownership of the Name before it expires.

### Functions

### `DexNS_Frontend.sol` contract

##### registerName

```js
function registerName(string _name) payable returns (bool ok)
```
Register a new name at Naming Service. `msg.sender` will become `owner` and `address` of this name. `metadata` will be set to "-ETC" by default.

##### registerAndUpdateName

```js
function registerAndUpdateName(string _name, address _owner, address _destination, string _metadata, bool _hideOwner) payable returns (bool ok)
```
Register a new `_name` at Naming Service. `_owner` will become `owner` and `_destination` will become the `address` of this name. `metadata` of this Name will be set to `_metadata`. `hideOwner` status will be set to `_hideOwner`.

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

##### endtimeOf
```js
function endtimeOf(string _name) constant returns (uint _expires)
```
Returns timestamp when the name will become free to re-register. Returns 0 for not registered names.

NOTE: `endtime` is stored at the logical contract. Not in storage. Logic of registering and freeing names is part of logical contract. Storage only accepts calls from it.

##### updateName
```js
function updateName(string _name, address _addr, string _value) { }
function updateName(string _name, address _addr) { }
function updateName(string _name, string _value) { }
```

Changes the contents of `_name` and sets the provided parameters.

##### appendNameMetadata
```js
 function appendNameMetadata(string _name, string _value)
```
Adds the provided `_value` to the end of the already-existing metadata string of the `_name`.

##### changeNameOwner
```js
function changeNameOwner(string _name, address _newOwner)
```
Changes `_name` owner to `_newOwner`.

##### hideNameOwner
```js
function hideNameOwner(string _name, bool _hide)
```
If `_hide` is true then `ownerOf(_name)` will `throw` whenever called. 

Rationale: add possibility to abort execution of transaction/call when someone is trying to interact with name `owner` from external contract. Address that is associated with each `_name` is `addressOf(_name)`, not `ownerOf(_name)` !

##### assignName
```js
function assignName(string _name)
```

Assigns `_name` to `msg.sender` if sender is an owner of the name.

##### unassignName
```js
function unassignName(string _name)
```

Clears `_name` ussignation if `msg.sender` is an owner of the name.

##### extendNameBindingTime
```js
function extendNameBindingTime(string _name) payable
```

Extends binding time of the `_name` by constant specified period if sender provided more funds that required to register/update name. (default 0, free names)

#### Debugging functions (for owner only)

##### change_Storage_Address
```js
function change_Storage_Address(address _newStorage)
```

Changes address of the storage to `_newStorage`.

##### change_Owner
```js
function change_Owner(address _newOwner)
```

Changes owner of the contract to `_newOwner`.

##### disable_Debug
```js
function disable_Debug()
```

Disables possibility to debug the contract.

##### set_Owning_Time
```js
function set_Owning_Time(uint _newOwningTime)
```

Sets the specified time period for the name binding.

##### change_Name_Price
```js
function change_Name_Price(uint _newNamePrice)
```

Sets the specified price for the name registering


## Events

##### Error

```js
event Error(bytes32)
```
Triggered when error occurs.

##### NamePriceChanged

```js
event NamePriceChanged(uint indexed _price)
```
Triggered when price of name is changed by the owner.

##### OwningTimeChanged

```js
event OwningTimeChanged(uint indexed _period)
```
Triggered when binding preiod of time is changed by the owner.

##### DebugDisabled

```js
event DebugDisabled()
```
Triggered when debug is disabled.


### `DexNS_Storage.sol` contract

##### functions that would be called from DexNS frontend contract to modify state

```js
function registerName(string _name) payable returns (bool ok) { }
function registerAndUpdateName(string, address, address, string, bool) returns (bool ok) { }
function updateName(string _name, address _addr, string _value) { }
function updateName(string _name, address _addr) { }
function updateName(string _name, string _value) { }
function appendNameMetadata(string _name, string _value) { }
function changeNameOwner(string _name, address _newOwner) { }
function hideNameOwner(string _name, bool _hide) { }
function assignName(string _name) { }
function unassignName(string _name) { }
```

#### functions to return contract data state

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

##### metadataOf
```js
function metadataOf(string _name) constant returns (string memory _value) 
```
Returns `owner` of the name.

##### assignation
```js
 function assignation(address _assignee) constant returns (string _name)
```
Returns `_name` that is currently assigned to `_assignee`.

##### name_assignation
```js
function name_assignation(string _name) constant returns (address _assignee)
```
Returns `_assignee` address that is currently assigned to `_name`.



##### Debugging functions (for owner only)

##### change_FrontEnd
```js
function change_FrontEnd(address _newFrontEnd)
```

Changes address of the storage to `_newFrontEnd`.

##### change_Owner
```js
function change_Owner(address _newOwner)
```

Changes owner of the contract to `_newOwner`.


### Events

##### Error

```js
event Error(bytes32)
```
Triggered when error occurs.

## Notes

`MyContract` / `      something        strange` / `%20%20%11` are valid names for DexNS. It has no checks for inputs. All names that you can imagine are valid.

It can be a good idea to use versions for testing contracts: `MyTest v1.0.0` / `MyTest v9.256.122` etc.

# Deploying DexNS contracts.

1. Compile and deploy the [DexNS storage](https://github.com/EthereumCommonwealth/DexNS/blob/master/DexNS_Storage.sol) contract.

2. Update the DexNS Frontend contract to init a db on a valid address (or change it after the contract is deployed): https://github.com/EthereumCommonwealth/DexNS/blob/master/DexNS_Frontend.sol#L112

3. Call the [change_Frontend_Address](https://github.com/EthereumCommonwealth/DexNS/blob/master/DexNS_Storage.sol#L399) function of the Storage contract to upload the address of the Frontend contract.
