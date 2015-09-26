//
//  ViewController.m
//  SoundTouchHack
//
//  Created by Jürgen De Beckker on 26/09/15.
//  Copyright © 2015 Ice Design. All rights reserved.
//

#include <arpa/inet.h>

#import "ViewController.h"

#import "XmlParser.h"

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
    
    _mainView.delegate = self;
    
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

- (void)getVolume
{
    NSString *urlString = [NSString stringWithFormat:@"http://%s:%i/volume", _ipAddress, _portNumber];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil)
             [self fetchedVolume:data];
         
         /*
          else if ([data length] == 0 && error == nil)
          NSLog(@"parser: data length = 0");
          else if (error != nil && error.code == ERROR_CODE_TIMEOUT)
          [delegate timedOut];
          else if (error != nil)
          NSLog(@"parser error: %@", error);
          */
     }];
}

- (void)fetchedVolume:(NSData *)data
{
    XmlParser *parser = [[XmlParser alloc] init];
    
    int volume = [parser parseXml:data];
    
    [_mainView setVolume:volume];
    
    NSLog(@"volume fetched: %d", volume);
}

- (void)setVolume:(int)volume
{
    NSString *post = [NSString stringWithFormat:@"<volume>%d</volume>", volume];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSString *urlString = [NSString stringWithFormat:@"http://%s:%i/volume", _ipAddress, _portNumber];
    
    NSLog(@"URL string: %@", urlString);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:YES];
    if (connection)
        NSLog(@"Command sent successfully");
    else
        NSLog(@"Sending command failed");
}

- (void)updateInfo
{
    [_mainView setLabel:[NSString stringWithFormat:@"SoundTouch device found:\n%@\n\nMAC address: %@\nIP address: %s\nPort number: %i", [_service name], _macAddress, _ipAddress, _portNumber]];
}

#pragma mark - NSNetServiceBrowserDelegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    NSLog(@"Found service: %@", [service name]);
    
    [self updateInfo];
    
    
    _service = [[NSNetService alloc] initWithDomain:@"local." type:@"_soundtouch._tcp" name:[service name]];
    
    _service.delegate = self;
    
    [_service resolveWithTimeout:2];
    [_service startMonitoring];
    
    
    //[self sendStreamToService:_service];
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
    NSLog(@"Did stop searching");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict
{
    NSLog(@"Did not search");
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
    NSLog(@"Start searching");
    
    [_mainView setLabel:@"Searching for SoundTouch devices..."];
}

#pragma mark - NSNetServiceDelegate

- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data
{
    NSString * newStr = [[NSString alloc] initWithData:[[NSNetService dictionaryFromTXTRecordData:data] objectForKey:@"MAC"] encoding:NSUTF8StringEncoding];
    
    _macAddress = newStr;
    
    NSLog(@"MAC address: %@", _macAddress);
    
    [self updateInfo];
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    for (NSData *address in [sender addresses]) {
        struct sockaddr_in *socketAddress = (struct sockaddr_in *) [address bytes];
        
        _ipAddress = inet_ntoa(socketAddress->sin_addr);
        _portNumber = [sender port];
        
        NSLog(@"IP address: %s", _ipAddress);
        NSLog(@"Port number: %i", _portNumber);
        
        [self updateInfo];
        
        [self getVolume];
    }
}

#pragma mark - MainViewDelegate

- (void)volume:(int)volume
{
    [self setVolume:volume];
}

@end
