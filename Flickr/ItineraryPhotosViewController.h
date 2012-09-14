//
//  ItineraryPhotosViewController.h
//  Flickr
//
//  Created by Michael Overstreet on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "CoreDataTableViewController.h"

@interface ItineraryPhotosViewController : CoreDataTableViewController

@property (nonatomic, strong) Location *location;

@end
