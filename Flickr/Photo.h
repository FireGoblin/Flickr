//
//  Photo.h
//  Flickr
//
//  Created by Michael Overstreet on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location, Tag;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * identity;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Location *location;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
