//
//  WKPhotoCell.m
//  photosFrame
//
//  Created by wk on 2017/11/17.
//  Copyright © 2017年 wk. All rights reserved.
//

#import "WKPhotoCell.h"
#import "WKPhtotosManager.h"
#import "WKAlbumModel.h"

@interface WKPhotoCell()
@property (strong, nonatomic) UIImageView *imageView;       //照片
@property (strong, nonatomic) UIImageView *selectImageView;
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UILabel *timeLength;

@property (nonatomic, strong) UIImageView *videoImgView;

@end

@implementation WKPhotoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    return self;
}
- (void)setUpUI
{
//    self.contentView.backgroundColor = [uici];
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.selectImageView];
    [self.contentView addSubview:self.bottomView];
    [self.bottomView addSubview:self.timeLength];
    [self.bottomView addSubview:self.videoImgView];
    [self.contentView addSubview:self.selectPhotoButton];
}
- (void)setModel:(WKPhotosModel *)model
{
    _model = model;
    [[WKPhtotosManager shareManager] getPostImageWithAsset:model.asset original:YES completion:^(UIImage *image) {
        self.imageView.image = image;
    }];
    if (model.mediaType == WKMediaTypePhoto) {
        _videoImgView.hidden = YES;
        _timeLength.hidden = YES;
        _bottomView.hidden = YES;
    }else{
        _selectImageView.hidden = YES;
        _selectPhotoButton.hidden = YES;
        _videoImgView.hidden = NO;
        _timeLength.hidden = NO;
        _bottomView.hidden = NO;
        _timeLength.text =  [[WKPhtotosManager shareManager] getNewTimeFromDurationSecond:[model.dureTime longLongValue]];
    }
    
}

- (UIButton *)selectPhotoButton {
    if (_selectPhotoButton == nil) {
        UIButton *selectPhotoButton = [[UIButton alloc] init];
        selectPhotoButton.frame = CGRectMake(self.frame.size.width - 44, 0, 44, 44);
        _selectPhotoButton = selectPhotoButton;
        [_selectPhotoButton addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectPhotoButton;
}
- (void)selectPhotoButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    sender.selected ? (_selectImageView.image = [UIImage imageNamed:@"photo.bundle/photo_sel_photoPickerVc"]) : (_selectImageView.image =  [UIImage imageNamed:@"photo.bundle/photo_def_photoPickerVc"]);
    if (self.selectedBlock) {
        self.selectedBlock(sender.selected);
    }
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        _imageView = imageView;
        
        [self.contentView bringSubviewToFront:_selectImageView];
        [self.contentView bringSubviewToFront:_bottomView];
    }
    return _imageView;
}

- (UIImageView *)selectImageView {
    if (_selectImageView == nil) {
        UIImageView *selectImageView = [[UIImageView alloc] init];
        selectImageView.frame = CGRectMake(self.frame.size.width - 27, 0, 27, 27);
        UIImage *image = [UIImage imageNamed:@"photo.bundle/photo_def_photoPickerVc.png"];
        selectImageView.image = image;
        selectImageView.userInteractionEnabled = NO;
        _selectImageView = selectImageView;
    }
    return _selectImageView;
}

- (UIView *)bottomView {
    if (_bottomView == nil) {
        UIView *bottomView = [[UIView alloc] init];
        bottomView.frame = CGRectMake(0, self.frame.size.height - 17, self.frame.size.width, 17);
        static NSInteger rgb = 0;
        bottomView.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.8];
        _bottomView = bottomView;
    }
    return _bottomView;
}

- (UIImageView *)videoImgView {
    if (_videoImgView == nil) {
        UIImageView *videoImgView = [[UIImageView alloc] init];
        videoImgView.frame = CGRectMake(8, 0, 17, 17);
        videoImgView.image = [UIImage imageNamed:@"photo.bundle/VideoSendIcon.png"];
        _videoImgView = videoImgView;
    }
    return _videoImgView;
}

- (UILabel *)timeLength {
    if (_timeLength == nil) {
        UILabel *timeLength = [[UILabel alloc] init];
        timeLength.font = [UIFont boldSystemFontOfSize:11];
        _timeLength.backgroundColor = [UIColor blueColor];
        CGFloat x = self.videoImgView.frame.origin.x + self.videoImgView.frame.size.width;
        timeLength.frame = CGRectMake(x, 0, self.frame.size.width - x - 5, 17);
        timeLength.textColor = [UIColor whiteColor];
        timeLength.textAlignment = NSTextAlignmentRight;
        _timeLength = timeLength;
    }
    return _timeLength;
}
@end
