//
//  ViewController.m
//  SoundTouchHack
//
//  Created by Jürgen De Beckker on 26/09/15.
//  Copyright © 2015 Ice Design. All rights reserved.
//

#include <arpa/inet.h>

#import "DeviceListController.h"

#import "Device.h"
#import "ViewController.h"
#import "XmlParser.h"

@interface DeviceListController ()
{
}

@end

@implementation DeviceListController

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.title = @"Devices";
        
        _services = [[NSMutableArray alloc] init];
        
        [self discover];
    }
    
    return self;
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
    NSLog(@"Found device: %@", [service name]);
    
    
    NSNetService *service2 = [[NSNetService alloc] initWithDomain:@"local." type:@"_soundtouch._tcp" name:[service name]];
    
    service2.delegate = self;
    
    [service2 resolveWithTimeout:2];
    [service2 startMonitoring];
    
    [_services addObject:service2];
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
    //NSLog(@"Did stop searching");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict
{
    //NSLog(@"Did not search");
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
    //NSLog(@"Start searching");
}

#pragma mark - NSNetServiceDelegate

- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data
{
    NSString * newStr = [[NSString alloc] initWithData:[[NSNetService dictionaryFromTXTRecordData:data] objectForKey:@"MAC"] encoding:NSUTF8StringEncoding];
    
    _macAddress = newStr;
    
    //NSLog(@"MAC address: %@", _macAddress);
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    for (NSData *address in [sender addresses]) {
        struct sockaddr_in *socketAddress = (struct sockaddr_in *) [address bytes];
        
        _ipAddress = inet_ntoa(socketAddress->sin_addr);
        _portNumber = [sender port];
        
        //NSLog(@"IP address: %s", _ipAddress);
        //NSLog(@"Port number: %i", _portNumber);
        
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_services count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier"];
    
    //Device *device = [_devices objectAtIndex:indexPath.row];
    NSNetService *service = [_services objectAtIndex:indexPath.row];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"identifier"];
    }
    
    cell.textLabel.text = service.name;
    
    for (NSData *address in [service addresses])
    {
        struct sockaddr_in *socketAddress = (struct sockaddr_in *) [address bytes];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%s", inet_ntoa(socketAddress->sin_addr)];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNetService *service = [_services objectAtIndex:indexPath.row];
    
    ViewController *viewController = [[ViewController alloc] initWithService:service];
    
    [self.navigationController pushViewController:viewController animated:true];
}

@end
