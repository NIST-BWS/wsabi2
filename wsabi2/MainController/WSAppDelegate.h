//
//  WSAppDelegate.h
//  wsabi2
//
//  Created by Matt Aronoff on 1/10/12.
 
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"

@class BWSViewController;

@interface WSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//Core Data
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//Logging
@property (nonatomic, strong) DDFileLogger *fileLogger;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

//The main view controller
@property (strong, nonatomic) BWSViewController *viewController;

@end
