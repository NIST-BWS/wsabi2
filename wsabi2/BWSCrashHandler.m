// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#include <execinfo.h>

#import "DDLog.h"

#import "BWSCrashHandler.h"

void ExceptionHandler(NSException *exception);
void SignalHandler(int signal);

static const NSInteger kBWSCrashHandlerMaximumFrames = 20;
static int ddLogLevel = LOG_LEVEL_ERROR;

@implementation BWSCrashHandler

+ (void)setupCrashHandling
{
    // Catch uncaught exceptions
	NSSetUncaughtExceptionHandler(&ExceptionHandler);
    
    // Catch some common signals
	signal(SIGABRT, SignalHandler);
	signal(SIGILL, SignalHandler);
	signal(SIGSEGV, SignalHandler);
	signal(SIGFPE, SignalHandler);
	signal(SIGBUS, SignalHandler);
}

+ (NSArray *)backtrace
{
    void *callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (NSInteger i = 0; ((i < frames) && (i < kBWSCrashHandlerMaximumFrames)); i++)
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    free(strs);
    
    return (backtrace);
}

#pragma mark - Handlers

void
ExceptionHandler(NSException *exception)
{
    [BWSCrashHandler handleException:exception];
}

void
SignalHandler(int signal)
{
    [NSException raise:@"SignalRaisedException" format:@"%s (%d)", strerror(signal), signal];
}

#pragma mark - Logging

+ (void)handleException:(NSException *)exception
{
    DDLogError(@"CRASH: %@: %@", exception.name, exception.reason);
    if (([exception userInfo] != nil) && ([[exception userInfo] count] > 0))
        DDLogError(@"%@", [exception userInfo]);
    
    NSArray *backtrace = [BWSCrashHandler backtrace];
    for (NSString *backtraceLine in backtrace) {
        DDLogError(@"%@", backtraceLine);
    }
    
    // Quit
    sync();
    kill(getpid(), SIGKILL);
}

@end
