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

RCT_EXTERN_METHOD(_createWallet:(nonnull NSString *)descriptor
                  changeDescriptor:(nonnull NSString *)changeDescriptor
                  network:(nonnull NSString *)network
                  databaseConfig:(nonnull NSString *)databaseConfig
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(_getAddress:(nonnull NSString *)addressIndex
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(_setBlockchain:(nonnull NSString *)type
                  url:(nonnull NSString *)url
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(_sync:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(_getBalance:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(_getTransactions:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(_send:(nonnull NSString *)to
                  amount:(nonnull NSNumber *)amount
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

@end
