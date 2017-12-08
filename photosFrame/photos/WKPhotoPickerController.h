//
//  WKPhotoPickerController.h
//  photosFrame
//
//  Created by wk on 2017/11/17.
//  Copyright © 2017年 wk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WKAlbumModel;
@interface WKPhotoPickerController : UIViewController
@property(nonatomic, strong)NSArray *assets;//object is PHAsset or ALAsset
@property(nonatomic, strong)WKAlbumModel *albumModel; //相册名字
@end
