//
//  WKTestCollectionViewCell.h
//  photosFrame
//
//  Created by wk on 2017/11/11.
//  Copyright © 2017年 wk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WKTestCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *videoImageView;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UILabel *gifLable;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, strong) id asset;

@end
