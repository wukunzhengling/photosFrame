//
//  WKAlbumModel.h
//  photosFrame
//
//  Created by wk on 2017/11/15.
//  Copyright © 2017年 wk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WKAlbumModel : NSObject
@property (nonatomic, strong) NSString *name;        ///< The album name
@property (nonatomic, assign) NSInteger count;       ///< Count of photos the album contain
@property (nonatomic, strong) id result;             ///< PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset>

+ (instancetype)albumModelWith:(id)result albumName:(NSString *)albumName;  //albumName  相册名字
@end

typedef NS_ENUM(NSUInteger, WKMediaType) {
    WKMediaTypePhoto = 0,
    WKMediaTypeVideo,
    WKMediaTypeLivePhoto
};
@interface WKPhotosModel : NSObject

@property(nonatomic, strong)id asset; // PHAsset or ALAsset
@property(nonatomic, assign)BOOL isSelected;
@property(nonatomic, strong)NSString *dureTime;
@property(nonatomic, assign) WKMediaType mediaType;

+ (instancetype)photosModelWith:(id)asset albumName:(NSString *)albumName; //albumName  相册名字

@end
