import { NativeModules, Platform } from 'react-native';
import type { Network, WordCount } from './types';

const LINKING_ERROR =
  `The package 'rn-bdk' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo managed workflow\n';

const RnBdk = NativeModules.RnBdk
  ? NativeModules.RnBdk
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export async function generateExtendedKey(args: {
  network?: Network;
  wordCount?: WordCount;
  password?: string;
}): Promise<{
  mnemonic: string;
  fingerprint: string;
  xprv: string;
}> {
  const { network = 'bitcoin', wordCount = 12, password = '' } = args;
  const key = await RnBdk._generateExtendedKey(network, wordCount, password);
  return key;
}

export async function restoreExtendedKey(args: {
  network?: Network;
  mnemonic: string;
  password?: string;
}): Promise<{
  mnemonic: string;
  fingerprint: string;
  xprv: string;
}> {
  const { network = 'bitcoin', mnemonic, password = '' } = args;
  const key = await RnBdk._restoreExtendedKey(network, mnemonic, password);
  return key;
}
