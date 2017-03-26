# Dexaran Naming Service
Naming Service is a part of [Dexaran Treasury System](https://github.com/Dexaran/Treasury).

This is very early version. Many updates are coming.
ETC mainnet version: [0x0e2cec66618f7ca428b1fe01d0de779dbb0f7358](https://gastracker.io/addr/0x0e2cec66618f7ca428b1fe01d0de779dbb0f7358)


## How to try it

You can access this contract by following this small guide:
1. Navigate to https://www.myetherwallet.com/#contracts
2. Insert contract address: [0x0e2cec66618f7ca428b1fe01d0de779dbb0f7358](https://gastracker.io/addr/0x0e2cec66618f7ca428b1fe01d0de779dbb0f7358)
3. Open [`simple_ABI.json`](https://github.com/Dexaran/DNS/blob/master/HOWTO/simple_ABI.json) and copy everything from it to `ABI / JsonInterface` on MyEtherWallet.
4. Click `Access`. Functions list will appear under `Read / Write contract` label. `simple_ABI` will only show you functions that are executable for a regular user. If you want to watch debugging functions or inner contract variables you can use `full_ABI` instead.

5. Select a function you want to watch. The main two are `registerName` and `getName`. You can choose `getName` and an empty function output template will appear. You can input any text intor `_name` field and click `READ` button. It will execute function and show its output. If the name you entered is already registered the `getName` function will show you [ditails like this](https://github.com/Dexaran/DNS/blob/master/HOWTO/HOWTO5.png). Otherwise it will return 0x0 addresses and empty string. The `READ` executions are free.
6. If you want to register `_name` you need to choose `registerName` function and input a text you want to be owned by your address. Then choose a decription method and decrypt your wallet. After wallet is decrypted `WRITE` button will appear. `WRITE` is not free. If you want to register name you should click `WRITE` and transaction generation window will appear. You need to set Gas Limit to 200 000. MyEtherWallet is inputing a wrong value so if you will not update it manually transaction will fail. Then click `Generate transaction` and `Yes, im sure!` to send transaction. Wait for transaction to submit and enjoy result.


## Description

Service provides an opportunity to register a key-phrase 'Name' and to associate one address (wallet or contract) and one string variable with each key-phrase. External contracts can access Naming Service variables:

`NamingService ns= new NamingService();`

`ns.addressOf("Bit Ether Coin").call(_gas)(_data);`

`//this will initiate a call of address associated with "Bit Ether Coin" string.`

I don't insist on how to use contract functions. You can utilize string variable in any way you want. Offchain resources like emails, links or whatever else is needed.
For example "Dexaran" word is associated with "https://github.com/Dexaran/" link. Also key-phrase "TheDAO hacker" is associated with his address and he is the owner of this Name.

Addresses or stringified data can be accessed from the external contract. 
Naming Service content can't be blocked, removed or censored in any other way. Everyone is allowed to do whatever he/she wants with it, for example connect Names with addresses or store data in the immutable storage.

# Details 
- `Name` is a key-phrase that will be associated with name data. Each `Name` contains:
    - `owner` the owner of Name.
    - `addr` associated address.
    - `value` stringified associated data.
    - `endblock` the number of block on which ownership of this Name expires.
    - `signature` sha256 hash of this Name key-phrase.
    

You can register Name and became its owner. You will own it until specified block with `endblock` number. If no one will claim your Name after `endblock` you will continue to be its owner but if Name will be re-registered it will be updated with a new owner and new Name data. 


- `registerName` function allows you to register a new key-phrase Name and become its owner.
- `updateName` function allows you to update Name content if you are Name owner.
- `changeNameOwner` function allows owner to transfer ownership to another address.
- `hideNameOwner` function allows to hide Name owner. If Name owner is hidden `getName(Name)` will return owner as 0x0 and `ownerOf(Name)` will throw an error.
- `extendNameBindingTime` function allows you to pay Name again and extend owning period by next `owningTime` blocks.
- `ownerOf` function allows to check who is Name owner. (for example it may be needed to check ownership in contract trading Names)
- `addressOf` will return address associated with Name.
- `valueOf` will return stringified data associated with Name.
- `endblockOf` will return the block number on which ownership on given Name expires.

- `owningTime ` is a number of blocks you will own registered Name. (=1 500 000 now)
- `namePrice ` is amount of Ether that you need to pay to buy Name. (=0 now)
- `debug ` returns is a contract in debugging mode or not.
