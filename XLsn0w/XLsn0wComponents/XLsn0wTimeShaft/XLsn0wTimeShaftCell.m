/*********************************************************************************************
 *   __      __   _         _________     _ _     _    _________   __         _         __   *
 *	 \ \    / /  | |        | _______|   | | \   | |  |  ______ |  \ \       / \       / /   *
 *	  \ \  / /   | |        | |          | |\ \  | |  | |     | |   \ \     / \ \     / /    *
 *     \ \/ /    | |        | |______    | | \ \ | |  | |     | |    \ \   / / \ \   / /     *
 *     /\/\/\    | |        |_______ |   | |  \ \| |  | |     | |     \ \ / /   \ \ / /      *
 *    / /  \ \   | |______   ______| |   | |   \ \ |  | |_____| |      \ \ /     \ \ /       *
 *   /_/    \_\  |________| |________|   |_|    \__|  |_________|       \_/       \_/        *
 *                                                                                           *
 *********************************************************************************************/

#import "XLsn0wTimeShaftCell.h"

#import "XLsn0wTimeShaftModel.h"

#import <Masonry/Masonry.h>
#import <UIImageView+WebCache.h>

#define leftSpace 50
//R G B 颜色
#define XLsn0wTimeShaftCellRGBColor(r,g,b)    [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

@interface XLsn0wTimeShaftCell ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *contentLabel;
@property(nonatomic, strong) UILabel *statusLabel;
@property(nonatomic, strong) UILabel *phoneNumberLabel;
@property(nonatomic, strong) UILabel *timeLabel;

/** 图片 */
@property (nonatomic, strong) UIImageView *recordImageView;

@end

@implementation XLsn0wTimeShaftCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self drawCellUI];
    }
    return self;
}

- (void)setCurrented:(BOOL)currented {
    _currented = currented;
    if (currented) {
//        self.contentLabel.textColor = [UIColor blueColor];
    } else {
//        self.contentLabel.textColor = LZRGBColor(139, 139, 139);
    }
}


- (void)drawCellUI {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont boldSystemFontOfSize:15];
    _titleLabel.numberOfLines = 0;
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(40);
        make.width.mas_equalTo(120);
    }];
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.font = [UIFont systemFontOfSize:12];
    _contentLabel.numberOfLines = 0;
    [self.contentView addSubview:_contentLabel];
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-40);
        make.left.mas_equalTo(40);
        make.width.mas_equalTo(300);
    }];
    
    _statusLabel = [[UILabel alloc] init];
    _statusLabel.font = [UIFont systemFontOfSize:12];
    _statusLabel.numberOfLines = 0;
    [self.contentView addSubview:_statusLabel];
    _statusLabel.textColor = [UIColor blueColor];
    [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-20);
        make.left.mas_equalTo(40);
        make.width.mas_equalTo(300);
    }];
    
    _timeLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.right.mas_equalTo(-1);
        make.width.mas_equalTo(120);
    }];
    _timeLabel.font = [UIFont systemFontOfSize:15];
    
    _recordImageView = [[UIImageView alloc] init];
    _recordImageView.image = [UIImage imageNamed:@"point"];
    [self.contentView addSubview:_recordImageView];
    [_recordImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_contentLabel.mas_bottom).offset(10);
        make.centerX.equalTo(_contentLabel);
        make.height.width.equalTo(@100);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = XLsn0wTimeShaftCellRGBColor(238, 238, 238);
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40);
        make.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
        make.height.mas_equalTo(@1);
    }];
}

- (void)setModel:(XLsn0wTimeShaftModel *)model {
    _model = model;
    _timeLabel.text = model.time;
    _statusLabel.text = model.status;
    _titleLabel.text = model.title;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:4];//调整行间距
    NSDictionary *attributes = @{NSFontAttributeName:self.contentLabel.font,NSParagraphStyleAttributeName:paragraphStyle};
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:model.content attributes:attributes];
    _contentLabel.attributedText = attrString;
    
    if ([model.imgUrl isEqualToString:@""] || model.imgUrl == nil) {
        _recordImageView.hidden = YES;
        [_recordImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentLabel.mas_bottom).offset(10);
            make.centerX.equalTo(_contentLabel);
            make.height.width.equalTo(@0);
        }];
    } else {
        _recordImageView.hidden = NO;
        [_recordImageView sd_setImageWithURL:[NSURL URLWithString:model.imgUrl] placeholderImage:[UIImage imageNamed:@"point"]];
        [_recordImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentLabel.mas_bottom).offset(10);
            make.centerX.equalTo(_contentLabel);
            make.height.width.equalTo(@100);
        }];
    }


}

- (void)drawRect:(CGRect)rect {
    
    CGFloat height = self.bounds.size.height;
    CGFloat cicleWith = self.currented?12:6;
    //    CGFloat shadowWith = cicleWith/3.0;
    
    if (self.hasUpLine) {
        
        UIBezierPath *topBezier = [UIBezierPath bezierPath];
        [topBezier moveToPoint:CGPointMake(leftSpace/2.0, 0)];
        [topBezier addLineToPoint:CGPointMake(leftSpace/2.0, height/2.0 - cicleWith/2.0 - cicleWith/6.0)];
        
        topBezier.lineWidth = 1.0;
        UIColor *stroke = XLsn0wTimeShaftCellRGBColor(185, 185, 185);
        [stroke set];
        [topBezier stroke];
    }
    
    if (self.currented) {
        
        UIBezierPath *cicle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(leftSpace/2.0 - cicleWith/2.0, height/2.0 - cicleWith/2.0, cicleWith, cicleWith)];
        
        cicle.lineWidth = cicleWith/3.0;
        UIColor *cColor = [UIColor blueColor];
        [cColor set];
        [cicle fill];
        
        UIColor *shadowColor = [UIColor blueColor];
        [shadowColor set];
        
        
        [cicle stroke];
    } else {
        
        UIBezierPath *cicle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(leftSpace/2.0-cicleWith/2.0, height/2.0 - cicleWith/2.0, cicleWith, cicleWith)];
        
        UIColor *cColor = XLsn0wTimeShaftCellRGBColor(185, 185, 185);
        [cColor set];
        [cicle fill];
        
        [cicle stroke];
    }
    
    if (self.hasDownLine) {
        
        UIBezierPath *downBezier = [UIBezierPath bezierPath];
        [downBezier moveToPoint:CGPointMake(leftSpace/2.0, height/2.0 + cicleWith/2.0 + cicleWith/6.0)];
        [downBezier addLineToPoint:CGPointMake(leftSpace/2.0, height)];
        
        downBezier.lineWidth = 1.0;
        UIColor *stroke = XLsn0wTimeShaftCellRGBColor(185, 185, 185);
        [stroke set];
        [downBezier stroke];
    }
}

@end
