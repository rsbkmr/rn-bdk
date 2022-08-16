# rn-bdk

[![MIT License](https://img.shields.io/apm/l/atomic-design-ui.svg?)](https://github.com/tterb/atomic-design-ui/blob/master/LICENSEs)

Bitcoin Dev Kit for React Native.

## Installation

Install rn-bdk with npm

```bash
  npm install rn-bdk
```

or yarn

```bash
  yarn add rn-bdk
```

## Example

```ts
import bdk from 'rn-bdk';

// generate extended key
const key = await bdk.generateExtendedKey({});

// or

// restore exteneded key
const key = await bdk.restoreExtendedKey({
  mnemonic: '...',
});

// create descriptor
const descriptor = bdk.createDescriptor({{ xprv: key.xprv }})

await bdk.createWallet({
  descriptor: bdk.createDescriptor({ xprv: key.xprv }),
  changeDescriptor: bdk.createDescriptor({
    xprv: key.xprv,
    change: true,
  }),
});

// get last unused address from wallet
const { address } = await bdk.getAddress();

// set your own node url
await bdk.setBlockchain({ url: 'ssl://electrum.blockstream.info:50002' });

// get transactions
const transactions = await bdk.getTransactions();

// send transaction
const txid = await bdk.send(to, amount);
```

## Contributing

Contributions are always welcome!

See `contributing.md` for ways to get started.

Please adhere to this project's `code of conduct`.
