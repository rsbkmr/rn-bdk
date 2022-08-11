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

@objc(RnBdk)
class RnBdk: NSObject {
  
  @objc
  func _generateExtendedKey(_ network: String, wordCount: NSNumber, password: String, resolve:@escaping RCTPromiseResolveBlock,reject:@escaping RCTPromiseRejectBlock) -> Void {
    do {
      let key = try generateExtendedKey(network: parseNetwork(network), wordCount: parseWordCount(wordCount), password: password)
      
      let response = [
        "fingerprint": key.fingerprint,
        "mnemonic": key.mnemonic,
        "xprv": key.xprv
      ] as [String: Any]
      resolve(response)
    } catch {
      reject("generate extended keys error", error.localizedDescription, error)
    }
  }
  
  @objc
  func _restoreExtendedKey(_ network: String, mnemonic: String, password: String, resolve:@escaping RCTPromiseResolveBlock,reject:@escaping RCTPromiseRejectBlock) -> Void {
    do {
      let key = try restoreExtendedKey(network: parseNetwork(network), mnemonic: mnemonic, password: password)
      
      let response = [
        "fingerprint": key.fingerprint,
        "mnemonic": key.mnemonic,
        "xprv": key.xprv
      ] as [String: Any]
      resolve(response)
    } catch {
      reject("restore extended keys error", error.localizedDescription, error)
    }
  }
}
