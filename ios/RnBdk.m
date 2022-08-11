#import <React/RCTBridgeModule.h>


@interface RCT_EXTERN_MODULE(RnBdk, NSObject)

RCT_EXTERN_METHOD(_generateExtendedKey:(nonnull NSString *)network
                  wordCount:(nonnull NSNumber *)wordCount
                  password:(nonnull NSString *)password
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(_restoreExtendedKey:(nonnull NSString *)network
                  mnemonic:(nonnull NSString *)mnemonic
                  password:(nonnull NSString *)password
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

@end
