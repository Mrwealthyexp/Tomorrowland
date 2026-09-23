# Tomorrowland Builder Badge (BLDR) Deployment

This repository includes `/contracts/BuilderBadge.sol` and website integration in `/index.html` and `/dist/index.html`.

> **Important:** Deployment, wallet funding, MetaMask transaction signing, Polygonscan verification, and nft.storage uploads are manual owner actions. This repository update does **not** perform those external steps.

## 1) Fund deployment wallet (manual)

- Use a wallet you control in MetaMask.
- Fund it with POL on **Polygon Mainnet** (chain ID **137**) for deployment + admin transactions.

## 2) Deploy in Remix (manual)

1. Open https://remix.ethereum.org.
2. Create `BuilderBadge.sol` and paste `/contracts/BuilderBadge.sol`.
3. Compile with Solidity `^0.8.20` (OpenZeppelin v5 is easiest on 0.8.24+).
4. In **Deploy & Run**, choose **Injected Provider - MetaMask**.
5. Confirm network is Polygon Mainnet (chain ID 137).
6. Deploy `BuilderBadge` with constructor argument:
   - `baseTokenURI_` (example: `ipfs://<METADATA_CID>/` or `https://tomorrowland.example/badge/`)

## 3) Verify on Polygonscan (manual)

- Go to `https://polygonscan.com/address/<CONTRACT_ADDRESS>#code` and run **Verify and Publish**.
- Use the same compiler version and optimizer settings as deployment.
- License: MIT.
- Constructor arguments: ABI-encoded `baseTokenURI_` string (auto-detection usually works).
- Remix flattening or verification plugin can help when verifying imports.

## 4) Metadata and artwork via IPFS (manual)

The contract resolves token metadata as:

`tokenURI(tokenId) = baseURI + tokenId`

If `baseURI` is `ipfs://<METADATA_CID>/`, token `1` resolves to `ipfs://<METADATA_CID>/1`.

### Metadata file format

Create metadata files named by token id (`1`, `2`, `3`, ...):

```json
{
  "name": "Tomorrowland Builder Badge #1",
  "description": "Soulbound badge for builders of Tomorrowland.",
  "image": "ipfs://<IMAGE_CID>/badge.png",
  "attributes": [
    { "trait_type": "Role", "value": "Builder" },
    { "trait_type": "Collection", "value": "Tomorrowland" }
  ]
}
```

Upload image + metadata folder to https://nft.storage, then set base URI on-chain using owner account:

- `setBaseURI("ipfs://<METADATA_CID>/")`

## 5) Website configuration (manual)

After deployment, set the address in both:

- `/index.html`
- `/dist/index.html`

Find:

```js
const NFT_CONTRACT_ADDRESS='0x0000000000000000000000000000000000000000';
```

Replace with your deployed contract address.

The site mints using `safeMint(address)` and reads:
- `balanceOf(address)`
- `totalSupply()`
- `tokenOfOwnerByIndex(address,uint256)`

It requires/switches to Polygon Mainnet (137) before minting when an injected wallet is available.

## 6) Ownership and governance migration (manual)

Owner powers include:
- `setBaseURI(string)`
- `airdrop(address[] recipients)`

Recommended progression:
1. Deploy from a secure EOA for initial launch.
2. Transfer ownership to a Safe multisig (`transferOwnership`) once governance hardens.
3. Route treasury/admin operations through multisig policy.
