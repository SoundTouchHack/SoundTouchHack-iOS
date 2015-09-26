#import "XmlParser.h"

@implementation XmlParser

- (int)parseXml:(NSData *)webData
{
    xmlParser = [[NSXMLParser alloc] initWithData:webData];
	
    [xmlParser setDelegate: self];
	[xmlParser setShouldResolveExternalEntities: YES];
	
    [xmlParser parse];
    
    return _volume;
}

- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
   namespaceURI:(NSString *)namespaceURI 
  qualifiedName:(NSString *)qName 
	 attributes:(NSDictionary *)attributeDict 
{
}

- (void)parser:(NSXMLParser *)parser 
  didEndElement:(NSString *)elementName 
   namespaceURI:(NSString *)namespaceURI 
  qualifiedName:(NSString *)qName 
{
    if( [elementName isEqualToString:@"actualvolume"])
	{
        _volume = [_string intValue];
        
        return;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string 
{
    _string = string;
}

@end
