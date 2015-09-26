#import "MainView.h"

#define MARGIN 15

@implementation MainView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor redColor];
    }
    
    return self;
}


#pragma mark - Private methods

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    /*CGSize size = self.bounds.size;
    
    int maxLabelWidth = size.width-2*MARGIN;
    
    CGRect infoRect = [_infoLabel.text boundingRectWithSize:CGSizeMake(maxLabelWidth, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_infoLabel.font} context:nil];
    
    _infoLabel.frame = CGRectMake(MARGIN, MARGIN, infoRect.size.width, infoRect.size.height);*/
}

@end