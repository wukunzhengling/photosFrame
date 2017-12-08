//
//  WKAlbumModel.m
//  photosFrame
//
//  Created by wk on 2017/11/15.
//  Copyright © 2017年 wk. All rights reserved.
//

#import "WKAlbumModel.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation WKAlbumModel
+ (instancetype)albumModelWith:(id)result albumName:(NSString *)albumName
{
    WKAlbumModel *model = [[WKAlbumModel alloc]init];
    model.result = result;
    model.name = albumName;
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *phAssetResult = (PHFetchResult *)result;
        model.count = phAssetResult.count;
        
    }else if ([result isKindOfClass:[ALAssetsGroup class]]){
        ALAssetsGroup *phAssetGroup = (ALAssetsGroup *)result;
        model.count = [phAssetGroup numberOfAssets];
    }
    return model;
}
@end

@implementation WKPhotosModel

+ (instancetype)photosModelWith:(id)asset albumName:(NSString *)albumName
{
    WKPhotosModel *model = [[WKPhotosModel alloc]init];
    model.asset = asset;
    if ([asset isKindOfClass:[PHAsset class]]) {
        model.mediaType = WKMediaTypePhoto;
        PHAsset *tempAsset = (PHAsset *)asset;
        if (tempAsset.mediaType == PHAssetMediaTypeVideo) {
            model.dureTime = [NSString stringWithFormat:@"%f", tempAsset.duration];
            model.mediaType = WKMediaTypeVideo;
        }
//        [[PHImageManager defaultManager]requestAVAssetForVideo:tempAsset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
//            NSURL *url = [(AVURLAsset *)asset URL];
//            NSNumber *fileSizeValue = nil;
//            [url getResourceValue:&fileSizeValue forKey:NSURLFileSizeKey error:nil];
//            model.dureTime = [NSString stringWithFormat:@"%lld", [fileSizeValue longLongValue]];
//            model.mediaType = WKMediaTypeVideo;
//        }];
        
    }else{
        model.mediaType = WKMediaTypePhoto;
        ALAsset *tempAsset = (ALAsset *)asset;
        if ([[tempAsset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
            long  long durtime = [[tempAsset defaultRepresentation] size];
            model.dureTime = [NSString stringWithFormat:@"%lld", durtime];
            model.mediaType = WKMediaTypeVideo;
        }
    }
    return model;
}

@end
