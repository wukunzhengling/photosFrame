//
//  WKTestCollectionViewCell.m
//  photosFrame
//
//  Created by wk on 2017/11/11.
//  Copyright © 2017年 wk. All rights reserved.
//

#import "WKTestCollectionViewCell.h"

@implementation WKTestCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    __weak typeof (self)weakSelf = self;
    UIImageView *imageView = [[UIImageView alloc]init];
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.mas_left).offset(4.0);
        make.right.mas_equalTo(weakSelf.mas_right).offset(-4.0);
        make.top.mas_equalTo(weakSelf.mas_top).offset(4.0);
        make.bottom.mas_equalTo(weakSelf.mas_bottom).offset(-4.0);
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"photo_delete"] forState:UIControlStateNormal];
    [self.contentView addSubview:btn];
    self.deleteBtn = btn;
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(10);
        make.width.mas_equalTo(10);
        make.top.mas_equalTo(weakSelf.mas_top);
        make.right.mas_equalTo(weakSelf.mas_right);
    }];
    
    UILabel *label = [[UILabel alloc]init];
    label.backgroundColor = [UIColor blueColor];
    label.text = @"GIF";
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:10];
    [self.contentView addSubview:label];
    self.gifLable = label;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(20);
        make.width.mas_equalTo(20);
        make.top.mas_equalTo(weakSelf.mas_top);
        make.left.mas_equalTo(weakSelf.mas_left);
    }];
    
}
@end
