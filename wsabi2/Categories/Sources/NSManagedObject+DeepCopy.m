// This software was developed at the National Institute of Standards and
// Technology (NIST) by employees of the Federal Government in the course
// of their official duties. Pursuant to title 17 Section 105 of the
// United States Code, this software is not subject to copyright protection
// and is in the public domain. NIST assumes no responsibility whatsoever for
// its use by other parties, and makes no guarantees, expressed or implied,
// about its quality, reliability, or any other characteristic.

#import "NSManagedObject+DeepCopy.h"

@implementation NSManagedObject (DeepCopy)

- (NSManagedObject *)cloneInContext:(NSManagedObjectContext *)context withCopiedCache:(NSMutableDictionary *)alreadyCopied exludeEntities:(NSArray *)namesOfEntitiesToExclude {
    NSString *entityName = [[self entity] name];
    
    if ([namesOfEntitiesToExclude containsObject:entityName]) {
        return nil;
    }
    
    NSManagedObject *cloned = [alreadyCopied objectForKey:[self objectID]];
    if (cloned != nil) {
        return cloned;
    }
    
    //create new object in data store
    cloned = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    [alreadyCopied setObject:cloned forKey:[self objectID]];
    
    //loop through all attributes and assign then to the clone
    NSDictionary *attributes = [[NSEntityDescription entityForName:entityName inManagedObjectContext:context] attributesByName];
    
    for (NSString *attr in attributes) {
        [cloned setValue:[self valueForKey:attr] forKey:attr];
    }
    
    //Loop through all relationships, and clone them.
    NSDictionary *relationships = [[NSEntityDescription entityForName:entityName inManagedObjectContext:context] relationshipsByName];
    for (NSString *relName in [relationships allKeys]){
        NSRelationshipDescription *rel = [relationships objectForKey:relName];
        
        NSString *keyName = rel.name;
        //Do ordered sets first, then unordered.
        if ([rel isToMany] && [rel isOrdered]) {
            //get a set of all objects in the relationship
            NSMutableOrderedSet *sourceSet = [self mutableOrderedSetValueForKey:keyName];
            NSMutableOrderedSet *clonedSet = [cloned mutableOrderedSetValueForKey:keyName];
            NSEnumerator *e = [sourceSet objectEnumerator];
            NSManagedObject *relatedObject;
            while ( relatedObject = [e nextObject]){
                //Clone it, and add clone to set
                NSManagedObject *clonedRelatedObject = [relatedObject cloneInContext:context withCopiedCache:alreadyCopied exludeEntities:namesOfEntitiesToExclude];
                [clonedSet addObject:clonedRelatedObject];
            }
        }
        else if ([rel isToMany]) {
            //get a set of all objects in the relationship
            NSMutableSet *sourceSet = [self mutableSetValueForKey:keyName];
            NSMutableSet *clonedSet = [cloned mutableSetValueForKey:keyName];
            NSEnumerator *e = [sourceSet objectEnumerator];
            NSManagedObject *relatedObject;
            while ( relatedObject = [e nextObject]){
                //Clone it, and add clone to set
                NSManagedObject *clonedRelatedObject = [relatedObject cloneInContext:context withCopiedCache:alreadyCopied exludeEntities:namesOfEntitiesToExclude];
                [clonedSet addObject:clonedRelatedObject];
            }
        }
        else {
            NSManagedObject *relatedObject = [self valueForKey:keyName];
            if (relatedObject != nil) {
                NSManagedObject *clonedRelatedObject = [relatedObject cloneInContext:context withCopiedCache:alreadyCopied exludeEntities:namesOfEntitiesToExclude];
                [cloned setValue:clonedRelatedObject forKey:keyName];
            }
        }
    }
    
    return cloned;
}

- (NSManagedObject *)cloneInContext:(NSManagedObjectContext *)context exludeEntities:(NSArray *)namesOfEntitiesToExclude {
    return [self cloneInContext:context withCopiedCache:[NSMutableDictionary dictionary] exludeEntities:namesOfEntitiesToExclude];
}

@end
