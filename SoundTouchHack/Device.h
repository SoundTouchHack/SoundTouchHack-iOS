#import <Foundation/Foundation.h>

@interface Device : NSObject
{
	NSString *_name;
	NSString *_ip;
    NSString *_port;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *ip;
@property (nonatomic, copy) NSString *port;

- (id)initWithName:(NSString *)name ip:(NSString *)ip port:(NSString *)port;

@end
