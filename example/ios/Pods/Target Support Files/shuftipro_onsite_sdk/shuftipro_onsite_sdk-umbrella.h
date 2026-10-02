#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ShuftiproSdk.h"
#import "ShuftiproSdkPlugin.h"

FOUNDATION_EXPORT double shuftipro_onsite_sdkVersionNumber;
FOUNDATION_EXPORT const unsigned char shuftipro_onsite_sdkVersionString[];

