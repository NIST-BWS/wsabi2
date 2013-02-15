#wsabi2

##About

wsabi, short for *web services for acquiring biometric information*, is a reference application that demonstrates the capabilities of the WS-Biometric Devices (WS-BD) protocol as defined by NIST Special Publication 500-288, [**Specification for WS-Biometric Devices**](http://www.nist.gov/itl/iad/ig/upload/NIST-SP-500-288-v1.pdf). 

wsabi requires iOS 6.0 or later.

##Logging
In addition to being a WS-BD reference implementation, wsabi collects touch logging information (for *most* controls) in support of cognitive modeling efforts.  Touch and other custom logging macros are exposed in `BWSDDLog.h`, via extensions to [CocoaLumberjack](https://github.com/robbiehanson/CocoaLumberjack).

Logs are saved as plain text files that can be retrieved from a device via iTunes File Sharing.  When connected to Xcode, logs are also printed to the console.

The various types of logging can be toggled via the Settings popover, which is enabled via the system Settings app.
