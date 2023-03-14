# Crowd Funding Smart Contract Project

This project demonstrates a minimalistic crowd funding smart contract using hardhat. It comes with it's own ERC20 token, and a script that deploys that contract.

note: test and contract interaction scripts needs to be implemented. Until then use remix to interact with the contract.

Spin up local host in separate terminal.

```
npx hardhat node
```

In separate terminal deploy crowd funding token contract.
```
npx hardhat run scripts/erc20Deploy.js
```

Paste the token address in crowd funding contract deploy script and run it.
```
npx hardhat run scripts/crowdFundDeploy.js
```

Once the repo is updated for testnet and mainnet with testing scripts try doing the following:

```shell
npx hardhat help
npx hardhat test
npx hardhat test --network <network name> //for staging test
REPORT_GAS=true npx hardhat test
npx hardhat run --network <network name> scripts/<fileName>.js
```
