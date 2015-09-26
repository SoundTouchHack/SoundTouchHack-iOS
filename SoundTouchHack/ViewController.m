//
//  ViewController.m
//  SoundTouchHack
//
//  Created by Jürgen De Beckker on 26/09/15.
//  Copyright © 2015 Ice Design. All rights reserved.
//

#import "ViewController.h"

#import "MainView.h"

@interface ViewController ()
{
    MainView *_mainView;
}

@end

@implementation ViewController

- (void)loadView
{
    CGRect frame = [UIScreen mainScreen].bounds;
    
    _mainView = [[MainView alloc] initWithFrame:frame];
    
    self.view = _mainView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self discover];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Bose specific code

- (void)discover
{
    _browser = [[NSNetServiceBrowser alloc] init];
    
    [_browser setDelegate:self];
    
    [_browser searchForServicesOfType:@"_soundtouch._tcp" inDomain:@""];
}

#pragma mark - NSNetServiceBrowserDelegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    NSLog(@"found service %@ with name %@", service, [service name]);
    
    [_mainView setLabel:[NSString stringWithFormat:@"SoundTouch device found:\n%@", [service name]]];
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
    NSLog(@"did stop searching");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict
{
    NSLog(@"did not search");
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
    NSLog(@"will search");
    
    [_mainView setLabel:@"Searching for SoundTouch devices..."];
}

@end
