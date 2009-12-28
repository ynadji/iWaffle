//
//  iWaffleAppDelegate.h
//  iWaffle
//
//  Created by Yacin Nadji on 12/13/09.
//  Copyright Georgia Institute of Technology 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iWaffleViewController;

@interface iWaffleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    iWaffleViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet iWaffleViewController *viewController;

@end

