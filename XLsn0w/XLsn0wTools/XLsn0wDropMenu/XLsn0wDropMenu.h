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

#import <UIKit/UIKit.h>

@class XLsn0wDropMenu;

@protocol XLsn0wDropMenuDelegate <NSObject>

- (void)dropMenu:(XLsn0wDropMenu *)dropMenu didSelectRow:(NSInteger)row;

@end

@interface XLsn0wDropMenu : UIView

@property (nonatomic, weak) id<XLsn0wDropMenuDelegate> xlsn0wDelegate;

@property (nonatomic, strong) UIButton *textButton;

@property (nonatomic, strong) UITableView *dropListTableView;
/*! 圆角 */
@property (nonatomic) CGFloat cornerRadius;
/*! 边线宽度 */
@property (nonatomic) CGFloat borderWidth;
/*! 边线颜色 */
@property (nonatomic) UIColor *borderColor;
/*! 箭头图片 */
@property (nonatomic) UIImage *arrowImage;
/*! 文字颜色 */
@property (nonatomic) UIColor *textColor;
/*! 测试颜色 */
@property (nonatomic) NSString *testString;
/*! 最大行数 */
@property (nonatomic) NSInteger maxRows;
/*! 下拉数据源 */
@property (strong, nonatomic) NSArray *listItems;
/*! 默认标题 */
@property (nonatomic, strong) NSString *defaultTitle;
/*! 背景颜色 */
@property (nonatomic, strong) UIColor *comBackgroundColor;
/*! 标题大小 */
@property (nonatomic, assign) NSInteger titleSize;
/*! 下拉时选择的事件 */
@property (nonatomic, copy) void (^ClickDropDown)(NSInteger index);
/*! 当前选项值 */
@property (nonatomic, copy, readonly) NSString *value;

- (void)reloadData;
- (void)closeMenu;

@end

/*!

 - (void)viewDidLoad {
 [super viewDidLoad];
 // Do any additional setup after loading the view, typically from a nib.
 
 
 _dropMenu = [[XLsn0wDropMenu alloc] initWithFrame:(CGRectMake(100, 200, 200, 30))];
 [self.view addSubview:_dropMenu];
 _dropMenu.listItems = @[@"房屋问题",@"居家维修(有偿维修)",@"楼宇对讲"];
 _dropMenu.maxRows = 3;//设置最大列数
 _dropMenu.defaultTitle = @"房屋问题";//标题
 _dropMenu.titleSize = 14;//标题字体大小
 _dropMenu.borderColor = [UIColor blackColor];
 _dropMenu.borderWidth = 1;
 _dropMenu.cornerRadius = 5;
 _dropMenu.comBackgroundColor = [UIColor whiteColor];
 _dropMenu.xlsn0wDelegate = self;
 
 [_dropMenu.textButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
 
 
 _bottomView = [UIView new];
 [self.view addSubview:_bottomView];
 _bottomView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
 _bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
 _bottomView.hidden = YES;
 UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBottomView)];
 [_bottomView addGestureRecognizer:tap];
 
 
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBottomView) name:@"showBottomView" object:nil];
 }
 
 - (void)hideBottomView {
 _bottomView.hidden = YES;
 [UIView animateWithDuration:.25 animations:^{
 [_dropMenu.dropListTableView setFrame:CGRectMake(0,_dropMenu.dropListTableView.frame.origin.y, _dropMenu.dropListTableView.frame.size.width, 0)];
 CGRect frameTemp = _dropMenu.frame;
 frameTemp.size.height = _dropMenu.textButton.frame.size.height + 0;
 _dropMenu.frame = frameTemp;
 } completion:nil];
 }
 
 - (void)showBottomView {
 _bottomView.hidden = NO;
 }
 
 - (void)dropMenu:(XLsn0wDropMenu *)dropMenu didSelectRow:(NSInteger)row {
 _bottomView.hidden = YES;
 
 }
 
 */
