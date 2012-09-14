//
//  Photo+Flickr.h
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)flickrInfo
        inManagedObjectContext:(NSManagedObjectContext *)context;

+ (BOOL)photoExistsWithFlickrInfo:(NSDictionary *)flickrInfo
           inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)deletePhotoWithImageURL:(NSURL *)url
         inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)deletePhotoWithFlickrInfo:(NSDictionary *)flickrInfo
              inManagedObjectContext:(NSManagedObjectContext *)context;

@end
