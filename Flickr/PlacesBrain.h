//
//  PlacesBrain.h
//  Flickr
//
//  Created by Michael Overstreet on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlacesBrain : NSObject

NSInteger citySort(id city1, id city2, void *context);

@property (nonatomic, strong) NSArray *placeList;

@end
