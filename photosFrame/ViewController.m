//
//  ViewController.m
//  photosFrame
//
//  Created by wk on 2017/11/11.
//  Copyright © 2017年 wk. All rights reserved.
//

#import "ViewController.h"
#import "WKTestCollectionViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVKit/AVKit.h>
#import "WKPhtotosManager.h"
#import "WKImagePickerController.h"

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate,UIActionSheetDelegate, UIAlertViewDelegate>

@property(nonatomic, strong)UICollectionView *collectionView;
@property(nonatomic, strong)UIImagePickerController *pickerVc;
@property(nonatomic, strong)NSMutableArray *dataArray;

@end

@implementation ViewController
- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        CGFloat margin = 10;
        int row = 4;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumInteritemSpacing = margin;
        layout.minimumLineSpacing = margin;
        CGFloat width = (self.view.bounds.size.width - (row +1)*margin )/row;
        layout.itemSize = CGSizeMake(width, width);
        _collectionView = [[UICollectionView alloc]initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[WKTestCollectionViewCell class] forCellWithReuseIdentifier:@"testcell"];
    }
    return _collectionView;
}
- (UIImagePickerController *)pickerVc
{
    if (_pickerVc == nil) {
        _pickerVc = [[UIImagePickerController alloc]init];
        _pickerVc.delegate = self;
    }
    return _pickerVc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma dataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count + 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WKTestCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"testcell" forIndexPath:indexPath];
    cell.videoImageView.hidden = YES;
    if (indexPath.item == self.dataArray.count) {
        cell.imageView.image = [UIImage imageNamed:@"AlbumAddBtn.png"];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == self.dataArray.count) {
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"去相册选择", nil];
        [sheet showInView:self.view];
    }
}

#pragma UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self takePhoto];
            break;
        case 1:
            [self takeAlnum];
            break;
        default:
            break;
    }
}

- (void)isCanUsePhotos{

        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if ((status == AVAuthorizationStatusNotDetermined || status == AVAuthorizationStatusDenied) && iOS7Later) {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
            alert.tag = 1;
            [alert show];
        //拍照之前检查相册权限
        }else if ([WKPhtotosManager authorizationStatus] == 2){//已被拒绝，没有相册权限，将无法保存
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
            alert.tag = 2;
            [alert show];
        }else{
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                self.pickerVc.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:self.pickerVc animated:YES completion:nil];
            }else{
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = @"模拟器中无法打开相机,请在真机中尝试";
                [hud hideAnimated:YES afterDelay:2.f];
            }
        }
}

- (void)takePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.pickerVc.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.pickerVc animated:YES completion:nil];
    }else{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"模拟器中无法打开相机,请在真机中尝试";
        [hud hideAnimated:YES afterDelay:2.f];
    }
}
- (void)takeAlnum
{
//    self.pickerVc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    [self presentViewController:self.pickerVc animated:YES completion:nil];
    WKAlbumPickerController *vc = [[WKAlbumPickerController alloc]init];
    WKImagePickerController *pickerVc = [[WKImagePickerController alloc]initWithRootViewController:vc ];
    [self presentViewController:pickerVc animated:YES completion:nil];
}

#pragma UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}

#pragma UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSLog(@"拍完照片后选择使用照片来到这个代理");
}
@end
