#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "LMAddress.h"
#import "LMGeocoder.h"
#import "LMGeocoderUniversal.h"

FOUNDATION_EXPORT double LMGeocoderUniversalVersionNumber;
FOUNDATION_EXPORT const unsigned char LMGeocoderUniversalVersionString[];

