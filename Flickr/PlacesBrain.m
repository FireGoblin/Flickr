//
//  PlacesBrain.m
//  Flickr
//
//  Created by Michael Overstreet on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlacesBrain.h"
#import "FlickrFetcher.h"

@interface PlacesBrain()
@property (nonatomic, strong) NSArray *theList;
@end



@implementation PlacesBrain

@synthesize theList = _theList;

NSInteger citySort(id city1, id city2, void *context)
{
    return [[city1 objectForKey:FLICKR_PLACE_NAME] compare:[city2 objectForKey:FLICKR_PLACE_NAME]];
}

- (void)setPlaceList:(NSArray *)placeList
{
    _theList = [[placeList sortedArrayUsingFunction:citySort context:NULL] copy];
}

- (NSArray *)placeList
{
    return [_theList copy];
}

@end
