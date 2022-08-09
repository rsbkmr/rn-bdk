import Foundation

@objc(RnBdk)
class RnBdk: NSObject {
  @objc
  func multiply(_ a: Float, b: Float, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
    resolve(a*b)
  }
}
