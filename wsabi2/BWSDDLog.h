// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

/// Custom Lumberjack DDLog log levels.

#ifndef wsabi2_BWSDDLog_h
#define wsabi2_BWSDDLog_h

#import "DDLog.h"

// The first 4 bits are being used by the standard levels (0 - 3) 
// All other bits are fair game for us to use.

#define LOG_FLAG_BWS_TOUCH          (1 << 4)
#define LOG_FLAG_BWS_MOTION         (1 << 5)
#define LOG_FLAG_BWS_NETWORK        (1 << 6)
#define LOG_FLAG_BWS_DEVICE         (1 << 7)

#define LOG_BWS_TOUCH               (ddLogLevel & LOG_FLAG_BWS_TOUCH)
#define LOG_BWS_MOTION              (ddLogLevel & LOG_FLAG_BWS_MOTION)
#define LOG_BWS_NETWORK             (ddLogLevel & LOG_FLAG_BWS_NETWORK)
#define LOG_BWS_DEVICE              (ddLogLevel & LOG_FLAG_BWS_DEVICE)

#define REFRESH_DD_BWS_LOG_PREFS    (ddLogLevel = [BWSDDLog readBWSDDLogPreferenceLevel])

/// Log touch information
#define DDLogBWSTouch(frmt, ...)    REFRESH_DD_BWS_LOG_PREFS; ASYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_BWS_TOUCH, 0, ([NSString stringWithFormat:@"<TL> %@", frmt]), ##__VA_ARGS__)
/// Log motion information
#define DDLogBWSMotion(frmt, ...)   REFRESH_DD_BWS_LOG_PREFS; ASYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_BWS_MOTION, 0, ([NSString stringWithFormat:@"<ML> %@", frmt]), ##__VA_ARGS__)
/// Log network information
#define DDLogBWSNetwork(frmt, ...)  REFRESH_DD_BWS_LOG_PREFS; ASYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_BWS_NETWORK, 0, ([NSString stringWithFormat:@"<NL> %@", frmt]), ##__VA_ARGS__)
/// Log device-level sequence issues
#define DDLogBWSDevice(frmt, ...)   REFRESH_DD_BWS_LOG_PREFS; ASYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_BWS_NETWORK, 0, ([NSString stringWithFormat:@"<DL> %@", frmt]), ##__VA_ARGS__)

@interface BWSDDLog : NSObject

+ (int)readBWSDDLogPreferenceLevel;

@end

static int ddLogLevel;

#endif
