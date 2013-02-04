// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

//This is taken from http://stackoverflow.com/a/7613406 
//(The accepted answer and followup on the parent topic don't handle to-one relationships, 
//and possibly fail for other reasons as well, so we're using this version.)

#import <CoreData/CoreData.h>

@interface NSManagedObject (DeepCopy)

-(NSManagedObject *)cloneInContext:(NSManagedObjectContext *)context exludeEntities:(NSArray *)namesOfEntitiesToExclude;

@end
