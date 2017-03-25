# DNS
Dexaran Naming Service

This is very early version. Many updates are coming.
ETC mainnet version: 0x0e2cec66618f7ca428b1fe01d0de779dbb0f7358


## How to try it

You can access this contract by following this small guide:
1. Navigate to https://www.myetherwallet.com/#contracts
2. Insert contract address: [0x0e2cec66618f7ca428b1fe01d0de779dbb0f7358](https://gastracker.io/addr/0x0e2cec66618f7ca428b1fe01d0de779dbb0f7358)
3. Open [`simple_ABI.json`](https://github.com/Dexaran/DNS/blob/master/HOWTO/simple_ABI.json) and copy everything from it to `ABI / JsonInterface` on MyEtherWallet.
4. Click `Access`. Functions list will appear under `Read / Write contract` label. `simple_ABI` will only show you functions that are executable for a regular user. If you want to watch debugging functions or inner contract variables you can use `full_ABI` instead.

5. Select a function you want to watch. The main two are `registerName` and `getName`. You can choose `getName` and an empty function output template will appear. You can input any text intor `_name` field and click `READ` button. It will execute function and show its output. If the name you entered is already registered the `getName` function will show you [ditails like this](https://github.com/Dexaran/DNS/blob/master/HOWTO/HOWTO5.png). Otherwise it will return 0x0 addresses and empty string. The `READ` executions are free.
6. If you want to register `_name` you need to choose `registerName` function and input a text you want to be owned by your address. Then choose a decription method and decrypt your wallet. After wallet is decrypted `WRITE` button will appear. `WRITE` is not free. If you want to register name you should click `WRITE` and transaction generation window will appear. You need to set Gas Limit to 200 000. MyEtherWallet is inputing a wrong value so if you will not update it manually transaction will fail. Then click `Generate transaction` and `Yes, im sure!` to send transaction. Wait for transaction to submit and enjoy result.
