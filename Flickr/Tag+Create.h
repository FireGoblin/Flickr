//
//  Tag+Create.h
//  Flickr
//
//  Created by Michael Overstreet on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tag.h"

@interface Tag (Create)

+ (Tag *)tagWithName:(NSString *)name
        inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)deleteTagWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;


@end
