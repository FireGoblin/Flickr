//
//  TagPhotosViewController.h
//  Flickr
//
//  Created by Michael Overstreet on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tag.h"
#import "CoreDataTableViewController.h"

@interface TagPhotosViewController : CoreDataTableViewController

@property (nonatomic, strong) Tag *tag;

@end
