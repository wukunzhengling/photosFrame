//
//  WKPreviewCollectionCell.h
//  photosFrame
//
//  Created by wk on 2017/11/29.
//  Copyright © 2017年 wk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WKPhotosModel;
@interface WKPreviewCollectionCell : UICollectionViewCell
@property(nonatomic, strong)WKPhotosModel *photoModel;
@property(nonatomic, assign)NSInteger index;//被选中照片的序号
@property(nonatomic, copy)void(^singleTapBlock)(void);
@end
