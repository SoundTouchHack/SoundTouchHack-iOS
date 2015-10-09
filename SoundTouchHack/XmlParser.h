#import <Foundation/Foundation.h>

@interface XmlParser : NSObject <NSXMLParserDelegate>
{
    NSXMLParser *xmlParser;
    
    NSString *_string;
    
    int _volume;
    NSString *_nowPlaying;
}

- (int)parseXml:(NSData *)webData;
- (NSString *)parseNowPlayingXml:(NSData *)webData;

@end
