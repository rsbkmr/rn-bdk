#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(RnBdk, NSObject)

RCT_EXTERN_METHOD(multiply:(float)a b:(float)b
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

@end
