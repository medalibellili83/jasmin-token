# Jasmin Token (JSM)

A minimal ERC-20 token written from scratch in Solidity (no external libraries), with a full Foundry test suite.

Built to understand exactly how tokens like USDT and USDC work under the hood: balances, transfers, allowances, burning and events.

## Features

- Standard ERC-20 interface: `transfer`, `approve`, `transferFrom`, `balanceOf`, `allowance`, `totalSupply`
- `burn`: holders can permanently destroy their own tokens
- Infinite approvals (`type(uint256).max`) are never decreased, following common convention
- 18 decimals, fixed initial supply minted to the deployer

## Tests

11 tests, including a fuzz test that checks the total supply is conserved across random transfer amounts.

```shell
forge test -vv
```

## Deploy

Local blockchain:

```shell
anvil
forge script script/DeployJasminToken.s.sol --rpc-url http://127.0.0.1:8545 --private-key <anvil_test_key> --broadcast
```

Sepolia testnet (using an encrypted Foundry keystore, never a raw private key):

```shell
cast wallet import dev --interactive
forge script script/DeployJasminToken.s.sol --rpc-url sepolia --account dev --broadcast
```

## Stack

Solidity 0.8 · Foundry (forge, cast, anvil)
