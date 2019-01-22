//
//  CHTViewController.m
//  Sample
//
//  Created by Nelson Tai on 2013/10/31.
//  Copyright (c) 2013年 Nelson Tai. All rights reserved.
//

#import "CHTViewController.h"

@interface CHTViewController ()
@property (nonatomic, strong) CHTStickerView *selectedView;
@end

@implementation CHTViewController

- (void)setSelectedView:(CHTStickerView *)selectedView {
    if (_selectedView != selectedView) {
        if (_selectedView) {
            _selectedView.showEditingHandlers = NO;
        }
        _selectedView = selectedView;
        if (_selectedView) {
            _selectedView.showEditingHandlers = YES;
            [_selectedView.superview bringSubviewToFront:_selectedView];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
    testView.backgroundColor = [UIColor redColor];
    
    CHTStickerView *stickerView = [[CHTStickerView alloc] initWithContentView:testView];
    stickerView.center = self.view.center;
    stickerView.delegate = self;
    stickerView.outlineBorderColor = [UIColor blueColor];
    [stickerView setImage:[UIImage imageNamed:@"close"] forHandler:CHTStickerViewHandlerClose];
    [stickerView setImage:[UIImage imageNamed:@"rotate"] forHandler:CHTStickerViewHandlerRotate];
    [stickerView setImage:[UIImage imageNamed:@"flip"] forHandler:CHTStickerViewHandlerFlip];
    [stickerView setHandlerSize:40];
    [self.view addSubview:stickerView];
    
    UILabel *textLabel = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    textLabel.text = @"人体中99%的钙质存在骨骼牙齿中，支持人体的运动和咀嚼能力。体内缺钙，会影响身体成长，导致神经性偏头痛、烦躁不安、失眠，还会出现肌肉痉挛的症状。经常盐酸背痛、血糖低或者常饮用碳酸饮料的人群需要补钙。补钙的最佳方式多在日常饮食中选择天然的食物，如牛奶和豆制品，其钙含量绝对能够满足一个人的需要。";
    textLabel.textAlignment = NSTextAlignmentCenter;
    
    CHTStickerView *stickerView2 = [[CHTStickerView alloc] initWithContentView:textLabel];
    stickerView2.center = CGPointMake(100, 100);
    stickerView2.delegate = self;
    [stickerView2 setImage:[UIImage imageNamed:@"close"] forHandler:CHTStickerViewHandlerClose];
    [stickerView2 setImage:[UIImage imageNamed:@"rotate"] forHandler:CHTStickerViewHandlerRotate];
    [stickerView2 setImage:[UIImage imageNamed:@"flip"] forHandler:CHTStickerViewHandlerFlip];
    stickerView2.showEditingHandlers = NO;
    [self.view addSubview:stickerView2];
    
    self.selectedView = stickerView;
}

- (void)stickerViewDidBeginMoving:(CHTStickerView *)stickerView {
    self.selectedView = stickerView;
}

- (void)stickerViewDidTap:(CHTStickerView *)stickerView {
    self.selectedView = stickerView;
}

@end
