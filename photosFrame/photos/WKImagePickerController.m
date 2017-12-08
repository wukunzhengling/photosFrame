//
//  WKImagePickerController.m
//  photosFrame
//
//  Created by wk on 2017/11/15.
//  Copyright © 2017年 wk. All rights reserved.
//

#import "WKImagePickerController.h"
#import "WKPhtotosManager.h"
#import "WKAlbumCell.h"
#import "WKPhotoPickerController.h"
#import "WKAlbumModel.h"

@interface WKImagePickerController ()
@property(nonatomic, strong)UILabel *tipLabel;
@property(nonatomic, strong)UIButton *settingBtn;
@end

@implementation WKImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationItem setTitle:@"照片"];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    rightItem.tintColor = [UIColor blueColor];
    self.navigationController.navigationItem.rightBarButtonItem = rightItem;
    // 导航栏左右按钮字体颜色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self configerSetting];
    
}
- (instancetype)init
{
    self = [super init];
    
    
    return self;
}
- (void)cancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)configerSetting
{
    if (![[WKPhtotosManager shareManager]authorizationStatusAuthorized ]) {
        _tipLabel = [[UILabel alloc]init];
        _tipLabel.frame = CGRectMake(8, 120, self.view.frame.size.width - 16, 60);
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.numberOfLines = 0;
        _tipLabel.font = [UIFont systemFontOfSize:16];
        _tipLabel.textColor = [UIColor blackColor];
        NSDictionary *infoDict = [[NSBundle mainBundle]infoDictionary];
        NSString *appName = [infoDict objectForKey:@"CFBundleDisplayName"];
        _tipLabel.text = [NSString stringWithFormat:@"允许 %@ 访问你的相册在 设置 -> 隐私 -> 相册", appName];
        [self.view addSubview:_tipLabel];
        _settingBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_settingBtn setTitle:@"设置" forState:UIControlStateNormal];
        _settingBtn.frame = CGRectMake(0, 180, self.view.frame.size.width, 44);
        _settingBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_settingBtn addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_settingBtn];
    }
}

- (void)settingBtnClick
{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end


@interface WKAlbumPickerController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSArray *dataArray;
@end
static NSString *indentifier = @"WKAlbumCell";
@implementation WKAlbumPickerController

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[WKAlbumCell class] forCellReuseIdentifier:indentifier];
    }
    return _tableView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configTableView];
    self.navigationItem.title = @"照片";
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = rightBar;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    
    //去除没有数据的空白行
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor whiteColor];
    [self.tableView setTableFooterView:view];
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)configTableView
{
    [[WKPhtotosManager shareManager]getAllAlbumsCameraRollAlbum:YES allowPickImage:YES completeBlock:^(NSArray *models) {
        self.dataArray = models;
        if (self.dataArray.count) {
            [_tableView reloadData];
        }
    }];
}
#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WKAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    cell.albumModel = self.dataArray[indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block WKAlbumModel *model = self.dataArray[indexPath.row];
    [[WKPhtotosManager shareManager]getAlbumPhotos:model.result completeBlock:^(NSArray *photos) {
        
        WKPhotoPickerController *photoVc = [[WKPhotoPickerController alloc]init];
        photoVc.assets = photos;
        photoVc.albumModel = model;
        [self.navigationController pushViewController:photoVc animated:YES];
    }];
}
@end
