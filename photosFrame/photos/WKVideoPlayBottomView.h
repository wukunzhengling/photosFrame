//
//  WKVideoPlayBottomView.h
//  photosFrame
//
//  Created by wk on 2017/12/7.
//  Copyright © 2017年 wk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WKVideoPlayBottomViewDelegate <NSObject>
- (void)btnPlayOrPauseClick:(UIButton *)sender;
- (void)sliderMoveChangeEvent:(UISlider *)sender;
- (void)sliderTap:(UITapGestureRecognizer *)tap;
@end

@interface WKVideoPlayBottomView : UIView

@property (weak, nonatomic) IBOutlet UIButton *btnPlayOrPause;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *videoSlider;

@property(nonatomic, weak)id <WKVideoPlayBottomViewDelegate> delegate;

@end
