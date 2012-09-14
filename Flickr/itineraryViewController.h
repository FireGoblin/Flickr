//
//  itineraryViewController.h
//  Flickr
//
//  Created by Michael Overstreet on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface itineraryViewController : CoreDataTableViewController

@property (nonatomic, strong) UIManagedDocument *photoDatabase;
@end
