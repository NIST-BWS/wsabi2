// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import "BWSConstants.h"

#import "BWSDDLog.h"

@implementation BWSDDLog

+ (int)readBWSDDLogPreferenceLevel
{
    int logLevel = 0;
    
    /* Check for defaults */
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsTouchLoggingEnabled])
        logLevel |= LOG_FLAG_BWS_TOUCH;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMotionLoggingEnabled])
        logLevel |= LOG_FLAG_BWS_MOTION;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsNetworkLoggingEnabled])
        logLevel |= LOG_FLAG_BWS_NETWORK;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsDeviceLoggingEnabled])
        logLevel |= LOG_FLAG_BWS_DEVICE;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsVerboseLoggingEnabled])
        logLevel |= LOG_FLAG_BWS_VERBOSE;
    
    // To quiesce unused variable warning
    ddLogLevel = logLevel;
    
    return (logLevel);
}

@end
