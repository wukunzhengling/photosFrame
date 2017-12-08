//
//  WKPhtotosManager.m
//  photosFrame
//
//  Created by wk on 2017/11/14.
//  Copyright © 2017年 wk. All rights reserved.
//

#import "WKPhtotosManager.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "WKAlbumModel.h"

#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)

static WKPhtotosManager *instance_;

@interface WKPhtotosManager ()

@end

@implementation WKPhtotosManager
+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [[WKPhtotosManager alloc]init];
    });
    return instance_;
}

+ (NSInteger)authorizationStatus
{
    if (iOS9Later) {
        return [PHPhotoLibrary authorizationStatus];
    }else{
        return [ALAssetsLibrary authorizationStatus];
    }
}
//返回YES如果得到了授权
- (BOOL)authorizationStatusAuthorized
{
    NSInteger status = [self.class authorizationStatus];
    if (status == 0) {
        [self requestauthorizationStatusWhenNotDetermined];
    }
    
    return status == 3;
}
//AuthorizationStatusNotDetermined 时询问授权弹出系统授权alertView
- (void)requestauthorizationStatusWhenNotDetermined
{
    if (iOS8Later) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                });
            }];
        });
    }else{
        ALAssetsLibrary *assetLibary = [[ALAssetsLibrary alloc]init];
        [assetLibary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
        } failureBlock:^(NSError *error) {
            
        }];
    }
}
//返回所有的相册
- (void)getAllAlbumsCameraRollAlbum:(BOOL)allowPickVideo allowPickImage:(BOOL)allowPickImage completeBlock:(void(^)(NSArray *models))completeBlock
{
   __block NSMutableArray *models = [NSMutableArray array];
    if (iOS8Later) {
        PHFetchOptions *options = [[PHFetchOptions alloc]init];
        if (!allowPickVideo) options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        if (!allowPickImage) options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        
        PHFetchResult<PHAssetCollection *> *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *collection in result) {
            if ([collection isKindOfClass:[PHAssetCollection class]]) {
                PHFetchResult<PHAsset *> *assetResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
                if (assetResult.count < 1)  continue;
                WKAlbumModel *model = [WKAlbumModel albumModelWith:assetResult albumName:collection.localizedTitle];
                [models addObject:model];
            }
        }
        if (completeBlock && models.count) completeBlock(models);
    }else{
        ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc]init];
        [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if ([group numberOfAssets] < 1) return ;
            WKAlbumModel *model = [WKAlbumModel albumModelWith:group albumName:[group valueForProperty:ALAssetsGroupPropertyName]];
            [models addObject:model];
        } failureBlock:nil];
        if (completeBlock && models.count) completeBlock(models);
        
    }
    
}
//获取一个相册中所有的照片
- (void)getAlbumPhotos:(id)result completeBlock:(void(^)(NSArray *photos))completeBlock
{
    __block NSMutableArray *dataPhotos = [NSMutableArray array];
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult<PHAsset *> *tempResult = (PHFetchResult *)result;
        for (PHAsset *asset in tempResult) {
//            [self getPostImageWithAsset:asset original:YES completion:^(UIImage *image) {
//                [dataPhotos addObject:image];
//            }];
            [dataPhotos addObject:asset];
        }
        completeBlock(dataPhotos);
    }else{
        ALAssetsGroup *group = (ALAssetsGroup *)result;
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            
//            [self getPostImageWithAsset:result original:YES completion:^(UIImage *image) {
//                [dataPhotos addObject:image];
//            }];
            [dataPhotos addObject:result];
        }];
        completeBlock(dataPhotos);
    }
}

//从asset获取图片
- (void)getPostImageWithAsset:(id)asset original:(BOOL)original completion:(void (^)(UIImage *))completion
{
    if (iOS8Later) {
        
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *tempAsset = (PHAsset *)asset;
            CGSize size = original ? CGSizeMake(tempAsset.pixelWidth, tempAsset.pixelHeight) : CGSizeZero;
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
            options.resizeMode = PHImageRequestOptionsResizeModeFast;//防止闪存暴增
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
//            options.networkAccessAllowed = YES;//照片选择后如果照片保存在iCloud，获取iCloud的图片文件
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//                [self fixOrientation:result];
                completion(result);
            }];
        }
    }else if ([asset isKindOfClass:[ALAsset class]]){
        ALAsset *tempAsset = (ALAsset *)asset;
        ALAssetRepresentation *represention = [tempAsset defaultRepresentation];
        CGImageRef fullScreenImage = represention.fullScreenImage;
        UIImage *image= [UIImage imageWithCGImage:fullScreenImage];
        completion(image);
        
    }
}

//获取图片封面
- (void)getPostImageWithAsset:(WKAlbumModel *)model completion:(void (^)(UIImage *))completion
{
    if (iOS8Later) {
        id asset = [model.result lastObject];
        [self getPostImageWithAsset:asset original:NO completion:^(UIImage *image) {
            completion(image);
        }];
    }else{
        ALAssetsGroup *group = model.result;
        CGImageRef postImage = group.posterImage;
        UIImage *image = [UIImage imageWithCGImage:postImage];
        completion(image);
    }
}
- (void)getBytesPhotos:(NSArray *)photos completion:(void(^)(NSString *bytes))completionBlock
{
    __block NSInteger dataLenth = 0;
    if (photos.count == 0) return;
    for (int i=0; i<photos.count; i++) {
        WKPhotosModel *model = photos[i];
        if ([model.asset isKindOfClass:[PHAsset class]]) {
            [[PHImageManager defaultManager]requestImageDataForAsset:model.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                dataLenth += imageData.length;
                if (i==photos.count -1) {
                    NSString *bytes =[self getPhotoDataLenth:dataLenth];
                    completionBlock(bytes);
                }
            }];
        }else{
            ALAsset *asset = (ALAsset *)model.asset;
            dataLenth += asset.defaultRepresentation.size;
            if (i==photos.count -1) {
                NSString *bytes =[self getPhotoDataLenth:dataLenth];
                completionBlock(bytes);
            }
        }
    }
    
}

- (void)getPhotoVideoWith:(id)asset completion:(void(^)(AVPlayerItem *playerItem, NSDictionary *info))completionBlock
{
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *tempAsset = (PHAsset *)asset;
        [[PHImageManager defaultManager]requestPlayerItemForVideo:tempAsset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            if(completionBlock) completionBlock(playerItem, info);
        }];
    }else{
        ALAsset *tempAsset = (ALAsset *)asset;
        ALAssetRepresentation *represent = tempAsset.defaultRepresentation;
        NSString *UTI = represent.UTI;
        NSURL  *videoURL = [[tempAsset valueForProperty:ALAssetPropertyURLs] valueForKey:UTI];
        AVPlayerItem *playerItem = [[AVPlayerItem alloc]initWithURL:videoURL];
        if(completionBlock) completionBlock(playerItem, nil);
    }
}


- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration
{
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"0:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"0:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}

- (NSString *)getPhotoDataLenth:(NSInteger)lenth
{
    NSString *bytes;
    if (lenth >= 1024*1024) {
        bytes = [NSString stringWithFormat:@"%0.1fM",lenth/1024.0/1024.0];
    }else{
        bytes = [NSString stringWithFormat:@"%0.0ldk",lenth/1024];
    }
    return bytes;
}
/// 修正图片转向
- (UIImage *)fixOrientation:(UIImage *)aImage {
//    if (!self.shouldFixOrientation) return aImage;
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
@end
