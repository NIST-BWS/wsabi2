/*
 *  NBCLSensorLinkConstants.h
 *  Wsabi
 *
 *  Created by Matt Aronoff on 11/30/10.
 *
 */
/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */


//Operation types
typedef enum {
    kOpTypeRegister = 0,
    kOpTypeUnregister,
    kOpTypeLock,
    kOpTypeUnlock,
    kOpTypeStealLock,
    kOpTypeGetCommonInfo,
    kOpTypeGetDetailedInfo,
    kOpTypeInitialize,
    kOpTypeGetConfiguration,
    kOpTypeConfigure,
    kOpTypeGetContentType,
    kOpTypeCapture,
    kOpTypeDownload,
    kOpTypeThriftyDownload,
    kOpTypeCancel,
    kOpTypeConnectSequence,
    kOpTypeCaptureSequence,
    kOpTypeDisconnectSequence,
    kOpTypeAll

} SensorOperationType;