//
//  Photo+Flickr.m
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Location+Create.h"
#import "Tag.h"
#import "Tag+Create.h"

@implementation Photo (Flickr)

// 9. Query the database to see if this Flickr dictionary's unique id is already there
// 10. If error, handle it, else if not in database insert it, else just return the photo we found
// 11. Create a category to Photographer to add a factory method and use it to set whoTook
// (then back to PhotographersTableViewController)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)flickrInfo
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"identity = %@", [flickrInfo objectForKey:FLICKR_PHOTO_ID]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.identity = [flickrInfo objectForKey:FLICKR_PHOTO_ID];
        photo.title = [flickrInfo objectForKey:FLICKR_PHOTO_TITLE];
        photo.subtitle = [flickrInfo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.longitude = [flickrInfo objectForKey:FLICKR_LONGITUDE];
        photo.latitude = [flickrInfo objectForKey:FLICKR_LATITUDE];
        photo.image = [[FlickrFetcher urlForPhoto:flickrInfo format:FlickrPhotoFormatLarge] absoluteString];
        photo.location = [Location locationWithName:[flickrInfo objectForKey:FLICKR_PHOTO_PLACE_NAME] inManagedObjectContext:context];
        
        NSArray *tags = [[[flickrInfo objectForKey:FLICKR_TAGS] capitalizedString] componentsSeparatedByString:@" "];
        for(NSString *tag in tags){
            if([[tag componentsSeparatedByString:@":"] count] == 1){
                Tag *holder = [Tag tagWithName:tag inManagedObjectContext:context];
                [photo addTagsObject:holder];
                //[holder addPhotosObject:photo];
            }
        }
    } else {
        photo = [matches lastObject];
    }
    
    return photo;
}

+ (BOOL)photoExistsWithFlickrInfo:(NSDictionary *)flickrInfo
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"identity = %@", [flickrInfo objectForKey:FLICKR_PHOTO_ID]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        return NO;
    } else {
        return YES;
    }
    
    return NO;
}

+ (void)deletePhotoWithImageURL:(NSURL *)url
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"image = %@", [url absoluteString]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        NSLog(@"nothing to delete");
    } else {
        photo = [matches lastObject];
        if([photo.location.photos count] == 1)
            [Location deleteLocationWithName:photo.location.title inManagedObjectContext:context];
        NSMutableArray *tags;
        for(Tag *tag in photo.tags){
            if([tag.photos count] == 1)
                [tags insertObject:tag.title atIndex:0];
        }
        for(NSString *title in tags){
            [Tag deleteTagWithName:title inManagedObjectContext:context];
        }   
        [context deleteObject:photo];
    }
    
}

+ (void)deletePhotoWithFlickrInfo:(NSDictionary *)flickrInfo
              inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"identity = %@", [flickrInfo objectForKey:FLICKR_PHOTO_ID]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        NSLog(@"nothing to delete");
    } else {
        photo = [matches lastObject];
        if([photo.location.photos count] == 1)
            [Location deleteLocationWithName:photo.location.title inManagedObjectContext:context];
        NSMutableArray *tags = [[NSMutableArray alloc] initWithCapacity:[photo.tags count]];
        for(Tag *tag in photo.tags){
            if([tag.photos count] == 1 || [tag.photos count] == 0)
                [tags insertObject:tag.title atIndex:0];
        }
        for(NSString *title in tags){
            [Tag deleteTagWithName:title inManagedObjectContext:context];
        }
        [context deleteObject:photo];
    }
    
}


@end
