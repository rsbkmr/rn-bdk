package com.rnbdk

import android.util.Log
import com.facebook.react.bridge.*
import org.bitcoindevkit.*
import java.util.Collections.emptyList

fun parseNetwork(network: String): Network {
  when (network) {
    "bitcoin" -> return Network.BITCOIN
    "regtest" -> return Network.REGTEST
    "signet" -> return Network.SIGNET
    "testnet" -> return Network.TESTNET
    else -> {
      return Network.TESTNET
    }
  }
}

fun parseWordCount(wordCount: Int): WordCount {
  when (wordCount) {
    12 -> return WordCount.WORDS12
    15 -> return WordCount.WORDS15
    18 -> return WordCount.WORDS18
    21 -> return WordCount.WORDS21
    24 -> return WordCount.WORDS24
    else -> {
      return WordCount.WORDS12
    }
  }
}

fun parseDatabaseConfig(config: String): DatabaseConfig {
  when (config) {
    "memory" -> return DatabaseConfig.Memory
//    "sled" -> return DatabaseConfig.Sled
//    "sqlite" -> return DatabaseConfig.Sqlite
    else -> {
      return DatabaseConfig.Memory
    }
  }
}

fun parseAddressIndex(index: String): AddressIndex {
  when (index) {
    "last-unused" -> return AddressIndex.LAST_UNUSED
    "new" -> return AddressIndex.NEW
    else -> {
      return AddressIndex.LAST_UNUSED
    }
  }
}

class RnBdkModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  private lateinit var wallet: Wallet
  private lateinit var blockchain: Blockchain
  val defaultBlockchainConfigUrl = "ssl://electrum.blockstream.info:60002"
  private var defaultBlockchainConfig =
    BlockchainConfig.Electrum(
      ElectrumConfig(this.defaultBlockchainConfigUrl, null, 5u, null, 10u)
    )

  object ProgressLog : Progress {
    override fun update(progress: Float, message: String?) {
      Log.i(progress.toString(), "Progress Log")
    }
  }

  override fun getName(): String {
    return "RnBdk"
  }

  init {
    this.blockchain = Blockchain(this.defaultBlockchainConfig)
  }

  @ReactMethod
  fun _generateExtendedKey(network: String, wordCount: Int, password: String, promise: Promise) {
    try {
      val keysInfo: ExtendedKeyInfo =
        generateExtendedKey(parseNetwork(network), parseWordCount(wordCount), password)
      val response = mutableMapOf<String, Any?>()
      response["fingerprint"] = keysInfo.fingerprint
      response["mnemonic"] = keysInfo.mnemonic
      response["xprv"] = keysInfo.xprv
      promise.resolve(Arguments.makeNativeMap(response))
    } catch (error: Throwable) {
      return promise.reject("Generate Mnemonic Error", error.message, error)
    }
  }

  @ReactMethod
  fun _restoreExtendedKey(network: String, mnemonic: String, password: String, promise: Promise) {
    try {
      val key: ExtendedKeyInfo = restoreExtendedKey(parseNetwork(network), mnemonic, password)
      val response = mutableMapOf<String, Any?>()
      response["fingerprint"] = key.fingerprint
      response["mnemonic"] = key.mnemonic
      response["xprv"] = key.xprv
      promise.resolve(Arguments.makeNativeMap(response))
    } catch (error: Throwable) {
      return promise.reject("Generate Mnemonic Error", error.message, error)
    }
  }

  @ReactMethod
  fun _createWallet(
    descriptor: String,
    changeDescriptor: String,
    network: String,
    databaseConfig: String,
    promise: Promise
  ) {
    try {
      this.wallet = Wallet(
        descriptor,
        changeDescriptor,
        parseNetwork(network),
        parseDatabaseConfig(databaseConfig)
      )
    } catch (error: Throwable) {
      promise.reject("Create Wallet Error", error.message, error.cause)
    }
  }

  @ReactMethod
  fun _getAddress(addressIndex: String, promise: Promise) {
    try {
      val response = mutableMapOf<String, Any?>()
      response["address"] = this.wallet.getAddress(parseAddressIndex(addressIndex)).address
      response["index"] = this.wallet.getAddress(parseAddressIndex(addressIndex)).index.toInt()
      promise.resolve(Arguments.makeNativeMap(response))
    } catch (error: Throwable) {
      promise.reject("Get Address Error", error.message, error.cause)
    }
  }

  @ReactMethod
  fun _setBlockchain(type: String, url: String, promise: Promise) {
    try {
      var blockchainConfig: BlockchainConfig

      when (type) {
        "electrum" -> blockchainConfig = BlockchainConfig.Electrum(
          ElectrumConfig(url, null, 5u, null, 10u)
        )
        // TODO: add esplora
        else -> {
          blockchainConfig = BlockchainConfig.Electrum(
            ElectrumConfig(this.defaultBlockchainConfigUrl, null, 5u, null, 10u)
          )
        }
      }

      this.blockchain = Blockchain(
        blockchainConfig
      )
      this.wallet.sync(this.blockchain, ProgressLog)
    } catch (error: Throwable) {
      promise.reject("Set Blockchain Error", error.message, error.cause)
    }
  }

  @ReactMethod
  fun _sync(promise: Promise) {
    try {
      this.wallet.sync(this.blockchain, ProgressLog)
    } catch (error: Throwable) {
      promise.reject("Sync Error", error.message, error.cause)
    }
  }

  @ReactMethod
  fun _getBalance(promise: Promise) {
    try {
      promise.resolve(this.wallet.getBalance().toString())
    } catch (error: Throwable) {
      promise.reject("Get Balance Error", error.message, error.cause)
    }
  }

  @ReactMethod
  fun _getTransactions(promise: Promise) {
    try {
      val transactions = this.wallet.getTransactions()
      if (transactions.isEmpty()) {
        promise.resolve(Arguments.makeNativeArray(emptyList<Any>()))
      } else {
        val txs: MutableList<Map<String, Any?>> = mutableListOf()

        for (item in transactions) {
          val response = mutableMapOf<String, Any?>()
          when (item) {
            is Transaction.Unconfirmed -> {
              response["received"] = item.details.received.toString()
              response["sent"] = item.details.sent.toString()
              response["fee"] = item.details.fee.toString()
              response["txid"] = item.details.txid
              response["confirmed"] = false
            }
            is Transaction.Confirmed -> {
              response["received"] = item.details.received.toString()
              response["sent"] = item.details.sent.toString()
              response["fee"] = item.details.fee.toString()
              response["txid"] = item.details.txid
              response["confirmed"] = true
              response["confirmation_height"] = item.confirmation.height.toString()
              response["confirmation_timestamp"] = item.confirmation.timestamp.toString()
            }
          }
          txs.add(response)
        }
        promise.resolve(Arguments.makeNativeArray(txs))
      }
    } catch (error: Throwable) {
      promise.reject("Send Transaction Error", error.message, error.cause)
    }
  }

  @ReactMethod
  fun _send(to: String, amount: Double, promise: Promise) {
    try {
      val _amount: Long = amount.toLong()
      val txBuilder = TxBuilder().addRecipient(to, _amount.toULong())
      val psbt = txBuilder.finish(this.wallet)
      this.wallet.sign(psbt)
      this.blockchain.broadcast(psbt)
      promise.resolve(psbt.txid())
    } catch (error: Throwable) {
      promise.reject("Send Transaction Error", error.message, error.cause)
    }
  }
}
