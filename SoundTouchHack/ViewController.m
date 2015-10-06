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



- (id)initWithService:(NSNetService *)service
{
    self = [super init];
    
    if (self)
    {
        _service = service;
        
        self.title = _service.name;
        
        //[self reconnect];
    }
    
    return self;
}

- (void)loadView
{
    CGRect frame = [UIScreen mainScreen].bounds;
    
    _mainView = [[MainView alloc] initWithFrame:frame];
    
    _mainView.delegate = self;
    
    self.view = _mainView;
    
    [self updateInfo];
    
    [self reconnect];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self discover];
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
    
    NSLog(@"%@", urlString);
    
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
    NSLog(@"-- %@", [_service name]);
    
    for (NSData *address in [_service addresses]) {
        struct sockaddr_in *socketAddress = (struct sockaddr_in *) [address bytes];
        
        _ipAddress = inet_ntoa(socketAddress->sin_addr);
        _portNumber = _service.port;
        
        [_mainView setLabel:[NSString stringWithFormat:@"SoundTouch device:\n%@\n\nIP address: %s\nPort number: %i", [_service name], _ipAddress, _portNumber]];
    }
}

- (void)reconnect;
{
    _webSocket.delegate = nil;
    _webSocket = nil;
    
    NSString *urlString = [NSString stringWithFormat:@"ws://%s:8080/", _ipAddress];
    
    NSLog(@"Web socket url: %@", urlString);
    
    SRWebSocket *newWebSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:urlString]];
    newWebSocket.delegate = self;
    
    [newWebSocket open];
    
    /*
    _webSocket.delegate = nil;
    
    //[_webSocket close];
    
    NSString *url = [NSString stringWithFormat:@"ws://%s:8080", _ipAddress];
    
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    _webSocket.delegate = self;
    
    NSLog(@"Opening web socket connection...");
    
    [_webSocket open];*/
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

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)newWebSocket
{
    _webSocket = newWebSocket;
    
    [_webSocket send:[NSString stringWithFormat:@"webSocketDidOpen: %@", [UIDevice currentDevice].name]];
    
    NSLog(@"Web socket did open");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"Web socket didFailWithError: %@", error.description);
    
    //[self reconnect];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"Web socket did close");
    
    //NSLog(@"Web socket didCloseWithCode: %d - %@ - %@", code, reason, wasClean);
    
    [self reconnect];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"Web socket didReceiveMessage: %@", message);
    
    //self.messagesTextView.text = [NSString stringWithFormat:@"%@\n%@", self.messagesTextView.text, message];
}

@end
