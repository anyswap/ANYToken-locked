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


## contract explained

This smart contract is used to lock a sum ERC20 token to this contract
(someone should transfer tokens to this contract as preparation),
and let this contract to control how to gradually unlock/release these tokens to `beneficiary`.

This contract will release some tokens (actually `releasedPerBlock * blocksPerCycle * cycles`)
when `release` method is called (every one can call this function to release tokens if have releasable amount).
in which `cycles = (current block height - latestReleasedHeight) / blocksPerCycle`,
and the first cycle is fromm `startBlock` to `startBlock + blocksPerCycle.`

We can call `releasableAmount` to query how many tokens it can release at latest block height.

```javascript
// init in constructor, specify which ERC20 token to control by this contract
IERC20 public token;

// adjustable by the owner by set... method
address public beneficiary; // where the released token was received
uint256 public startBlock;  // from which block to calc cycles
uint256 public stableHeight = 30; // stable number of blocks to ensure security (default: 30)
uint256 public blocksPerCycle = 6600; // how many number of blocks each cycle has (default: 6600)
uint256 public releasedPerBlock; // how many tokens release per one block

// maintained by contract internally
uint256 public totalReleased; // total tokens released, accumulate each released amount together
uint256 public latestReleasedHeight; // latest have released block height, update after release succeed
address public owner; // creator of this contract, only owner can modify some variables in this contract

function setBeneficiary(address addr) onlyOwner public; // set beneficiary value (must not zero address)
function setStartBlock(uint256 start) onlyOwner public; // set startBlock value (must > latestReleasedHeight)
function setStableHeight(uint256 stable) onlyOwner public; // set stableHeight value (must < blocksPerCycle)
function setBlocksPerCycle(uint256 count) onlyOwner public; // set blocksPerCycle value (must > stableHeight)
function setReleasedPerBlock(uint256 amount) onlyOwner public; // set releasedPerBlock value
function revoke() onlyOwner public; // revoke all token balances to the owner of this contract
function releasableAmount() public view returns (uint256 amount, uint256 height); // query how many tokens can be released and to which block height
function release() public; // execute release function, will fail if have no releasable amount
```

So if we want to make the contract run, we should call the following methods to set or adjust internal variables:
```text
setBeneficiary
setStartBlock
setStableHeight
setBlocksPerCycle
setReleasedPerBlock
```

For testing, you can set a smaller `stableHeight` and `blocksPerCycle` value to check `release` function more quickly.
