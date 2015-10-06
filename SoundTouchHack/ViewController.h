//
//  ViewController.h
//  SoundTouchHack
//
//  Created by Jürgen De Beckker on 26/09/15.
//  Copyright © 2015 Ice Design. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MainView.h"
#import "SRWebSocket.h"

@interface ViewController : UIViewController<NSNetServiceBrowserDelegate, NSNetServiceDelegate, NSStreamDelegate, MainViewDelegate, SRWebSocketDelegate>
{
    NSNetServiceBrowser *_browser;
    
    NSNetService *_service;
    
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
    
    NSString *_macAddress;
    char *_ipAddress;
    NSInteger _portNumber;
    
    SRWebSocket *_webSocket;
    NSMutableArray *_messages;
}

@property (nonatomic, strong) SRWebSocket *webSocket;

- (id)initWithService:(NSNetService *)service;

@end

