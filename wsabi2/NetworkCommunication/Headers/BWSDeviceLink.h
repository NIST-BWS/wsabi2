// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import <Foundation/Foundation.h>

#import "WSBDAFHTTPClient.h"
#import "BWSDeviceLinkDelegate.h"
#import "BWSDeviceLinkConstants.h"

/// Communication mechanism with a single WS-BD service
@interface BWSDeviceLink : NSObject <NSXMLParserDelegate>

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
@property (nonatomic, unsafe_unretained) id<BWSDeviceLinkDelegate> delegate;

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

/// @brief
/// Open a new client-server session.
/// @param deviceID
/// URL-representation of the backing managed WSCDDeviceDefinition object.
- (void)registerClient:(NSURL *)deviceID;

/// @brief
/// Close a client-server session.
/// @param sessionId
/// Identity of the session to remove.
/// @param deviceID
/// URL-representation of the backing managed WSCDDeviceDefinition object.
- (void)unregisterClient:(NSString *)sessionId deviceID:(NSURL *)deviceID;

/// @brief
/// Initialize the target biometric sensor.
/// @param sessionId
/// Identity of the session requesting initialization.
/// @param deviceID
/// URL-representation of the backing managed WSCDDeviceDefinition object.
- (void)initialize:(NSString *)sessionId deviceID:(NSURL *)deviceID;

/// @brief
/// Retrieve metadata about the target biometric sensor's current configuration.
/// @param sessionId
/// Identity of the session requesting the configuration.
/// @param deviceID
/// URL-representation of the backing managed WSCDDeviceDefinition object.
- (void)getConfiguration:(NSString *)sessionId deviceID:(NSURL *)deviceID;

/// @brief
/// Set the target biometric sensor's configuration.
/// @param sessionId
/// Identity of the session setting the configuration.
/// @param deviceID
/// URL-representation of the backing managed WSCDDeviceDefinition object.
- (void)setConfiguration:(NSString *)sessionId withParameters:(NSDictionary *)params deviceID:(NSURL *)deviceID;

/// @brief
/// Retrieve metadata about the service.
/// @details
/// The metadata does not depend on session-specifc information or soverign
/// control of the target biometric sensor.
/// @param deviceID
/// URL-representation of the backing managed WSCDDeviceDefinition object.
- (void)getServiceInfo:(NSURL *)deviceID;

/// @brief
/// Cancel the current sensor operation.
/// @param sessionId
/// Identity of the session requesting cancellation.
/// @param deviceID
/// URL-representation of the backing managed WSCDDeviceDefinition object.
- (void)cancel:(NSString *)sessionId deviceID:(NSURL *)deviceID;

/// @brief
/// Try to obtain the service lock.
/// @param sessionId
/// Identity of the session requesting the service lock.
/// @param deviceID
/// URL-representation of the backing managed WSCDDeviceDefinition object.
- (void)lock:(NSString *)sessionId deviceID:(NSURL *)deviceID;

/// @brief
/// Release the service lock.
/// @param sessionId
/// Identity of the session requesting the service lock.
/// @param deviceID
/// URL-representation of the backing managed WSCDDeviceDefinition object.
- (void)unlock:(NSString *)sessionId deviceID:(NSURL *)deviceID;

/// @brief
/// Forcibly obtain the lock away from a peer client.
/// @param sessionId
/// Identity of the session requesting the service lock.
/// @param deviceID
/// URL-representation of the backing managed WSCDDeviceDefinition object.
- (void)stealLock:(NSString *)sessionId deviceID:(NSURL *)deviceID;

/// @brief
/// Capture biometric data.
/// @param sessionId
/// Identity of the session capturing the biometric data.
/// @param deviceID
/// URL-representation of the backing managed WSCDDeviceDefinition object.
- (void)capture:(NSString *)sessionId deviceID:(NSURL *)deviceID;

/// @brief
/// Get the metadata associated with a capture.
/// @param captureId
/// Identity of the captured data to query.
/// @param deviceID
/// URL-representation of the backing managed WSCDDeviceDefinition object.
- (void)getDownloadInfo:(NSString *)captureId deviceID:(NSURL *)deviceID;

/// @brief
/// Download the captured biometric data.
/// @param captureId
/// Identity of the captured data to download.
/// @param deviceID
/// URL-representation of the backing managed WSCDDeviceDefinition object.
- (void)download:(NSString *)captureId deviceID:(NSURL *)deviceID;

/// @brief
/// Download a scaled representatio of the captured biometric data ("thrifty").
/// @param captureId
/// Identify ot the captured data to download.
/// @param maxSize
/// Content-type dependent indicator of maximum permitted download size.
/// @param deviceID
/// URL-representation of the backing managed WSCDDeviceDefinition object.
- (void)download:(NSString *)captureId withMaxSize:(float)maxSize deviceID:(NSURL *)deviceID;

//
// Predetermined operation sequences
//

- (BOOL)beginConnectSequenceWithDeviceID:(NSURL *)deviceID;
- (BOOL)beginConnectConfigureSequenceWithConfigurationParams:(NSMutableDictionary *)params deviceID:(NSURL *)deviceID;
- (BOOL)beginConfigCaptureDownloadSequence:(NSString *)sessionId configurationParams:(NSMutableDictionary *)params withMaxSize:(float)maxSize deviceID:(NSURL *)deviceID;
- (BOOL)beginFullSequenceWithConfigurationParams:(NSMutableDictionary *)params withMaxSize:(float)maxSize deviceID:(NSURL *)deviceID;

/// Remove all enqueued network operations.
- (void)cancelAllOperations;

@end
