//
//  WKAlbumCell.m
//  photosFrame
//
//  Created by wk on 2017/11/15.
//  Copyright © 2017年 wk. All rights reserved.
//

#import "WKAlbumCell.h"
#import "WKAlbumModel.h"
#import "WKPhtotosManager.h"

@interface WKAlbumCell()
@property(nonatomic, strong)UIImageView *avatorImageView;
@property(nonatomic, strong)UILabel *albumLabel;
@end
@implementation WKAlbumCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpUI];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}
- (void)setUpUI
{
    _avatorImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 70, 70)];
    _avatorImageView.clipsToBounds = YES;
    _avatorImageView.contentMode= UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_avatorImageView];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.frame = CGRectMake(80, 0, self.frame.size.width - 80 - 50, self.frame.size.height);
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:titleLabel];
    _albumLabel = titleLabel;
}
- (void)layoutSublayersOfLayer:(CALayer *)layer {
    if (iOS7Later) [super layoutSublayersOfLayer:layer];
}
- (void)setAlbumModel:(WKAlbumModel *)albumModel
{
    _albumModel = albumModel;
    NSString *text = [NSString stringWithFormat:@"%@  (%zd)",albumModel.name, albumModel.count];
    _albumLabel.text = text;
//    _avatorImageView.image = [];
    [[WKPhtotosManager shareManager]getPostImageWithAsset:albumModel completion:^(UIImage *image) {
        
        _avatorImageView.image = image;
    }];
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
