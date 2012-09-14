//
//  VacationHelper.m
//  Flickr
//
//  Created by Michael Overstreet on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "VacationHelper.h"
#import <CoreData/CoreData.h>

@implementation VacationHelper

+ (void) openVacation:(NSString *)vacationName usingBlock:(completion_block_t)completionBlock
{
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *directoryURL = [[manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *filePath = [directoryURL URLByAppendingPathComponent:vacationName];
    
    UIManagedDocument *file = [[UIManagedDocument alloc] initWithFileURL:filePath];
    if([manager fileExistsAtPath:[filePath path]]){
        [file openWithCompletionHandler:^(BOOL success) {
            if (success) completionBlock(file);
            //if (!success) NSLog(@“couldn’t open document at %@”, filePath);
        }];
    } else {
        [file saveToURL:filePath forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) completionBlock(file);
            //if (!success) NSLog(@“couldn’t create document at %@”, filePath);
        }];    
    }
}

@end
