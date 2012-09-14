//
//  Location+Create.h
//  Flickr
//
//  Created by Michael Overstreet on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

@interface Location (Create)

+ (Location *)locationWithName:(NSString *)name
        inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)deleteLocationWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

@end
