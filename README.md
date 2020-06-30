# ANYToken locked
ANYToken locked smart contract

## install @openzeppelin/contracts

```shell
npm install
```

## flatten contract

This has been already done.

Mention here only for re-flatten if modified later.

```shell
npm install -g truffle-flattener
truffle-flattener Distribute.sol | sed '/SPDX-License-Identifier:/d' | sed 1i'// SPDX-License-Identifier: MIT' > contracts/Distribute.sol
```

## compile

```shell
truffle compile
```

## deploy

Firstly, you shoule modify the migration script file `migrations/2_deploy_contracts.js`.
Assign a right token address to `ANYtoken` variable.

Calling of `deployer.deploy` with argument will
apply the token address to the contract constructor.

modify `truffle-config.js` accordingly, especially `host`, `port`, `network_id`.

```shell
truffle migrate
```

