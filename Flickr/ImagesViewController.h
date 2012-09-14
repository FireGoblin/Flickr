//
//  FlickrSecondViewController.h
//  Flickr
//
//  Created by Michael Overstreet on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationImagesViewController.h"

@interface ImagesViewController : UITableViewController <LocationImagesStorage>
-(void)storeViewedPicture:(NSDictionary *)picture;
@end
