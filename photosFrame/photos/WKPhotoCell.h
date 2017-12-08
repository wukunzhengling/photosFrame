//
//  WKPhotoCell.h
//  photosFrame
//
//  Created by wk on 2017/11/17.
//  Copyright © 2017年 wk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WKPhotosModel;
@interface WKPhotoCell : UICollectionViewCell

@property (strong, nonatomic) UIButton *selectPhotoButton;
@property(nonatomic, strong)WKPhotosModel *model;

@property(nonatomic, copy) void(^selectedBlock)(BOOL isSelected);
@end
