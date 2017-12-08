//
//  WKPhotoPreviewController.m
//  photosFrame
//
//  Created by wk on 2017/11/27.
//  Copyright © 2017年 wk. All rights reserved.
//

#import "WKPhotoPreviewController.h"
#import "WKPreviewCollectionCell.h"
#import "WKPhtotosManager.h"
#import "WKAlbumModel.h"

@interface WKPhotoPreviewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
//    UIView * _toolBar;
    UIButton * _originalPhotoButton;
//    UILabel * _originalPhotoLabel;
    UIButton * _doneButton;
    UIImageView * _numberImageView;
    UILabel * _numberLabel;
    
//    UIView * _naviBar;
    UIButton * _backButton;
    UIButton * _selectButton;
    UILabel * _indexLabel;
}

@property(nonatomic, strong)UICollectionView *collectionView;
@property(nonatomic, strong)UILabel * originalPhotoLabel;
@property(nonatomic, strong)UIView * toolBar;
@property(nonatomic, strong)UIView * naviBar;
@end

static NSString *identify = @"WKPreviewCollectionCell";
@implementation WKPhotoPreviewController

- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(self.view.frame.size.width + 20, self.view.frame.size.height);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(-10, 0, self.view.frame.size.width + 20, self.view.frame.size.height) collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.contentOffset = CGPointMake(0, 0);
        _collectionView.contentSize = CGSizeMake(self.selectPhotos.count*(self.view.frame.size.width + 20), 0);
        [_collectionView registerClass:[WKPreviewCollectionCell class] forCellWithReuseIdentifier:identify];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [_collectionView addGestureRecognizer:tap];
    }
    return _collectionView;
}
- (void)tap:(UITapGestureRecognizer *)tap
{
    _toolBar.hidden = !_toolBar.hidden;
    _naviBar.hidden = !_naviBar.hidden;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [self.view addSubview:self.collectionView];
    _collectionView.contentOffset = CGPointMake(self.index*_collectionView.frame.size.width, 0);
    [self configBottomToolBar];
    [self configCustomNaviBar];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)configBottomToolBar {
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    static CGFloat rgb = 34 / 255.0;
    _toolBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.7];
    
    NSString * fullImageBtnTitleStr = @"原图";
    CGFloat fullImageWidth = [fullImageBtnTitleStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size.width;
    _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _originalPhotoButton.frame = CGRectMake(0, 0, fullImageWidth + 56, 44);
    _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    _originalPhotoButton.backgroundColor = [UIColor clearColor];
    [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [_originalPhotoButton setTitle:fullImageBtnTitleStr forState:UIControlStateNormal];
    [_originalPhotoButton setTitle:fullImageBtnTitleStr forState:UIControlStateSelected];
    [_originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_originalPhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_originalPhotoButton setImage:[UIImage imageNamed:@"photo.bundle/preview_original_def.png"] forState:UIControlStateNormal];
    [_originalPhotoButton setImage:[UIImage imageNamed:@"photo.bundle/photo_original_sel.png"] forState:UIControlStateSelected];
    
    _originalPhotoLabel = [[UILabel alloc] init];
    _originalPhotoLabel.frame = CGRectMake(fullImageWidth + 42, 0, 80, 44);
    _originalPhotoLabel.textAlignment = NSTextAlignmentLeft;
    _originalPhotoLabel.font = [UIFont systemFontOfSize:13];
    _originalPhotoLabel.textColor = [UIColor whiteColor];
    _originalPhotoLabel.backgroundColor = [UIColor clearColor];
//    if (_isSelectOriginalPhoto) [self showPhotoBytes];
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.frame = CGRectMake(self.view.frame.size.width - 44 - 12, 0, 44, 44);
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    NSString * doneBtnTitleStr =  @"完成";
    [_doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_doneButton setTitle:doneBtnTitleStr forState:UIControlStateNormal];
    [_doneButton setTitleColor:[UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(17/255.0) alpha:1.0] forState:UIControlStateNormal];
    
    _numberImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo.bundle/photo_number_icon.png"]];
    _numberImageView.backgroundColor = [UIColor clearColor];
    _numberImageView.frame = CGRectMake(self.view.frame.size.width - 56 - 28, 7, 30, 30);
    _numberImageView.hidden = self.selectPhotos.count <= 0;
    
    _numberLabel = [[UILabel alloc] init];
    _numberLabel.frame = _numberImageView.frame;
    _numberLabel.font = [UIFont systemFontOfSize:15];
    _numberLabel.textColor = [UIColor whiteColor];
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    _numberLabel.text = [NSString stringWithFormat:@"%zd",self.selectPhotos.count];
    _numberLabel.hidden = self.selectPhotos.count <= 0;
    _numberLabel.backgroundColor = [UIColor clearColor];
    
    [_originalPhotoButton addSubview:_originalPhotoLabel];
    [_toolBar addSubview:_doneButton];
    [_toolBar addSubview:_originalPhotoButton];
    [_toolBar addSubview:_numberImageView];
    [_toolBar addSubview:_numberLabel];
    [self.view addSubview:_toolBar];
}

- (void)configCustomNaviBar {
    
    _naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    _naviBar.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:0.7];
    
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 44, 44)];
    [_backButton setImage:[UIImage imageNamed:@"photo.bundle/navi_back.png"] forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    _selectButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 54, 10, 42, 42)];
    [_selectButton setImage:[UIImage imageNamed:@"photo.budle/photo_def_photoPickerVc.png"] forState:UIControlStateNormal];
    [_selectButton setImage:[UIImage imageNamed:@"photo.budle/photo_sel_photoPickerVc.png"] forState:UIControlStateSelected];
    [_selectButton addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
    
    [_naviBar addSubview:_selectButton];
    [_naviBar addSubview:_backButton];
    _indexLabel = [[UILabel alloc] init];
    CGFloat width = 40.0;
    _indexLabel.frame = CGRectMake((_toolBar.frame.size.width - width)/2.0 , 20, width, _toolBar.frame.size.height -20);
    _indexLabel.font = [UIFont systemFontOfSize:15];
    _indexLabel.textColor = [UIColor whiteColor];
    _indexLabel.textAlignment = NSTextAlignmentCenter;
    if (self.selectPhotos.count) {
        _indexLabel.text = [NSString stringWithFormat:@"%zd/%zd", _index+1, self.selectPhotos.count];
    }else{
        _indexLabel.text = [NSString stringWithFormat:@"%zd/%zd", _index+1, self.assets.count];
    }
    
    _indexLabel.backgroundColor = [UIColor clearColor];
    [_naviBar addSubview:_indexLabel];
    [self.view addSubview:_naviBar];
}
- (void)originalPhotoButtonClick:(UIButton *)sender
{
    NSLog(@"click originalPhotoButtonClick");
    __weak typeof(self) weakSelf = self;
    _originalPhotoButton.selected = !_originalPhotoButton.selected;
    _originalPhotoLabel.hidden = !_originalPhotoButton.selected;
    NSMutableArray *photosAyrray = [NSMutableArray array];
    if(self.selectPhotos.count) photosAyrray = self.selectPhotos;
    else [photosAyrray addObject:self.photoModel];
    [[WKPhtotosManager shareManager]getBytesPhotos:photosAyrray completion:^(NSString *bytes) {
        weakSelf.originalPhotoLabel.text = bytes;
    }];
}
- (void)doneButtonClick
{
    NSLog(@"click doneButtonClick");
}
- (void)backButtonClick
{
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController popViewControllerAnimated:NO];

}

#pragma UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = self.selectPhotos.count ? self.selectPhotos.count : self.assets.count;
    return count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WKPreviewCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    if (self.selectPhotos.count) {
        cell.photoModel = self.selectPhotos[indexPath.item];
    }else{
        cell.photoModel = [WKPhotosModel photosModelWith:self.assets[indexPath.item] albumName:nil];
    }
    __weak typeof(self) weakSelf = self;
    cell.singleTapBlock = ^{
        weakSelf.toolBar.hidden = !weakSelf.toolBar.hidden;
        weakSelf.naviBar.hidden = !weakSelf.naviBar.hidden;
    };
    return cell;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point  = scrollView.contentOffset;
    NSInteger indexScroll = point.x /scrollView.frame.size.width;
    if (self.selectPhotos.count) {
        _indexLabel.text = [NSString stringWithFormat:@"%zd/%zd", indexScroll+1, self.selectPhotos.count];
    }else{
        _indexLabel.text = [NSString stringWithFormat:@"%zd/%zd", indexScroll+1, self.assets.count];
    }
    
}
- (void)dealloc
{
    NSLog(@"=======");
}
@end
