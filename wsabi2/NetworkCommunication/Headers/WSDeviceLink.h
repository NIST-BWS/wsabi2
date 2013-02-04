// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import <Foundation/Foundation.h>

#import "WSBDAFHTTPClient.h"
#import "WSDeviceLinkDelegate.h"
#import "NBCLDeviceLinkConstants.h"

/// Communication mechanism with a single WS-BD service
@interface WSDeviceLink : NSObject <NSXMLParserDelegate>

/// Base URI to the device.
@property (nonatomic, strong, readonly) NSURL *baseURI;
/// Established Session ID with the service.
@property (nonatomic, strong, readonly) NSString *currentSessionId;

/// @brief
/// Whether or not service registration procedure has completed.
/// @note
/// This is a suggestion only and may not reflect the true state.
@property (nonatomic, readonly) BOOL registered;

/// @brief
/// Whether or not registration has a lock on the service.
/// @note
/// This is a suggestion only and may not reflect the true state.
@property (nonatomic, readonly) BOOL hasLock;

/// @brief
/// Whether or not the service initialization procedure has completed.
/// @note
/// This is a suggestion only and may not reflect the true state.
@property (nonatomic, readonly) BOOL initialized;

/// Active sequence of operations being performed.
// TODO: Replace with state machine (github issue #148)
@property (nonatomic, readonly) SensorSequenceType sequenceInProgress;

/// Object that acts on service network activity
@property (nonatomic, unsafe_unretained) id<WSDeviceLinkDelegate> delegate;

/// @brief
/// Obtain a textual description for a sensor operation.
/// @param opType
/// The operation in question.
+ (NSString *)stringForSensorOperationType:(SensorOperationType)opType;

/// @brief
/// Create a new WSDeviceLink.
/// @param uri
/// Base URI to the device.
- (id)initWithBaseURI:(NSString *)uri;

//
// Operations/API Endpoints
//

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
- (BOOL)beginConnectConfigureSequenceWithConfigurationParams:(NSMutableDictionary *)params sourceObjectID:(NSURL *)sourceID;
- (BOOL)beginConfigCaptureDownloadSequence:(NSString *)sessionId configurationParams:(NSMutableDictionary *)params withMaxSize:(float)maxSize sourceObjectID:(NSURL *)sourceID;
- (BOOL)beginFullSequenceWithConfigurationParams:(NSMutableDictionary *)params withMaxSize:(float)maxSize sourceObjectID:(NSURL *)sourceID;

/// Remove all enqueued network operations.
- (void)cancelAllOperations;

@end
