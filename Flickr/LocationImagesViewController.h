//
//  LocationImagesViewController.h
//  Flickr
//
//  Created by Michael Overstreet on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LocationImagesStorage <NSObject>
-(void)storeViewedPicture:(NSDictionary *)picture;
@end

@interface LocationImagesViewController : UITableViewController

-(void)setup:(NSDictionary *)dict;

@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, weak) IBOutlet id <LocationImagesStorage> storage;

@end
