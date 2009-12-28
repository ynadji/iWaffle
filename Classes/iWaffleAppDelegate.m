//
//  iWaffleAppDelegate.m
//  iWaffle
//
//  Created by Yacin Nadji on 12/13/09.
//  Copyright Georgia Institute of Technology 2009. All rights reserved.
//

#import "iWaffleAppDelegate.h"
#import "iWaffleViewController.h"

@implementation iWaffleAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
