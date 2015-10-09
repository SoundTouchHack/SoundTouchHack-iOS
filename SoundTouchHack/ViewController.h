#import <UIKit/UIKit.h>

#import "MainView.h"

@interface ViewController : UIViewController<MainViewDelegate>
{
    NSNetServiceBrowser *_browser;
    
    NSNetService *_service;
    
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
    
    NSString *_macAddress;
    char *_ipAddress;
    NSInteger _portNumber;
    
    NSString *_nowPlaying;
}

- (id)initWithService:(NSNetService *)service;

@end

