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
#import "XLsn0wGuidePager.h"
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

#define W [UIScreen mainScreen].bounds.size.width
#define H [UIScreen mainScreen].bounds.size.height

#define wid self.view.width * 0.5
#define hei self.view.height * 0.7

@interface XLsn0wGuidePager () <UICollectionViewDataSource>

@property (nonatomic ,assign) CGFloat preOffsetX;//定义成员属性保存上一个偏移量
@property (nonatomic,weak) UIImageView *guideImageV;

@end

@implementation XLsn0wGuidePager

- (instancetype)init {
    //创建流水布局
    UICollectionViewFlowLayout *flowL = [[UICollectionViewFlowLayout alloc] init];
    //设置每一个格子的大小
    //    flowL.itemSize = CGSizeMake(100, 100);
    flowL.itemSize = CGSizeMake(W, H);
    //设置最小间距
    flowL.minimumLineSpacing = 0;
    //设置每一个格子的间距
    flowL.minimumInteritemSpacing = 0;

    //设置滚动方向
    flowL.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    return [super initWithCollectionViewLayout:flowL];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //注册cell
    [self.collectionView registerClass:[XLsn0wGuidePagerCell class] forCellWithReuseIdentifier:@"XLsn0wGuidePagerCell"];
    //取消弹簧效果
    self.collectionView.bounces = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.dataSource = self;

    _pageControl = [[UIPageControl alloc] init];
    [self.collectionView addSubview:_pageControl];
    _pageControl.currentPageIndicatorTintColor = [UIColor blueColor];
    _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    _pageControl.numberOfPages = self.pageCount;
    _pageControl.currentPage = 0;
    _pageControl.frame = CGRectMake(200, W-80, 30, 30);
}

#pragma mark --------------------
#pragma mark 当scorllView减速时调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //计算每次滚动时的偏移量
    CGFloat offset = scrollView.contentOffset.x - self.preOffsetX;
    //移动引导页的图片位置
    //    NSLog(@"--contenOffset%f",scrollView.contentOffset.x);
    //修改图片的位置尺寸
    self.preOffsetX = scrollView.contentOffset.x;
    //开始先设置两倍的偏移量,目的是让动画左侧或右侧出来
    self.guideImageV.x += 2 * offset;
    
    [UIView animateWithDuration:0.5 animations:^{
        //通过动画减去一个偏移量
        self.guideImageV.x -= offset;
    }];
    //    NSLog(@"--offset--%f",offset);
    
    //把当前的contentOffset.x设置给上一个偏移量
    self.preOffsetX = scrollView.contentOffset.x;
    
    //计算当前多少页
    NSInteger page = scrollView.contentOffset.x / self.collectionView.width;
    
    //给guide1ImageV重新设置图片
    self.guideImageV.image = [UIImage imageNamed:[NSString stringWithFormat:@"guide%ld",page + 1]];
    
    
    _pageControl.currentPage = page;
    _pageControl.frame = CGRectMake(200+self.preOffsetX*page, W-80, 30, 30);
}

#pragma mark - UICollectionViewDataSource Delegate Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//每一组有多少个格子
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pageCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XLsn0wGuidePagerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XLsn0wGuidePagerCell" forIndexPath:indexPath];
    
    cell.image = [UIImage imageNamed:[NSString stringWithFormat:@"XLsn0wGuidePager%ld",indexPath.item + 1]];
    [cell setStartBtn:indexPath pageCount:self.pageCount];
    
    return cell;
}

@end

/**************************************************************************************************/

@interface XLsn0wGuidePagerCell ()

/** 创建背景图片控件 */
@property (nonatomic,weak) UIImageView *imageV;

/** 创建开始体验按钮控件 */
@property (nonatomic,weak) UIButton *startBtn;

@end

@implementation XLsn0wGuidePagerCell

//懒加载创建按钮
- (UIButton *)startBtn {
    if (_startBtn == nil) {
        UIButton *startBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
        [startBtn setImage:[UIImage imageNamed:@"guideStart"] forState:UIControlStateNormal];
        [startBtn sizeToFit];
        
        //给按钮传值
        _startBtn = startBtn;
        [self.contentView addSubview:startBtn];
        [startBtn addTarget:self action:@selector(startBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startBtn;
}

//实现点击方法,进入主框架
- (void)startBtnClick {
    //切换控制器tabBar
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeMainVC" object:nil];
    [_startBtn setImage:[UIImage imageNamed:@"guideClicked"] forState:UIControlStateNormal];
    
    //添加核心动画
    CATransition *rippleEffectCATransition = [CATransition animation];
    rippleEffectCATransition.type = @"rippleEffect";
    rippleEffectCATransition.duration = 2;
    [[UIApplication sharedApplication].keyWindow.layer addAnimation:rippleEffectCATransition forKey:nil];
}

//懒加载形式创建UIImageView
- (UIImageView *)imageV {
    if (_imageV == nil) {
        UIImageView *imageV = [[UIImageView alloc] init];
        [self.contentView addSubview:imageV];
        _imageV = imageV;
    }
    return _imageV;
}

//传入当前是第几个cell,和总共有多少个cell
- (void)setStartBtn:(NSIndexPath *)indexPath pageCount:(NSInteger)pageCount {

    //判断如果是最后一个item
    if (indexPath.item == pageCount - 1) {
        //添加立即显示,进入主框架
        self.startBtn.hidden = NO;
    } else {
        self.startBtn.hidden = YES;
    }
}
//每次设置图片的时候都给UIImageview重新赋值
- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageV.image = image;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //设置图片尺寸
    self.imageV.frame = self.bounds;
    
    //设置按钮的位置坐标
    
    self.startBtn.center = CGPointMake(self.frame.size.width  * 0.5, self.height * 0.8);
    
    
}

@end

/**************************************************************************************************/

@implementation UIView (FLMValueOfFrame)
- (CGFloat)left
{
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top
{
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right
{
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom
{
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}



- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)removeAllSubviews
{
    while (self.subviews.count)
    {
        UIView* child = self.subviews.lastObject;
        [child removeFromSuperview];
    }
}

@end

