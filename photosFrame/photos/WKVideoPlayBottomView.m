//
//  WKVideoPlayBottomView.m
//  photosFrame
//
//  Created by wk on 2017/12/7.
//  Copyright © 2017年 wk. All rights reserved.
//

#import "WKVideoPlayBottomView.h"

@implementation WKVideoPlayBottomView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.btnPlayOrPause addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoSlider addTarget:self action:@selector(sliderMoveEventChange:) forControlEvents:UIControlEventValueChanged];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [self.videoSlider addGestureRecognizer:tap];
    
}

- (void)playOrPause:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(btnPlayOrPauseClick:)]) {
        [_delegate btnPlayOrPauseClick:sender];
    }
}

- (void)sliderMoveEventChange:(UISlider *)slider
{
    if (_delegate && [_delegate respondsToSelector:@selector(sliderMoveChangeEvent:)]) {
        [_delegate sliderMoveChangeEvent:slider];
    }
}
- (void)tap:(UITapGestureRecognizer *)tap
{
    if (_delegate && [_delegate respondsToSelector:@selector(sliderTap:)]) {
        [_delegate sliderTap:tap];
    }
}
@end
