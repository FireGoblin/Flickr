//
//  Location+Create.m
//  Flickr
//
//  Created by Michael Overstreet on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Location+Create.h"

@implementation Location (Create)

+ (Location *)locationWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context    
{
    Location *location = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    request.predicate = [NSPredicate predicateWithFormat:@"title = %@", name];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *locations = [context executeFetchRequest:request error:&error];
    
    if (!locations || ([locations count] > 1)) {
        //handle error
    } else if (![locations count]) {
        location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:context];
        location.title = name;
        location.time = [NSDate date];
    } else {
        location = [locations lastObject];
    }
    
    return location;
}

+ (void)deleteLocationWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context    
{
    Location *location = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    request.predicate = [NSPredicate predicateWithFormat:@"title = %@", name];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *locations = [context executeFetchRequest:request error:&error];
    
    if (!locations || ([locations count] > 1)) {
        //handle error
    } else if (![locations count]) {
        //do nothing
    } else {
        location = [locations lastObject];
        [context deleteObject:location];
    }
}

@end
