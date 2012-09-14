//
//  Tag+Create.m
//  Flickr
//
//  Created by Michael Overstreet on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Tag+Create.h"

@implementation Tag (Create)

+ (Tag *)tagWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context    
{
    Tag *tag = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.predicate = [NSPredicate predicateWithFormat:@"title = %@", name];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *tags = [context executeFetchRequest:request error:&error];
    
    if (!tags || ([tags count] > 1)) {
        //handle error
    } else if (![tags count]) {
        tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
        tag.title = name;
    } else {
        tag = [tags lastObject];
    }
    
    return tag;
}

+ (void)deleteTagWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context    
{
    Tag *tag = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.predicate = [NSPredicate predicateWithFormat:@"title = %@", name];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *tags = [context executeFetchRequest:request error:&error];
    
    if (!tags || ([tags count] > 1)) {
        //handle error
    } else if (![tags count]) {
        //do nothing
    } else {
        tag = [tags lastObject];
        [context deleteObject:tag];
    }
}

@end
