//
//  FlickrAnnotation.h
//  Flickr
//
//  Created by Michael Overstreet on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FlickrAnnotation : NSObject <MKAnnotation>

-(NSDictionary *)item;

@end
