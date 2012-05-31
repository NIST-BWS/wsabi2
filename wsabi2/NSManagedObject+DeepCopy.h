//
//  NSManagedObject+DeepCopy.h
//  wsabi2
//
//  Created by Matt Aronoff on 1/19/12.
 
//

//This is taken from http://stackoverflow.com/a/7613406 
//(The accepted answer and followup on the parent topic don't handle to-one relationships, 
//and possibly fail for other reasons as well, so we're using this version.)

#import <CoreData/CoreData.h>

@interface NSManagedObject (DeepCopy)

-(NSManagedObject *)cloneInContext:(NSManagedObjectContext *)context exludeEntities:(NSArray *)namesOfEntitiesToExclude;

@end
