//
//  XDSPlayerView.m
//  XDSPhotoBrowser
//
//  Created by Hmily on 2018/8/22.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSPlayerView.h"
#import "XDSGestureDetectingImageView.h"
#import "UIViewController+XDSMediaBrowser.h"

#import "XDSFullPlayerVC.h"
@interface XDSPlayerView () <XDSGestureDetectingImageViewDelegate>
@property (strong, nonatomic)AVPlayer *myPlayer;//播放器
@property (strong, nonatomic)AVPlayerItem *item;//播放单元
@property (strong, nonatomic)AVPlayerLayer *playerLayer;//播放界面（layer）


@property (nonatomic,strong) NSTimer *mTimer;//用来跟踪播放进度
@property (nonatomic,assign) XDSPlayerViewPlayStatus playStatus;//记录最后一次消失时的播放转态

@property (nonatomic,strong) XDSGestureDetectingImageView *gestureDetectingView;
@property (strong, nonatomic)UISlider *avSlider;//用来现实视频的播放进度，并且通过它来控制视频的快进快退。
@property (nonatomic,strong) UIButton *playButton;//播放按钮
@property (nonatomic,strong) UIView *containerView;//用来容纳时间，进度条，声音开关，全屏按钮等
@property (nonatomic,strong) UIButton *volumeButton;//音量开关
@property (nonatomic,strong) UIButton *fullScreenButton;//全屏按钮
@property (nonatomic,strong) UILabel *currentTimeLabel;//当前时间
@property (nonatomic,strong) UILabel *durationTimeLabel;//视频时长

@property (nonatomic,strong) UILabel *errorLabel;//用于显示该视频无法播放
@property (nonatomic,strong) UIActivityIndicatorView *loadingView;//视频加载提示器

@end


static NSInteger PlayerUIHiddenTimeInterval = 0;

@implementation XDSPlayerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createPlayerUI];
    }
    return self;
}

- (void)createPlayer {
    self.gestureDetectingView.hidden = YES;
    self.errorLabel.hidden = YES;
    [self.loadingView startAnimating];
    
    self.playStatus = XDSPlayerViewPlayStatusLoaing;
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    NSURL *videoURL = self.mediaModel.mediaURL;
    self.item = [AVPlayerItem playerItemWithURL:videoURL];
    _myPlayer = [AVPlayer playerWithPlayerItem:self.item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_myPlayer];
    self.playerLayer.frame = self.bounds;
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    
    //通过KVO来观察status属性的变化，来获得播放之前的错误信息
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    //程序进入前后台监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerAppear) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDisappear) name:UIApplicationDidEnterBackgroundNotification object:nil];
    //添加播放结束监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
}
- (void)createPlayerUI {
    self.gestureDetectingView = [[XDSGestureDetectingImageView alloc] initWithFrame:self.bounds];
    self.gestureDetectingView.gDelegate = self;
    [self addSubview:self.gestureDetectingView];
    
    self.errorLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
        label.textColor = [UIColor lightTextColor];
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 1;
        label.text = @"阿哦，该视频无法播放哦~";
        label.hidden = YES;
        [self addSubview:label];
        label;
    });
    
    self.loadingView = ({
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        [self addSubview:activityIndicator];
        //设置小菊花的frame
        activityIndicator.frame= self.bounds;
        //设置小菊花颜色
        activityIndicator.color = [UIColor redColor];
        //刚进入这个界面会显示控件，并且停止旋转也会显示，只是没有在转动而已，没有设置或者设置为YES的时候，刚进入页面不会显示
        activityIndicator.hidesWhenStopped = YES;
        activityIndicator;
    });
    
    
    self.playButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 55, 55);
        button.center = self.center;
        [button setImage:[UIImage imageNamed:@"btn_stop"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(playButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.gestureDetectingView addSubview:button];
        button;
    });

    
    self.containerView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.2];
        [self.gestureDetectingView addSubview:view];
        view;
    });
    
    self.avSlider = ({
        UISlider *slider = [[UISlider alloc]initWithFrame:CGRectZero];
        slider.maximumTrackTintColor = [UIColor whiteColor];
        slider.minimumTrackTintColor = [UIColor redColor];
        [slider setThumbImage:[UIImage imageNamed:@"img_circular"] forState:UIControlStateNormal];
        [self.containerView addSubview:slider];
        [slider addTarget:self action:@selector(avSliderAction) forControlEvents:
         UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
        slider;
    });
    
    self.currentTimeLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:11];
        label.numberOfLines = 1;
        label.text = @"--:--";
        label.textAlignment = NSTextAlignmentCenter;
        [self.containerView addSubview:label];
        label;
    });
    
    self.durationTimeLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:11];
        label.text = @"--:--";
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 1;
        [self.containerView addSubview:label];
        label;
    });
    
    self.volumeButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectZero;
        button.center = self.center;
        [button setImage:[UIImage imageNamed:@"btn_voice_disabled"] forState:UIControlStateSelected];
        [button setImage:[UIImage imageNamed:@"btn_voice"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(volumeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:button];
        button;
    });
    
    self.fullScreenButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectZero;
        button.center = self.center;
        [button setImage:[UIImage imageNamed:@"btn-amplification"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(fullScreenButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:button];
        button;
    });
    [self updateFrames];
    self.gestureDetectingView.hidden = YES;//player创建之前隐藏各种按钮
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateFrames];
}

- (void)updateFrames {
    
    
    self.gestureDetectingView.frame = self.bounds;
    self.playButton.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    self.playerLayer.frame = self.bounds;
    
    CGFloat contaiterHeight = 40;
    CGFloat containerWidth = CGRectGetWidth(self.bounds);
    self.containerView.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - contaiterHeight, containerWidth, contaiterHeight);
    CGFloat marginLeft = 10.f;
    CGFloat height = contaiterHeight;
    CGFloat width = containerWidth;

    CGRect frame = CGRectZero;
    CGPoint center = CGPointMake(0, height/2);

    //currentTimeLabel
    CGFloat labelWidth = 40.f;
    frame.size = CGSizeMake(labelWidth, height);
    center.x = marginLeft + labelWidth/2;
    self.currentTimeLabel.frame = frame;
    self.currentTimeLabel.center = center;

    //fullScreenButton
    CGFloat buttonWidth = 35.f;
    frame.size = CGSizeMake(buttonWidth, buttonWidth);
    center.x = width - marginLeft - buttonWidth/2;
    self.fullScreenButton.frame = frame;
    self.fullScreenButton.center = center;

    //volumeButton
    frame.size = CGSizeMake(buttonWidth, buttonWidth);
    center.x = CGRectGetMinX(self.fullScreenButton.frame) - buttonWidth/2;
    self.volumeButton.frame = frame;
    self.volumeButton.center = center;

    //durationTimeLabel
    frame = self.currentTimeLabel.frame;
    center.x = CGRectGetMinX(self.volumeButton.frame) - labelWidth/2;
    self.durationTimeLabel.frame = frame;
    self.durationTimeLabel.center = center;

    frame.size = CGSizeMake(CGRectGetMinX(self.durationTimeLabel.frame) - CGRectGetMaxX(self.currentTimeLabel.frame) , height);
    frame.origin = CGPointMake(CGRectGetMaxX(self.currentTimeLabel.frame), 0);
    self.avSlider.frame = frame;
}

- (void)showButtons {
    self.playButton.hidden = NO;
    self.containerView.hidden = NO;
}
- (void)hideButtons {
    self.playButton.hidden = YES;
    self.containerView.hidden = YES;
}

- (void)playButtonClick:(UIButton *)playButton{
    switch (self.playStatus) {
        case XDSPlayerViewPlayStatusReadyToPlay:
        case XDSPlayerViewPlayStatusPlaying:
        case XDSPlayerViewPlayStatusPause:
        case XDSPlayerViewPlayStatusEnd:{
            playButton.selected = !playButton.selected;
            if (self.playButton.selected == YES) {
                [self.myPlayer play];
                [self startTimer];
            }else {
                [self.myPlayer pause];
                self.gestureDetectingView.hidden = NO;
                [self stopTimer];
            }
            
            _playStatus = playButton.isSelected?XDSPlayerViewPlayStatusPlaying:XDSPlayerViewPlayStatusPause;
        }
            
        default:
            break;
    }
}
- (void)volumeButtonClick:(UIButton *)volumeButton {
    volumeButton.selected = !volumeButton.selected;
    self.myPlayer.volume = volumeButton.selected?0.f:5.f;
    [self restartTimer];
}

- (void)fullScreenButtonClick:(UIButton *)fullScreenButton {
    NSLog(@"全屏播放");

    [self hideButtons];
    [self restartTimer];
    [[NSNotificationCenter defaultCenter] postNotificationName:kXDSPlayerViewNotificationNameFullScreen object:nil];
    
    XDSFullPlayerVC *fullVC = [[XDSFullPlayerVC alloc] init];
    fullVC.playerView = self;
    [self.viewController presentViewController:fullVC translucent:YES animated:NO completion:nil];

}


- (void)restartTimer {
    if (_mTimer) {
        [self startTimer];
    }
}
- (void)startTimer {
    [self stopTimer];
    PlayerUIHiddenTimeInterval = 0;
    self.mTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                   target:self
                                                 selector:@selector(timer)
                                                 userInfo:nil
                                                  repeats:YES];
}
- (void)stopTimer {
    [self.mTimer invalidate];
    self.mTimer = nil;
}

- (void)avSliderAction{
    [self stopTimer];
    [self.myPlayer pause];
    //slider的value值为视频的时间
    float seconds = self.avSlider.value;
    //让视频从指定的CMTime对象处播放。
    CMTime startTime = CMTimeMakeWithSeconds(seconds, self.item.currentTime.timescale);
    
    NSLog(@"=====%lf", CMTimeGetSeconds(startTime));
    //让视频从指定处播放
    [self.myPlayer seekToTime:startTime completionHandler:^(BOOL finished) {
        if (finished) {
            self.playButton.selected = !self.playButton.selected;
            self.playStatus = XDSPlayerViewPlayStatusReadyToPlay;
            [self playButtonClick:self.playButton];
        }
    }];
    
    [self restartTimer];
}

//监控播放进度方法
- (void)timer {
    NSInteger seconds = CMTimeGetSeconds(self.myPlayer.currentItem.currentTime);
    self.avSlider.value = seconds;
    self.currentTimeLabel.text = [self timeWithSeconds:seconds];
    
    if (self.playButton.hidden == NO) {
        PlayerUIHiddenTimeInterval += 1;
    }
    if (PlayerUIHiddenTimeInterval == 3) {
        [self imageView:nil singleTapDetected:nil];
        PlayerUIHiddenTimeInterval = 0;
    }
}

- (NSString *)timeWithSeconds:(NSInteger)totalSeconds {
    NSInteger seconds = totalSeconds%60;
    NSInteger minutes = (totalSeconds%3600)/60;
    return [NSString stringWithFormat:@"%02ld:%02ld", minutes, seconds];
}

//KVO回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        //取出status的新值
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] intValue];
        switch (status) {
            case AVPlayerItemStatusFailed:
                //NSLog(@"item 有误");
                self.playStatus = XDSPlayerViewPlayStatusError;
                self.errorLabel.hidden = NO;
                [self.loadingView stopAnimating];
                break;
            case AVPlayerItemStatusReadyToPlay:
                //NSLog(@"准好播放了");
                self.gestureDetectingView.hidden = NO;
                self.errorLabel.hidden = YES;
                [self.loadingView stopAnimating];
                self.playStatus = XDSPlayerViewPlayStatusReadyToPlay;
                NSInteger totalSeconds = CMTimeGetSeconds(self.item.duration);
                self.avSlider.maximumValue = totalSeconds;
                self.currentTimeLabel.text = [self timeWithSeconds:0];
                self.durationTimeLabel.text = [self timeWithSeconds:totalSeconds];
                break;
            case AVPlayerItemStatusUnknown:
                self.playStatus = XDSPlayerViewPlayStatusError;
                self.errorLabel.hidden = NO;
                [self.loadingView stopAnimating];
                break;
            default:
                break;
        }
    }
}


#pragma mark - XDSGestureDetectingImageViewDelegate
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch {
    if (self.playButton.selected == NO) {
        [self playButtonClick:self.playButton];
        return;
    }
    if (self.playButton.hidden == YES) {
        self.playButton.hidden = NO;
        self.containerView.hidden = NO;
    }else {
        self.playButton.hidden = YES;
        self.containerView.hidden = YES;
    }
}


- (void)setMediaModel:(XDSMediaModel *)mediaModel {
    if (_mediaModel == mediaModel) {
        return;
    }else {
        _mediaModel = mediaModel;
        [self createPlayer];
        self.volumeButton.selected = NO;
        [self volumeButtonClick:self.volumeButton];//设置静音
    }
}


- (void)playbackFinished {
    //1、修改状态为播放结束
    self.playStatus = XDSPlayerViewPlayStatusEnd;
    
    //2、显示播放控件
    [self imageView:nil singleTapDetected:nil];
    
    //3、暂停播放
    [self playButtonClick:self.playButton];
    
    //4、重置slide
    self.avSlider.value = 0.f;
    
    //5、重置player的播放节点
    [self avSliderAction];
    
}
//player出现或者不显示，控制播放器播放或者暂停
- (void)playerDisappear {
    _playStatusWhenDisappear = self.playStatus;
    if (_playStatusWhenDisappear == XDSPlayerViewPlayStatusPlaying) {
        [self playButtonClick:self.playButton];
    }
}

- (void)playerAppear {
    if (_playStatusWhenDisappear == XDSPlayerViewPlayStatusPlaying) {
        [self playButtonClick:self.playButton];
    }
}

- (void)destroyPlayer {
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    [self.myPlayer pause];
    self.myPlayer = nil;
    //移除监听（观察者）
    [self.item removeObserver:self forKeyPath:@"status"];
    self.item = nil;
    [self stopTimer];
}

- (void)dealloc {
    NSLog(@"==播放器被销毁了==");
}




@end

NSString *const kXDSPlayerViewNotificationNameFullScreen = @"XDSPlayerViewNotificationNameFullScreen";
