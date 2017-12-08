//
//  WKPhotoPreviewController.h
//  photosFrame
//
//  Created by wk on 2017/11/27.
//  Copyright © 2017年 wk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WKPhotosModel;
@interface WKPhotoPreviewController : UIViewController

@property(nonatomic, strong)WKPhotosModel *photoModel;
@property(nonatomic, strong)NSMutableArray <WKPhotosModel *>*selectPhotos;
@property(nonatomic, assign)NSInteger index;
@property(nonatomic, strong)NSArray *assets;//某个相册里面的元素，object is PHAsset or ALAsset
@end
