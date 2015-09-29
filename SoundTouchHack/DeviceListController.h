//
//  ViewController.h
//  SoundTouchHack
//
//  Created by Jürgen De Beckker on 26/09/15.
//  Copyright © 2015 Ice Design. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceListController : UITableViewController<NSNetServiceBrowserDelegate, NSNetServiceDelegate, NSStreamDelegate>
{
    NSNetServiceBrowser *_browser;
    
    NSNetService *_service;
    
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
    
    NSString *_macAddress;
    char *_ipAddress;
    NSInteger _portNumber;
    
    NSMutableArray *_devices;
}

@end

