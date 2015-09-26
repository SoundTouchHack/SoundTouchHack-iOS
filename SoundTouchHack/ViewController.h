//
//  ViewController.h
//  SoundTouchHack
//
//  Created by Jürgen De Beckker on 26/09/15.
//  Copyright © 2015 Ice Design. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<NSNetServiceBrowserDelegate>
{
    NSNetServiceBrowser *_browser;
}

@end

