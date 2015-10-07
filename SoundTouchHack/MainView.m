#import "MainView.h"

#define MARGIN 50

@implementation MainView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        
        _infoLabel = [[UILabel alloc] init];
        
        _infoLabel.numberOfLines = 20;
        _infoLabel.font = [UIFont systemFontOfSize:12];
        _infoLabel.text = @"App loaded";
        
        [self addSubview:_infoLabel];
        
        
        _slider = [[UISlider alloc] init];
        
        _slider.minimumValue = 0;
        _slider.maximumValue = 100;
        _slider.continuous = NO;
        
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:_slider];
    }
    
    return self;
}

#pragma mark - Private methods

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    
    int y = MARGIN;
    
    int maxLabelWidth = size.width-2*MARGIN;
    
    CGRect infoRect = [_infoLabel.text boundingRectWithSize:CGSizeMake(maxLabelWidth, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_infoLabel.font} context:nil];
    
    _infoLabel.frame = CGRectMake(MARGIN, y, infoRect.size.width, infoRect.size.height);
    
    
    y+= infoRect.size.height+MARGIN;
    
    
    _slider.frame = CGRectMake(MARGIN, y, size.width-2*MARGIN, 15);
}

- (void)sliderValueChanged:(UISlider *)sender
{
    //NSLog(@"Slider value: %f", sender.value);
    
    [_delegate volume:sender.value];
}

#pragma mark - Public methods

- (void)setLabel:(NSString *)string
{
    _infoLabel.text = string;
    
    [self setNeedsLayout];
}

- (void)setVolume:(int)volume
{
    //NSLog(@"Set slider value: %d", volume);
    
    [_slider setValue:volume animated:NO];
}

@end