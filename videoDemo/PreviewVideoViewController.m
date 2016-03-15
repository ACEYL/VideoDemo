//
//  PreviewVideoViewController.m
//  videoDemo
//
//  Created by Yuan on 16/3/11.
//  Copyright © 2016年 Ace. All rights reserved.
//

#import "PreviewVideoViewController.h"
#import "MBProgressHUD.h"
#import "VideoPlayerView.h"
#import "VideoProgressView.h"
@interface PreviewVideoViewController ()

@property (strong,nonatomic) VideoPlayerView *playerView;
@property (strong,nonatomic) VideoProgressView *progressView;
/** 计时器 */
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation PreviewVideoViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}


//直播视频底层View

-(void)setupDownView
{
    _playerView = [[VideoPlayerView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width) playerWithUrl:self.stream_url];
    [self.view addSubview:_playerView];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //创建底层
    [self setupDownView];
    //注册KVO和通知中心
    [self registMonitor];
    //Player
    [self initStreamPlayer];
    
    //progressView
    [self setupProgress];
    
    //nextstepBtn
    [self setupNextStepBtn];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
}

-(void)initStreamPlayer
{
    [self.playerView.player play];
    [MBProgressHUD showHUDAddedTo:_playerView animated:NO];
}

-(void)setupProgress
{
    _progressView = [[VideoProgressView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.width - 20, self.view.frame.size.width, 20)];
    [self.view addSubview:_progressView];
    [self addProgressObserver];
    // slider开始滑动事件
    [self.progressView.slider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    // slider滑动中事件
    [self.progressView.slider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    // slider结束滑动事件
    [self.progressView.slider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
}

-(void)setupNextStepBtn
{
    
}

-(void)addProgressObserver{
    
    AVPlayerItem *playerItem=self.playerView.player.currentItem;
    UIProgressView *progress=self.progressView.progress;
    UISlider *slider = self.progressView.slider;
    UILabel *currentLabel = self.progressView.currentLabel;
    UILabel *totalLabel = self.progressView.totalLabel;
    //这里设置每秒执行一次
    [self.playerView.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current=CMTimeGetSeconds(time);
        float total=CMTimeGetSeconds([playerItem duration]);
        //当前时长进度progress
        NSInteger proMin = (NSInteger)CMTimeGetSeconds([self.playerView.player currentTime]) / 60;//当前秒
        NSInteger proSec = (NSInteger)CMTimeGetSeconds([self.playerView.player currentTime]) % 60;//当前分钟
        
        //duration 总时长
        NSInteger durMin = (NSInteger)self.playerView.playerItem.duration.value / self.playerView.playerItem.duration.timescale / 60;//总秒
        NSInteger durSec = (NSInteger)self.playerView.playerItem.duration.value / self.playerView.playerItem.duration.timescale % 60;//总分钟
        
        currentLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
        totalLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
        
        
        if (current) {
            [progress setProgress:(current/total) animated:YES];
            
            slider.maximumValue = 1;//音乐总共时长
            slider.value        = CMTimeGetSeconds([playerItem currentTime]) / (playerItem.duration.value / playerItem.duration.timescale);//当前进度
        }
    }];
}

#pragma mark - slider事件

// slider开始滑动事件
- (void)progressSliderTouchBegan:(UISlider *)slider
{

}

// slider滑动中事件
- (void)progressSliderValueChanged:(UISlider *)slider
{
    
    UILabel *currentLabel = self.progressView.currentLabel;
    UILabel *totalLabel = self.progressView.totalLabel;
    //拖动改变视频播放进度
    if (self.playerView.player.status == AVPlayerStatusReadyToPlay) {
        
        [self.playerView.player pause];
        //计算出拖动的当前秒数
        CGFloat total                       = (CGFloat)self.playerView.playerItem.duration.value / self.playerView.playerItem.duration.timescale;
        
        NSInteger dragedSeconds             = floorf(total * slider.value);
        
        //转换成CMTime才能给player来控制播放进度
        
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
        // 拖拽的时长
        NSInteger proMin = (NSInteger)CMTimeGetSeconds(dragedCMTime) / 60;//当前秒
        NSInteger proSec = (NSInteger)CMTimeGetSeconds(dragedCMTime) % 60;//当前分钟
        
        //duration 总时长
        NSInteger durMin = (NSInteger)total / 60;//总秒
        NSInteger durSec = (NSInteger)total % 60;//总分钟
        
        currentLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
        totalLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
        
    }
}

// slider结束滑动事件
- (void)progressSliderTouchEnded:(UISlider *)slider
{
    //计算出拖动的当前秒数
    CGFloat total = (CGFloat)self.playerView.playerItem.duration.value / self.playerView.playerItem.duration.timescale;
    
    NSInteger dragedSeconds = floorf(total * slider.value);
    
    //转换成CMTime才能给player来控制播放进度
    
    CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
    
    [self endSlideTheVideo:dragedCMTime];


}

// 滑动结束视频跳转
- (void)endSlideTheVideo:(CMTime)dragedCMTime
{
    //[_player pause];
    [self.playerView.player seekToTime:dragedCMTime completionHandler:^(BOOL finish){
        
        [self.playerView.player play];
        
    }];
}

#pragma 注册监听
-(void) registMonitor
{
    [self.playerView.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监听直播流突然中断
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoConnectLeaveOff) name:AVPlayerItemPlaybackStalledNotification object:self.playerView.playerItem];
}


//直播中断
-(void)videoConnectLeaveOff
{
    [MBProgressHUD showHUDAddedTo:_playerView animated:YES];
}

//KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        
        if ([playerItem status] == AVPlayerItemStatusUnknown) {
            
            NSLog(@"直播的有问题");
            
        }else if([playerItem status] == AVPlayerItemStatusReadyToPlay){
            [MBProgressHUD hideAllHUDsForView:_playerView animated:YES];
        }
    }
}

//释放
-(void)dealloc
{
    [self.playerView.playerItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self.playerView.playerItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
