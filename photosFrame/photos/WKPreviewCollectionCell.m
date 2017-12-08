//
//  WKPreviewCollectionCell.m
//  photosFrame
//
//  Created by wk on 2017/11/29.
//  Copyright © 2017年 wk. All rights reserved.
//

#import "WKPreviewCollectionCell.h"
#import "WKPhtotosManager.h"
#import "WKAlbumModel.h"

@interface WKPreviewCollectionCell()<UIScrollViewDelegate>

@property(nonatomic, strong)UIScrollView *scrollView;
@property(nonatomic, strong)UIImageView *imageView;
@end


@implementation WKPreviewCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(10, 0, self.frame.size.width - 20, self.frame.size.height)];
    _scrollView.bouncesZoom = YES;
    _scrollView.bounces = YES;
    _scrollView.minimumZoomScale = 0.5;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.delaysContentTouches = NO;
    _scrollView.canCancelContentTouches = YES;
    _scrollView.alwaysBounceVertical = NO;
    _scrollView.userInteractionEnabled = YES;
    [self addSubview:_scrollView];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    _imageView.userInteractionEnabled =  YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [_imageView addGestureRecognizer:singleTap];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [_imageView addGestureRecognizer:doubleTap];
    [_scrollView addSubview:_imageView];
}
- (void)singleTap:(UITapGestureRecognizer *)tap
{
    if (self.singleTapBlock) {
        self.singleTapBlock();
    }
}
- (void)doubleTap:(UITapGestureRecognizer *)tap
{
    if (_scrollView.zoomScale > 1.0) {
        _scrollView.contentInset = UIEdgeInsetsZero;
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat zoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / zoomScale;
        CGFloat ysize = self.frame.size.height / zoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}
- (void)setPhotoModel:(WKPhotosModel *)photoModel
{
    _photoModel = photoModel;

    [[WKPhtotosManager shareManager]getPostImageWithAsset:photoModel.asset original:YES completion:^(UIImage *image) {
        [self refrash:image];
        _imageView.image = image;
    }];
}

//- (void)setIndex:(NSInteger)index
//{
//    _index = index;
//    _scrollView.contentOffset = CGPointMake(index*self.frame.size.width, 0);
//}
- (void)refrash:(UIImage *)image
{
    CGSize size = image.size;
//    if (size.width > Screen_W) {
        CGFloat height = Screen_W *size.height / size.width;
        CGRect rect = CGRectZero;
        if (height > Screen_H) {
            _scrollView.contentSize = CGSizeMake(0, height);
            rect = CGRectMake(0, 0, Screen_W, height);
        }else{
            
            rect = CGRectMake(0, (Screen_H - height)/2, Screen_W, height);
        }
        _imageView.frame = rect;
//        _scrollView.frame = rect;
//    }
}

#pragma UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (scale < 1.0) {
        [scrollView setZoomScale:1.0 animated:YES];
    }
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    scrollView.contentInset = UIEdgeInsetsZero;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"%s",__func__);
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}

#pragma mark - Private

- (void)refreshImageContainerViewCenter {
    CGFloat offsetX = (_scrollView.frame.size.width > _scrollView.contentSize.width) ? ((_scrollView.frame.size.width - _scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (_scrollView.frame.size.height > _scrollView.contentSize.height) ? ((_scrollView.frame.size.height - _scrollView.contentSize.height) * 0.5) : 0.0;
    self.imageView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
}
@end
