//
//  ViewController.m
//  SoundTouchHack
//
//  Created by Jürgen De Beckker on 26/09/15.
//  Copyright © 2015 Ice Design. All rights reserved.
//

#import "ViewController.h"

#import "MainView.h"

@interface ViewController ()
{
    MainView *_mainView;
}

@end

@implementation ViewController

- (void)loadView
{
    CGRect frame = [UIScreen mainScreen].bounds;
    
    _mainView = [[MainView alloc] initWithFrame:frame];
    
    self.view = _mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
