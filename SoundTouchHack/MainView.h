#import <UIKit/UIKit.h>

@protocol MainViewDelegate <NSObject>

- (void)volume:(int)volume;

@end

@interface MainView : UIView
{
    UILabel *_infoLabel;
    
    UISlider *_slider;
    
    id<MainViewDelegate> _delegate;
}

@property (nonatomic, strong) id<MainViewDelegate> delegate;

- (void)setLabel:(NSString *)string;
- (void)setVolume:(int)volume;

@end
