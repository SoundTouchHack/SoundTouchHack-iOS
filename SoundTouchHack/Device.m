#import "Device.h"

@implementation Device

@synthesize name = _name;
@synthesize ip = _ip;
@synthesize port = _port;

- (id)initWithName:(NSString *)name ip:(NSString *)ip port:(NSString *)port
{
    if (self = [super init])
    {
        _name = name;
        _ip  = ip;
        _port = port;
    }
    
    return self;
}

@end