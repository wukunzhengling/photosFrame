//
//  WKPhtotosManager.h
//  photosFrame
//
//  Created by wk on 2017/11/14.
//  Copyright © 2017年 wk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WKAlbumModel, AVPlayerItem;
@interface WKPhtotosManager : NSObject

+ (instancetype)shareManager;

/**
 返回相册的访问权限
 PHAuthorizationStatusNotDetermined 此应用程序没有权限访问照片数据。
 PHAuthorizationStatusRestricted 用户不能更改此应用程序的状态，可能是由于诸如家长控件之类的活动限制导致的
 PHAuthorizationStatusDenied 用户已明确拒绝此应用程序对照片数据的访问
 PHAuthorizationStatusAuthorized 授权
 @return nil
 */
+ (NSInteger)authorizationStatus;

//返回YES如果得到了授权
- (BOOL)authorizationStatusAuthorized;


/**
 返回相册

 @param allowPickVideo 允许显示视频
 @param allowPickImage 允许显示图片
 @param completeBlock 返回一个WKAlbumModel
 */
- (void)getAllAlbumsCameraRollAlbum:(BOOL)allowPickVideo allowPickImage:(BOOL)allowPickImage completeBlock:(void(^)(NSArray *models))completeBlock;

/**
 返回相册的照片数组

 @param result PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset>
 @param completeBlock 照片数组 object is PHAsset or ALAsset
 */
- (void)getAlbumPhotos:(id)result completeBlock:(void(^)(NSArray *photos))completeBlock;

//获取图片封面
- (void)getPostImageWithAsset:(WKAlbumModel *)model completion:(void (^)(UIImage *))completion;

//从asset获取图片 asset is is PHAsset or ALAsset
- (void)getPostImageWithAsset:(id)asset original:(BOOL)original completion:(void (^)(UIImage *))completion;

/**
 视频时长的转换

 @param duration duration
 @return 时长
 */
- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration;


/**
 获取一组照片的大小

 @param photos WKPhotosModels
 @param completionBlock bytes
 */
- (void)getBytesPhotos:(NSArray *)photos completion:(void(^)(NSString *bytes))completionBlock;


/**
 获取相册中视频数据

 @param asset PHAsset or ALAsset
 @param completionBlock nil
 */
- (void)getPhotoVideoWith:(id)asset completion:(void(^)(AVPlayerItem *playerItem, NSDictionary *info))completionBlock;
@end
