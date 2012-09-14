//
//  ImagesBrain.h
//  Flickr
//
//  Created by Michael Overstreet on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImagesBrain : NSObject

-(void)storeViewedPicture:(NSDictionary *)picture;
-(void)loadData;

@property (nonatomic, strong, readonly) NSArray *imageList;

@end
