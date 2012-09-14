//
//  PictureViewController.h
//  Flickr
//
//  Created by Michael Overstreet on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureViewController : UIViewController

-(void)setup:(NSDictionary *)picture;
-(void)setup;

@property (nonatomic, strong) NSURL *image;

@property (nonatomic, strong) NSDictionary *imageData;

@end
