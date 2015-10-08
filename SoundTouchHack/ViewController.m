#include <arpa/inet.h>

#import "SRWebSocket.h"
#import "ViewController.h"
#import "XmlParser.h"

@interface ViewController () <SRWebSocketDelegate>
{
    MainView *_mainView;
}
@end

@implementation ViewController
{
    SRWebSocket *_webSocket;
}

- (id)initWithService:(NSNetService *)service
{
    self = [super init];
    
    if (self)
    {
        _service = service;
        
        
        self.title = _service.name;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        
        for (NSData *address in [_service addresses]) {
            struct sockaddr_in *socketAddress = (struct sockaddr_in *) [address bytes];
            
            _ipAddress = inet_ntoa(socketAddress->sin_addr);
            _portNumber = _service.port;
            
            [self getVolume];
        }
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self connectWithWebSocket];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    
    _webSocket.delegate = nil;
    
    [_webSocket close];
    
    _webSocket = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private methods

- (void)getVolume
{
    NSString *urlString = [NSString stringWithFormat:@"http://%s:%i/volume", _ipAddress, (int)_portNumber];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if ([data length] > 0 && error == nil)
            [self fetchedVolume:data];
    }] resume];
}

- (void)fetchedVolume:(NSData *)data
{
    XmlParser *parser = [[XmlParser alloc] init];
    
    int volume = [parser parseXml:data];
    
    NSLog(@"Volume fetched from API: %d", volume);
    
    [_mainView setVolume:volume];
}

- (void)setVolume:(int)volume
{
    NSString *post = [NSString stringWithFormat:@"<volume>%d</volume>", volume];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    NSString *urlString = [NSString stringWithFormat:@"http://%s:%i/volume", _ipAddress, (int)_portNumber];
    
    //NSLog(@"URL string: %@", urlString);
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:YES];
    
    /*
    if (connection)
        NSLog(@"Command sent successfully");
    else
        NSLog(@"Sending command failed");
    */
}

- (void)updateInfo
{
    for (NSData *address in [_service addresses]) {
        struct sockaddr_in *socketAddress = (struct sockaddr_in *) [address bytes];
        
        _ipAddress = inet_ntoa(socketAddress->sin_addr);
        _portNumber = _service.port;
        
        [_mainView setLabel:[NSString stringWithFormat:@"SoundTouch device:\n%@\n\nIP address: %s\nPort number: %i", [_service name], _ipAddress, (int)_portNumber]];
    }
}

- (void)connectWithWebSocket;
{
    NSString *urlString = [NSString stringWithFormat:@"ws://%s:8080", _ipAddress];
    
    
    _webSocket.delegate = nil;
    
    [_webSocket close];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    [request setValue:@"gabbo" forHTTPHeaderField:@"Sec-WebSocket-Protocol"];
    
    
    _webSocket = [[SRWebSocket alloc] initWithURLRequest: request];
    
    _webSocket.delegate = self;
    
    
    [_webSocket open];
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
    
    //NSLog(@"Web socket did open");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    //NSLog(@"Web socket didFailWithError: %@", error.description);
    
    [self connectWithWebSocket];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    //NSLog(@"Web socket did close");
    
    //NSLog(@"Web socket didCloseWithCode: %d - %@ - %@", code, reason, wasClean);
    
    [self connectWithWebSocket];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    //NSLog(@"Web socket didReceiveMessage: %@", message);
    
    XmlParser *parser = [[XmlParser alloc] init];
    
    int volume = [parser parseXml:[message dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"Volume fetched from socket: %d", volume);
    
    if (volume>0)
        [_mainView setVolume:volume];
    
    //self.messagesTextView.text = [NSString stringWithFormat:@"%@\n%@", self.messagesTextView.text, message];
}

@end
