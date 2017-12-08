//
//  WKPhotoPickerController.m
//  photosFrame
//
//  Created by wk on 2017/11/17.
//  Copyright © 2017年 wk. All rights reserved.
//

#import "WKPhotoPickerController.h"
#import "WKPhotoCell.h"
#import "WKAlbumModel.h"
#import "WKPhtotosManager.h"
#import "WKPhotoPreviewController.h"
#import "WKVideoPlayController.h"

#define oKButtonTitleColorNormal [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0]
#define oKButtonTitleColorDisabled  [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:0.5]

@interface WKPhotoPickerController ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSMutableArray *selectPhotos;
    UIButton * _previewButton;
    UIButton * _originalPhotoButton;
    UILabel * _originalPhotoLabel;
    UIButton * _doneButton;
    UIImageView * _numberImageView;
    UILabel * _numberLabel ;
    
    BOOL _isSelectOriginalPhoto;
}
@property(nonatomic, strong)UICollectionView *collection;
@end

static NSString *identify = @"WKPhotoCell";
@implementation WKPhotoPickerController

- (UICollectionView *)collection
{
    if (_collection == nil) {
        CGFloat margin = 10;
        int row = 4;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumInteritemSpacing = margin/2;
        layout.minimumLineSpacing = margin/2;
        CGFloat width = (self.view.bounds.size.width - (row +1)*margin/2 )/row;
        layout.itemSize = CGSizeMake(width, width);
        _collection = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collection.backgroundColor = [UIColor whiteColor];
        _collection.delegate = self;
        _collection.dataSource = self;
        [_collection registerClass:[WKPhotoCell class] forCellWithReuseIdentifier:identify];
        
    }
    return _collection;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    selectPhotos = [NSMutableArray array];
    self.title = self.albumModel.name;
    [self.view addSubview:self.collection];
    self.view.backgroundColor = [UIColor whiteColor];
    [self configBottomToolBar];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
// bottom tarbar
- (void)configBottomToolBar {
    
    CGFloat yOffset = 0;
    if (self.navigationController.navigationBar.isTranslucent) {
        yOffset = self.view.frame.size.height - 50;
    } else {
        CGFloat navigationHeight = 44;
        if (iOS7Later) navigationHeight += 20;
        yOffset = self.view.frame.size.height - 50 - navigationHeight;
    }
    
    UIView *bottomToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, yOffset, self.view.frame.size.width, 50)];
    CGFloat rgb = 253 / 255.0;
    bottomToolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
    
    NSString *preViewString  = @"预览";
    CGFloat previewWidth = [preViewString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size.width + 2;

    _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _previewButton.frame = CGRectMake(10, 3, previewWidth, 44);
    [_previewButton addTarget:self action:@selector(previewButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _previewButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_previewButton setTitle:preViewString forState:UIControlStateNormal];
    [_previewButton setTitle:preViewString forState:UIControlStateDisabled];
    [_previewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    _previewButton.enabled = selectPhotos.count;
    
    NSString *fullImageString = @"原图";
    CGFloat fullImageWidth = [fullImageString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size.width;
    _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _originalPhotoButton.frame = CGRectMake(CGRectGetMaxX(_previewButton.frame), self.view.frame.size.height - 50, fullImageWidth + 56, 50);
    _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_originalPhotoButton setTitle:fullImageString forState:UIControlStateNormal];
    [_originalPhotoButton setTitle:fullImageString forState:UIControlStateSelected];
    [_originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_originalPhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [_originalPhotoButton setImage:[UIImage imageNamed:@"photo.bundle/photo_original_def.png"] forState:UIControlStateNormal];
    [_originalPhotoButton setImage:[UIImage imageNamed:@"photo.bundle/photo_original_sel.png"] forState:UIControlStateSelected];
    _originalPhotoButton.selected = _isSelectOriginalPhoto;
    
    _originalPhotoLabel = [[UILabel alloc] init];
    _originalPhotoLabel.frame = CGRectMake(fullImageWidth + 46, 0, 80, 50);
    _originalPhotoLabel.textAlignment = NSTextAlignmentLeft;
    _originalPhotoLabel.font = [UIFont systemFontOfSize:16];
    _originalPhotoLabel.textColor = [UIColor blackColor];
    _originalPhotoLabel.hidden = selectPhotos.count <= 0;
    
    NSString *doneBtnString = @"完成";
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.frame = CGRectMake(self.view.frame.size.width - 44 - 12, 3, 44, 44);
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_doneButton setTitle:doneBtnString forState:UIControlStateNormal];
    [_doneButton setTitle:doneBtnString forState:UIControlStateDisabled];
    [_doneButton setTitleColor:oKButtonTitleColorNormal forState:UIControlStateNormal];
    [_doneButton setTitleColor:oKButtonTitleColorDisabled forState:UIControlStateDisabled];
    _doneButton.enabled = selectPhotos.count ;
    
    _numberImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo.bundle/photo_number_icon.png"]];
    _numberImageView.frame = CGRectMake(self.view.frame.size.width - 56 - 28, 10, 30, 30);
    _numberImageView.hidden = selectPhotos.count <= 0;
    _numberImageView.backgroundColor = [UIColor clearColor];
    
    _numberLabel = [[UILabel alloc] init];
    _numberLabel.frame = _numberImageView.frame;
    _numberLabel.font = [UIFont systemFontOfSize:15];
    _numberLabel.textColor = [UIColor whiteColor];
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    _numberLabel.text = [NSString stringWithFormat:@"%zd",selectPhotos.count];
    _numberLabel.hidden = selectPhotos.count <= 0;
    _numberLabel.backgroundColor = [UIColor clearColor];
    
    UIView *divide = [[UIView alloc] init];
    CGFloat rgb2 = 222 / 255.0;
    divide.backgroundColor = [UIColor colorWithRed:rgb2 green:rgb2 blue:rgb2 alpha:1.0];
    divide.frame = CGRectMake(0, 0, self.view.frame.size.width, 1);
    
    [bottomToolBar addSubview:divide];
    [bottomToolBar addSubview:_previewButton];
    [bottomToolBar addSubview:_doneButton];
    [bottomToolBar addSubview:_numberImageView];
    [bottomToolBar addSubview:_numberLabel];
    [self.view addSubview:bottomToolBar];
    [self.view addSubview:_originalPhotoButton];
    [_originalPhotoButton addSubview:_originalPhotoLabel];
}
- (void)originalPhotoButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    sender.selected ? [_originalPhotoButton setImage:[UIImage imageNamed:@"photo.bundle/photo_original_def.png"] forState:UIControlStateNormal] :
    [_originalPhotoButton setImage:[UIImage imageNamed:@"photo.bundle/photo_original_sel.png"] forState:UIControlStateSelected];
    _numberLabel.text = [NSString stringWithFormat:@"%zd",selectPhotos.count];
    _originalPhotoLabel.hidden = !sender.selected;
    [[WKPhtotosManager shareManager]getBytesPhotos:selectPhotos completion:^(NSString *bytes) {
        _originalPhotoLabel.text = bytes;
    }];
}
- (void)doneButtonClick
{
    NSLog(@"you are sending photo");
}
- (void)previewButtonClick
{
    NSLog(@"you preview photo");
    
}
- (void)getSelectedPhotoBytes
{
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WKPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    WKPhotosModel *model = [[WKPhotosModel alloc]init];
    id asset = self.assets[indexPath.row];
    model  = [WKPhotosModel photosModelWith:asset albumName:self.albumModel.name];
    cell.selectedBlock = ^(BOOL isSelected) {
        if (isSelected) {
            [selectPhotos addObject:model];
        }else{
            if ([selectPhotos containsObject:model]) {
                [selectPhotos removeObject:model];
            }
        }
        _previewButton.enabled = selectPhotos.count;
        _originalPhotoButton.enabled = selectPhotos.count > 0;
        _doneButton.enabled = selectPhotos.count ;
        _numberImageView.hidden = selectPhotos.count <= 0;
        _numberLabel.hidden = selectPhotos.count <= 0;
        _numberLabel.text = [NSString stringWithFormat:@"%zd",selectPhotos.count];
        [[WKPhtotosManager shareManager]getBytesPhotos:selectPhotos completion:^(NSString *bytes) {
            _originalPhotoLabel.text = bytes;
        }];
        if (selectPhotos.count == 0)
        {
            _originalPhotoLabel.hidden = YES;
            _originalPhotoButton.enabled = NO;
        }
    };
    cell.model = model;
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WKPhotosModel *model = [[WKPhotosModel alloc]init];
    id asset = self.assets[indexPath.row];
    model = [WKPhotosModel photosModelWith:asset albumName:self.albumModel.name];
    if (model.mediaType == WKMediaTypeVideo) {
        WKVideoPlayController *videoVc = [[WKVideoPlayController alloc]init];
        videoVc.asset = asset;
        [self.navigationController pushViewController:videoVc animated:YES];
        return;
    }
    WKPhotoPreviewController *photoPreviewVc = [[WKPhotoPreviewController alloc]init];
    photoPreviewVc.photoModel = model;
    photoPreviewVc.selectPhotos = selectPhotos;
    photoPreviewVc.assets = self.assets;//某个相册的照片
    photoPreviewVc.index = [self getPhotoInAlnumIndex:model];
    [self.navigationController pushViewController:photoPreviewVc animated:YES];
}

- (NSInteger)getPhotoInAlnumIndex:(WKPhotosModel *)photo
{
    NSInteger index = 0;
    if (selectPhotos.count)
    {
        for (NSInteger i=0; i<=selectPhotos.count-1; i++)
        {
            WKPhotosModel *model = selectPhotos[i];
            if (model.asset == photo.asset)
            {
                index = i;
            }
        }
    }
    else
    {
        for (NSInteger i=0; i<=self.assets.count-1; i++)
        {
            if (self.assets[i] == photo.asset)
            {
                index = i;
            }
        }
    }
    
    return index;
}
@end
