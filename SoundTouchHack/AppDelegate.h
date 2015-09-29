//
//  AppDelegate.h
//  SoundTouchHack
//
//  Created by Jürgen De Beckker on 26/09/15.
//  Copyright © 2015 Ice Design. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DeviceListController.h"
#import "ViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    DeviceListController *_deviceListController;
    ViewController *_viewController;
}

@property (strong, nonatomic) UIWindow *window;


@end

