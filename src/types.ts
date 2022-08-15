export type Network = 'testnet' | 'bitcoin' | 'regtest' | 'signet';
export type WordCount = 12 | 15 | 18 | 21 | 24;
export type DatabaseConfig = 'memory' | 'sqlite' | 'sled';
export type DescriptorType = 'pkh' | 'sh' | 'wpkh' | 'wsh';
export type AddressIndex = 'new' | 'last-unused';
export type BlockchainType = 'electrum' | 'esplora';
export interface Transaction {
  received: string;
  sent: string;
  fee: string;
  txid: string;
  confirmed: boolean;
  confirmation_height?: string;
  confirmation_timestamp?: string;
}
