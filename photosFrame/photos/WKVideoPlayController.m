//
//  WKVideoPlayController.m
//  photosFrame
//
//  Created by wk on 2017/12/6.
//  Copyright © 2017年 wk. All rights reserved.
//

#import "WKVideoPlayController.h"
#import "WKPhtotosManager.h"
#import <AVFoundation/AVFoundation.h>
#import "WKVideoPlayBottomView.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "WKAlbumModel.h"

@interface WKVideoPlayController ()<WKVideoPlayBottomViewDelegate>
{
    UIView *_toolBar;
    UIButton *_doneButton;
    
    UIButton * _playButton;
//    WKVideoPlayBottomView *_bottomView;
    WKPhotosModel *_photoVideoModel;
    ;
}
@property(nonatomic, strong)WKVideoPlayBottomView *bottomView;
@property(nonatomic, strong)AVPlayer *player;
@property(nonatomic, strong)id playerObserve;
@end

@implementation WKVideoPlayController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"预览";
    _photoVideoModel = [WKPhotosModel photosModelWith:self.asset albumName:nil];
    [self configVideo];
    
}
- (void)configVideo
{
    __weak typeof(self) weakSelf = self;
    [[WKPhtotosManager shareManager]getPhotoVideoWith:self.asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.player = [AVPlayer playerWithPlayerItem:playerItem];
            AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:weakSelf.player];
            playerLayer.frame = self.view.bounds;
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playVideoFinish) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
            //视频时长大于60秒 则每一秒更新一次，小于则1/30秒更新一次
            CMTime time = [_photoVideoModel.dureTime longLongValue] > 60 ? CMTimeMake(1, 1) : CMTimeMake(1, 30);
            weakSelf.playerObserve= [weakSelf.player addPeriodicTimeObserverForInterval:time queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                double currentTime =  CMTimeGetSeconds(time);
                weakSelf.bottomView.startTimeLabel.text = [[WKPhtotosManager shareManager]getNewTimeFromDurationSecond:currentTime];
                [weakSelf.bottomView.videoSlider setValue:currentTime/ [_photoVideoModel.dureTime  longLongValue]];
            }];
            [weakSelf.view.layer addSublayer:playerLayer];
//            [self configPlayButton];
            [self configBottom];
            [weakSelf.player play];
        });
    }];
}
- (void)configBottom
{
    __weak typeof(self) weakSelf = self;
    static CGFloat rgb = 34 / 255.0;
    /*_toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    
    _toolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.7];
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.frame = CGRectMake(self.view.frame.size.width - 44 - 12, 0, 44, 44);
    [_doneButton setTitle:@"完成" forState:UIControlStateNormal];
    [_doneButton setTitleColor:[UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0] forState:UIControlStateNormal];
    [_doneButton addTarget:self action:@selector(doneButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:_doneButton];
     [self.view addSubview:_toolBar];*/
    
    weakSelf.bottomView = [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([WKVideoPlayBottomView class]) owner:self options:nil]lastObject];
    weakSelf.bottomView.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
    weakSelf.bottomView.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.7];
    weakSelf.bottomView.delegate = self;
    weakSelf.bottomView.startTimeLabel.text = [[WKPhtotosManager shareManager] getNewTimeFromDurationSecond:[_photoVideoModel.dureTime longLongValue]];;
    weakSelf.bottomView.videoTimeLabel.text = [[WKPhtotosManager shareManager] getNewTimeFromDurationSecond:[_photoVideoModel.dureTime longLongValue]];;
    [weakSelf.bottomView.videoSlider setValue:0.0];
    [self.view addSubview:weakSelf.bottomView];
    
}
- (void)sliderMoveChangeEvent:(UISlider *)sender
{
    double currentTime = sender.value *[_photoVideoModel.dureTime longLongValue];
    CMTime time = CMTimeMake(currentTime, 1.0);
    [_player seekToTime:time];
}
- (void)sliderTap:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:_bottomView.videoSlider];
    double currentTime = point.x /_bottomView.videoSlider.frame.size.width *[_photoVideoModel.dureTime longLongValue];
    CMTime time = CMTimeMake(currentTime, 1.0);
    [_player seekToTime:time];
}
- (void)configPlayButton {
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playButton.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64 - 44);
    [_playButton setImage:[UIImage imageNamed:@"photo.bundle/MMVideoPreviewPlay.png"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamed:@"photo.bundle/MMVideoPreviewPlayHL.png"] forState:UIControlStateHighlighted];
    [_playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playButton];
}

- (void)doneButtonClick:(UIButton *)sender
{
    NSLog(@"=======doneButtonClick========");
}
- (void)playButtonClick
{
    NSLog(@"=======doneButtonClick========");
    
}
- (void)playVideoFinish
{
    _playButton.hidden = NO;
    [_player seekToTime:CMTimeMake(0, 1)];
    [_bottomView.btnPlayOrPause setImage:[UIImage imageNamed:@"photo.bundle/btn_video_stop.png"] forState:UIControlStateNormal];
}

#pragma WKVideoPlayBottomViewDelegate
- (void)btnPlayOrPauseClick:(UIButton *)sender
{
    NSLog(@"=======btnPlayOrPauseClick========");
    sender.selected = !sender.selected;
    sender.selected ? [sender setImage:[UIImage imageNamed:@"photo.bundle/btn_video_play.png"] forState:UIControlStateNormal] :
    [sender setImage:[UIImage imageNamed:@"photo.bundle/btn_video_stop.png"] forState:UIControlStateSelected];
    if (sender.selected) {
        [_player pause];
    }else{
        [_player play];
    }
}


- (void)dealloc
{
    [_player removeTimeObserver:_playerObserve];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
