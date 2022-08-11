package com.rnbdk

import com.facebook.react.bridge.*
import org.bitcoindevkit.*

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

class RnBdkModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return "RnBdk"
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  @ReactMethod
  fun multiply(a: Int, b: Int, promise: Promise) {
    promise.resolve(a * b)
  }

  @ReactMethod
  fun _generateExtendedKey(network: String, wordCount: Int, password: String, promise: Promise) {
    try {
      val keysInfo: ExtendedKeyInfo = generateExtendedKey(parseNetwork(network), parseWordCount(wordCount), password)
      val response = mutableMapOf<String, Any?>()
      response["fingerprint"] = keysInfo.fingerprint
      response["mnemonic"] = keysInfo.mnemonic
      response["xprv"] = keysInfo.xprv
      promise.resolve(Arguments.makeNativeMap(response))
    } catch (error: Throwable) {
      return promise.reject("Generate Mnemonic Error", error.localizedMessage, error)
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
      return promise.reject("Generate Mnemonic Error", error.localizedMessage, error)
    }
  }
}
