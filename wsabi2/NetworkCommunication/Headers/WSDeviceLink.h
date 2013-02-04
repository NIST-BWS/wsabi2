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

- (void)registerClient:(NSURL *)deviceID;
- (void)unregisterClient:(NSString *)sessionId deviceID:(NSURL *)deviceID;
- (void)initialize:(NSString *)sessionId deviceID:(NSURL *)deviceID;

- (void)getConfiguration:(NSString *)sessionId deviceID:(NSURL *)deviceID;
- (void)setConfiguration:(NSString *)sessionId withParameters:(NSDictionary *)params deviceID:(NSURL *)deviceID;
- (void)getServiceInfo:(NSURL *)deviceID;
- (void)cancel:(NSString *)sessionId deviceID:(NSURL *)deviceID;

- (void)lock:(NSString *)sessionId deviceID:(NSURL *)deviceID;
- (void)unlock:(NSString *)sessionId deviceID:(NSURL *)deviceID;
- (void)stealLock:(NSString *)sessionId deviceID:(NSURL *)deviceID;

- (void)capture:(NSString *)sessionId deviceID:(NSURL *)deviceID;
- (void)getDownloadInfo:(NSString *)captureId deviceID:(NSURL *)deviceID;
- (void)download:(NSString *)captureId deviceID:(NSURL *)deviceID;
- (void)download:(NSString *)captureId withMaxSize:(float)maxSize deviceID:(NSURL *)deviceID;

- (BOOL)beginConnectSequenceWithDeviceID:(NSURL *)deviceID;
- (BOOL)beginConnectConfigureSequenceWithConfigurationParams:(NSMutableDictionary *)params deviceID:(NSURL *)deviceID;
- (BOOL)beginConfigCaptureDownloadSequence:(NSString *)sessionId configurationParams:(NSMutableDictionary *)params withMaxSize:(float)maxSize deviceID:(NSURL *)deviceID;
- (BOOL)beginFullSequenceWithConfigurationParams:(NSMutableDictionary *)params withMaxSize:(float)maxSize deviceID:(NSURL *)deviceID;

/// Remove all enqueued network operations.
- (void)cancelAllOperations;

@end
