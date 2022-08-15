import Foundation

func parseNetwork(_ network: String) -> Network {
  switch network {
  case "testnet": return Network.testnet
  case "bitcoin": return Network.bitcoin
  case "regtest": return Network.regtest
  case "signet": return Network.signet
  default: return Network.testnet
  }
}

func parseWordCount(_ wordCount: NSNumber) -> WordCount {
  switch wordCount {
  case 12: return WordCount.words12
  case 15: return WordCount.words15
  case 18: return WordCount.words18
  case 21: return WordCount.words21
  case 24: return WordCount.words24
  default: return WordCount.words12
  }
}

func parseDatabaseConfig(_ config: String) -> DatabaseConfig {
  switch config {
  case "memory": return DatabaseConfig.memory
    //  case "memory": return DatabaseConfig.sled()
    //  case "sqlite": return DatabaseConfig.sqlite()
  default: return DatabaseConfig.memory
  }
}

func parseAddressIndex(_ index: String) -> AddressIndex {
  switch index {
  case "last-unused": return AddressIndex.lastUnused
  case "new": return AddressIndex.new
  default: return AddressIndex.lastUnused
  }
}

class BdkProgress: Progress {
  func update(progress: Float, message: String?) {
    print("progress", progress, message as Any)
  }
}

@objc(RnBdk)
class RnBdk: NSObject {
  var wallet: Wallet?
  var blockchain: Blockchain
  var blockchainConfig = BlockchainConfig.electrum(
    config: ElectrumConfig(
      url: "ssl://electrum.blockstream.info:60002",
      socks5: nil,
      retry: 5,
      timeout: nil,
      stopGap: 10
    )
  )
  
  override init() {
    blockchain = try! Blockchain(config: blockchainConfig)
  }
  
  @objc
  func _generateExtendedKey(
    _ network: String,
    wordCount: NSNumber,
    password: String,
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      let key = try generateExtendedKey(network: parseNetwork(network), wordCount: parseWordCount(wordCount), password: password)
      
      let response = [
        "fingerprint": key.fingerprint,
        "mnemonic": key.mnemonic,
        "xprv": key.xprv,
      ] as [String: Any]
      resolve(response)
    } catch {
      reject("Generate Extended Key Error", error.localizedDescription, error)
    }
  }
  
  @objc
  func _restoreExtendedKey(
    _ network: String,
    mnemonic: String,
    password: String,
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      let key = try restoreExtendedKey(network: parseNetwork(network), mnemonic: mnemonic, password: password)
      
      let response = [
        "fingerprint": key.fingerprint,
        "mnemonic": key.mnemonic,
        "xprv": key.xprv,
      ] as [String: Any]
      resolve(response)
    } catch {
      reject("Restore Extended Key Error", error.localizedDescription, error)
    }
  }
  
  @objc
  func _createWallet(
    _ descriptor: String,
    changeDescriptor: String,
    network: String,
    databaseConfig: String,
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      self.wallet = try Wallet.init(descriptor: descriptor, changeDescriptor: changeDescriptor, network: parseNetwork(network), databaseConfig: parseDatabaseConfig(databaseConfig))
    } catch {
      reject("Create Wallet Error", error.localizedDescription, error)
    }
  }
  
  @objc
  func _getAddress(
    _ addressIndex: String,
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      let addressObj = try self.wallet?.getAddress(addressIndex: parseAddressIndex(addressIndex))
      let response = [
        "address": addressObj?.address,
        "index": addressObj?.index
      ] as [String: Any?]
      resolve(response)
    } catch {
      reject("Get Address Error", error.localizedDescription, error)
    }
  }
  
  @objc
  func _setBlockchain(
    _ type: String,
    url: String,
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      let blockchainConfig: BlockchainConfig
      
      switch type {
      case "electrum": blockchainConfig = BlockchainConfig.electrum(
        config: ElectrumConfig(
          url: url,
          socks5: nil,
          retry: 5,
          timeout: nil,
          stopGap: 10
        )
      )
      default: blockchainConfig = BlockchainConfig.electrum(
        config: ElectrumConfig(
          url: "ssl://electrum.blockstream.info:60002",
          socks5: nil,
          retry: 5,
          timeout: nil,
          stopGap: 10
        )
      )
      }
      
      self.blockchain = try Blockchain.init(config: blockchainConfig)
      try self.wallet?.sync(blockchain: self.blockchain, progress: BdkProgress())
    } catch {
      reject("Set Blockchain Error", error.localizedDescription, error)
    }
  }
  
  @objc
  func _sync(
    _ resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      try self.wallet?.sync(blockchain: self.blockchain, progress: BdkProgress())
    } catch {
      reject("Sync Error", error.localizedDescription, error)
    }
  }
  
  @objc
  func _getBalance(
    _ resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      let balance = try self.wallet?.getBalance()
      resolve(String(balance ?? 0))
    } catch {
      reject("Get Balance Error", error.localizedDescription, error)
    }
  }
  
  @objc
  func _getTransactions(
    _ resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      let transactions = try wallet?.getTransactions()
      
      var txs: [Any] = []
      for tx in transactions ?? [] {
        // Unconfirmed transactions
        if case let .unconfirmed(details) = tx {
          let response = [
            "received": details.received,
            "sent": details.sent,
            "fee": details.fee!,
            "txid": details.txid,
            "confirmed": false,
          ] as [String: Any]
          txs.append(response)
        }
        // Confirmed transactions
        if case let .confirmed(details, confirmation) = tx {
          let response = [
            "received": details.received,
            "sent": details.sent,
            "fee": details.fee!,
            "txid": details.txid,
            "confirmed": true,
            "confirmation_height": confirmation.height,
            "confirmation_timestamp": confirmation.timestamp,
          ] as [String: Any]
          txs.append(response)
        }
      }
      
      resolve(txs)
    } catch {
      reject("Get Transactions Error", error.localizedDescription, error)
    }
  }
  
  @objc
  func _send(
    _ to: String,
    amount: NSNumber,
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    do {
      let txBuilder = TxBuilder().addRecipient(address: to, amount: UInt64(truncating: amount))
      let psbt = try txBuilder.finish(wallet: self.wallet!)
      try self.wallet?.sign(psbt: psbt)
      try self.blockchain.broadcast(psbt: psbt)
      resolve(psbt.txid())
    } catch {
      reject("Send Transaction Error", error.localizedDescription, error)
    }
  }
}
