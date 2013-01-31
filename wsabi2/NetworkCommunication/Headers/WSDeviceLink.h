// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import <Foundation/Foundation.h>

#import "WSBDAFHTTPClient.h"
#import "NBCLDeviceLink.h"
#import "WSDeviceLinkDelegate.h"

static NSString * const kBCLWSBDNamespace = @"xmlns=\"urn:oid:2.16.840.1.101.3.9.3.1\"";
static NSString * const kBCLSchemaInstanceNamespace = @"xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\"";
static NSString * const kBCLSchemaNamespace = @"xmlns:xs=\"http://www.w3.org/2001/XMLSchema\"";
static NSString * const kBCLGETMethod = @"GET";
static NSString * const kBCLPOSTMethod = @"POST";
static NSString * const kBCLPUTMethod = @"PUT";
static NSString * const kBCLDELETEMethod = @"DELETE";

@interface WSDeviceLink : NSObject <NSXMLParserDelegate>

/// Base URI to the device
@property (nonatomic, strong) NSURL *baseURI;
@property (nonatomic, strong) WSBDAFHTTPClient* service;


@property (nonatomic, strong) NSString *currentSessionId;

//IMPORTANT NOTE: Each of these is a GUIDELINE, and SUGGESTS that the sensor
//is PROBABLY past the stated phase and connected. If the sensor is
//disconnected, or another client holds the lock when the next operation is
//performed, it will still fail.
@property (nonatomic) BOOL registered;
@property (nonatomic) BOOL hasLock;
@property (nonatomic) BOOL initialized;

@property (nonatomic) SensorSequenceType sequenceInProgress;
@property (nonatomic) BOOL shouldRetryDownloadIfPending;

@property (nonatomic, unsafe_unretained) id<WSDeviceLinkDelegate> delegate;


/// @brief
/// Create a new WSDeviceLink
/// @param uri
/// Base URI to the device
- (id)initWithBaseURI:(NSString *)uri;

- (void)registerClient:(NSURL *)sourceObjectID;
- (void)unregisterClient:(NSString *)sessionId sourceObjectId:(NSURL *)sourceObjectID;
- (void)initialize:(NSString *)sessionId sourceObjectId:(NSURL *)sourceID;

- (void)getConfiguration:(NSString *)sessionId sourceObjectID:(NSURL *)sourceID;
- (void)setConfiguration:(NSString *)sessionId withParameters:(NSDictionary *)params sourceObjectID:(NSURL *)sourceID;
- (void)getServiceInfo:(NSURL *)sourceID;
- (void)cancel:(NSString *)sessionId sourceObjectID:(NSURL *)sourceObjectID;

- (void)lock:(NSString *)sessionId sourceObjectID:(NSURL *)sourceID;
- (void)unlock:(NSString *)sessionId sourceObjectID:(NSURL *)sourceID;
- (void)stealLock:(NSString *)sessionId sourceObjectID:(NSURL *)sourceID;

- (void)capture:(NSString *)sessionId sourceObjectID:(NSURL *)sourceID;
- (void)getDownloadInfo:(NSString *)captureId sourceObjectID:(NSURL *)sourceObjectID;
- (void)download:(NSString *)captureId sourceObjectID:(NSURL *)sourceID;
- (void)download:(NSString *)captureId withMaxSize:(float)maxSize sourceObjectID:(NSURL *)sourceID;

- (BOOL)beginConnectSequenceWithSourceObjectID:(NSURL *)sourceObjectID;

- (void)cancelAllOperations;

@end
