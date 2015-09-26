#import <Foundation/Foundation.h>

@interface XmlParser : NSObject <NSXMLParserDelegate>
{
    NSXMLParser *xmlParser;
    
    NSString *_string;
    
    int _volume;
}

- (int)parseXml:(NSData *)xml;

@end
