**[Symbiotic Protocol](https://symbiotic.fi) is an extremely flexible and permissionless shared security system.**

This repository contains a default Network contract and tooling to manage it. Basically, Network contract is an (OZ's TimelockController)[https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/governance/TimelockController.sol] with additional functionality to define delays for either (exact target | exact selector) or (any target | exact selector) pairs.

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/symbioticfi/network)

## Usage

### Dependencies

- Git ([installation](https://git-scm.com/downloads))
- foundry ([installation](https://getfoundry.sh/introduction/installation/))
- npm ([installation](https://nodejs.org/en/download/))

### Prerequisites

**Clone the repository**

```bash
git clone --recurse-submodules https://github.com/symbioticfi/symbiotic-super-sum.git
```

**Install dependencies**

```bash
npm install
```

### Deploy Your Network

- If you need pure Network deployment

  Open [DeployNetwork.s.sol](./script/DeployNetwork.s.sol), you will see config like this:

  ```solidity
  // Name of the Network
  string NAME = "My Network";
  // Default minimum delay (will be applied for any action that doesn't have a specific delay yet)
  uint256 DEFAULT_MIN_DELAY = 3 days;
  // Cold actions delay (a delay that will be applied for major actions like upgradeProxy and setMiddleware)
  uint256 COLD_ACTIONS_DELAY = 14 days;
  // Hot actions delay (a delay that will be applied for minor actions like setMaxNetworkLimit and setResolver)
  uint256 HOT_ACTIONS_DELAY = 0;
  // Admin address (will become executor, proposer, and default admin by default)
  address ADMIN = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

  // Optional

  // Metadata URI of the Network
  string METADATA_URI = "";
  // Salt for deterministic deployment
  bytes11 SALT = "SymNetwork";
  ```

  Edit needed fields, and execute the script via:

  ```bash
  forge script script/DeployNetwork.s.sol --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast
  ```

- If you need Network deployment for already deployed Vault

  Open [DeployNetworkForVault.s.sol](./script/DeployNetworkForVault.s.sol), you will see config like this:

  ```solidity
  // Name of the Network
  string NAME = "My Network";
  // Default minimum delay (will be applied for any action that doesn't have a specific delay yet)
  uint256 DEFAULT_MIN_DELAY = 3 days;
  // Cold actions delay (a delay that will be applied for major actions like upgradeProxy and setMiddleware)
  uint256 COLD_ACTIONS_DELAY = 14 days;
  // Hot actions delay (a delay that will be applied for minor actions like setMaxNetworkLimit and setResolver)
  uint256 HOT_ACTIONS_DELAY = 0;
  // Admin address (will become executor, proposer, and default admin by default)
  address ADMIN = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
  // Vault address to opt-in to
  address VAULT = 0x49fC19bAE549e0b5F99B5b42d7222Caf09E8d2a1;
  // Maximum amount of delegation that network is ready to receive
  uint256 MAX_NETWORK_LIMIT = 1000;
  // Resolver address (optional, is applied only if VetoSlasher is used)
  address RESOLVER = 0xbf616b04c463b818e3336FF3767e61AB44103243;

  // Optional

  // Subnetwork Identifier (multiple subnetworks can be used, e.g., to have different resolvers for the same network)
  uint96 SUBNETWORK_ID = 0;
  // Metadata URI of the Network
  string METADATA_URI = "";
  // Salt for deterministic deployment
  bytes11 SALT = "Test1";
  ```

  Edit needed fields, and execute the script via:

  ```bash
  forge script script/DeployNetworkForVault.s.sol:DeployNetworkForVault --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast
  ```

In console, you will see logs like these:

```bash
Deployed network
  network:0x90F545649eDA7a2083bA30ECC5C21335d030ae1d
  proxyAdminContract:0x79d771aeC770C936E05E51fA8e68f019a373f9b1
  newImplementation:0x3C00C0ef1B1be4dFFeF07dB148bb5fbF31277091
  salt:0x5465737433000000000000000000000000000000000000000000000000000000
Opted network into vault
  network:0x90F545649eDA7a2083bA30ECC5C21335d030ae1d
  vault:0x49fC19bAE549e0b5F99B5b42d7222Caf09E8d2a1
  subnetworkId:0
  maxNetworkLimit:1000
  resolver:0xbf616b04c463b818e3336FF3767e61AB44103243
```

### Manage you network

There are 5 predefined [action-scripts](./script/actions/), that you can use from the start:

- [SetMaxNetworkLimit](./script/actions/SetMaxNetworkLimit.s.sol) - set new maximum network limit for the vault
- [SetResolver](./script/actions/SetResolver.s.sol) - set a new resolver for the vault (only if the vault uses [VetoSlasher](https://docs.symbiotic.fi/modules/vault/slashing#1-vetoslasher))
- [SetMiddleware](./script/actions/SetMiddleware.s.sol) - set a new middleware
- [UpgradeProxy](./script/actions/UpgradeProxy.s.sol) - upgrade the proxy (network itself)
- [ArbitraryCall](./script/actions/ArbitraryCall.s.sol) - make a call to any contract with any data

Interaction with different actions is similar, let's consider [SetMaxNetworkLimit](./script/actions/SetMaxNetworkLimit.s.sol) as an example:

- ```bash
  forge script script/actions/SetMaxNetworkLimit.s.sol:SetMaxNetworkLimit --rpc-url
  ```

### Dashboard

## Security

Security audits can be found [here](./audits).
