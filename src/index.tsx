import type {
  AddressIndex,
  BlockchainType,
  DatabaseConfig,
  DescriptorType,
  Network,
  Transaction,
  WordCount,
} from './types';
import { NativeModules, Platform } from 'react-native';

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

class BitcoinDevKit {
  generateExtendedKey(args: {
    network?: Network;
    wordCount?: WordCount;
    password?: string;
  }): Promise<{
    mnemonic: string;
    fingerprint: string;
    xprv: string;
  }> {
    try {
      const { network = 'bitcoin', wordCount = 12, password = '' } = args;
      const key = await RnBdk._generateExtendedKey(
        network,
        wordCount,
        password
      );
      return key;
    } catch (error: any) {
      throw new Error(
        error.code ? `Code: ${error.code} Message: ${error.message}` : error
      );
    }
  }

  async restoreExtendedKey(args: {
    network?: Network;
    mnemonic: string;
    password?: string;
  }): Promise<{
    mnemonic: string;
    fingerprint: string;
    xprv: string;
  }> {
    try {
      const { network = 'bitcoin', mnemonic, password = '' } = args;
      const key = await RnBdk._restoreExtendedKey(network, mnemonic, password);
      return key;
    } catch (error: any) {
      throw new Error(
        error.code ? `Code: ${error.code} Message: ${error.message}` : error
      );
    }
  }

  createDescriptor(args: {
    xprv: string;
    change?: boolean;
    type?: DescriptorType;
  }): string {
    try {
      const { xprv, change = false, type = 'wpkh' } = args;
      return `${type}(${xprv}/84'/1'/0'/${change ? 1 : 0}/*)`; // segwit
    } catch (error: any) {
      throw new Error(
        error.code ? `Code: ${error.code} Message: ${error.message}` : error
      );
    }
  }

  async createWallet(args: {
    descriptor: string;
    changeDescriptor: string;
    network?: Network;
    databaseConfig?: DatabaseConfig;
  }): Promise<void> {
    try {
      const {
        descriptor,
        changeDescriptor,
        network = 'bitcoin',
        databaseConfig = 'memory',
      } = args;
      await RnBdk._createWallet(
        descriptor,
        changeDescriptor,
        network,
        databaseConfig
      );
    } catch (error: any) {
      throw new Error(
        error.code ? `Code: ${error.code} Message: ${error.message}` : error
      );
    }
  }

  async getAddress(
    addressIndex: AddressIndex = 'last-unused'
  ): Promise<{ address: string; index: number }> {
    try {
      return await RnBdk._getAddress(addressIndex);
    } catch (error: any) {
      throw new Error(
        error.code ? `Code: ${error.code} Message: ${error.message}` : error
      );
    }
  }

  async getBalance(): Promise<string> {
    try {
      return await RnBdk._getBalance();
    } catch (error: any) {
      throw new Error(
        error.code ? `Code: ${error.code} Message: ${error.message}` : error
      );
    }
  }

  async getTransactions(): Promise<Transaction> {
    try {
      return await RnBdk._getTransactions();
    } catch (error: any) {
      throw new Error(
        error.code ? `Code: ${error.code} Message: ${error.message}` : error
      );
    }
  }

  async sync(): Promise<void> {
    try {
      await RnBdk._sync();
    } catch (error: any) {
      throw new Error(
        error.code ? `Code: ${error.code} Message: ${error.message}` : error
      );
    }
  }

  async setBlockchain(args: {
    type?: BlockchainType;
    url?: string;
  }): Promise<void> {
    try {
      const {
        type = 'electrum',
        url = 'ssl://electrum.blockstream.info:60002', // testnet
      } = args;
      await RnBdk._setBlockchain(type, url);
    } catch (error: any) {
      throw new Error(
        error.code ? `Code: ${error.code} Message: ${error.message}` : error
      );
    }
  }

  async send(to: string, amount: number): Promise<any> {
    try {
      return await RnBdk._send(to, amount);
    } catch (error: any) {
      throw new Error(
        error.code ? `Code: ${error.code} Message: ${error.message}` : error
      );
    }
  }
}

const bdk = new BitcoinDevKit();

export default bdk;
