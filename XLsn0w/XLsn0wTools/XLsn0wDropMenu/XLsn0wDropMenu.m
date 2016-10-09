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

#import "XLsn0wDropMenu.h"

@interface XLsn0wDropMenu () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UIButton *dropArrow;
@property (nonatomic, assign) CGFloat heightDrop;

@end

@implementation XLsn0wDropMenu

#pragma mark - init
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self drawUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self drawUI];
    }
    return self;
}

- (void)drawUI {
    _textButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) - CGRectGetHeight(self.frame), CGRectGetHeight(self.frame))];
    [_textButton.layer setBackgroundColor:[UIColor whiteColor].CGColor];
    [_textButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_textButton addTarget:self action:@selector(dropdownClick:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:_textButton];
    
    UIButton *arrowButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - CGRectGetHeight(self.frame), 0, CGRectGetHeight(self.frame), CGRectGetHeight(self.frame))];
    [arrowButton setImage:[UIImage imageNamed:@"arrowButton"] forState:(UIControlStateNormal)];
    CGFloat vInset = self.bounds.size.height / 5;
    CGFloat hInset = self.bounds.size.height / 8;
    arrowButton.imageEdgeInsets = UIEdgeInsetsMake(vInset, hInset, vInset, hInset);
    [arrowButton addTarget:self action:@selector(dropdownClick:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:arrowButton];
    self.dropArrow = arrowButton;
    
    //下拉框设置
    _dropListTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, _textButton.bounds.size.height, CGRectGetWidth(self.bounds), 0)];
    _dropListTableView.layer.borderWidth = 1.0;
    _dropListTableView.layer.borderColor = [[UIColor blackColor] CGColor];
    _dropListTableView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    _dropListTableView.rowHeight = _textButton.bounds.size.height;
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    _dropListTableView.delegate = self;
    _dropListTableView.dataSource = self;
    if (!_listItems) {
        [_textButton setTitle:@" " forState:UIControlStateNormal];
    }
    CGFloat fontsize = ( _textButton.bounds.size.height * 3.0f / 7.0f);
    [_textButton.titleLabel setFont:[UIFont systemFontOfSize:(CGFloat)fontsize]];
    if ([_dropListTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_dropListTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([_dropListTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_dropListTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [self addSubview:_dropListTableView];
    self.dropListTableView = _dropListTableView;
}

/**
 *  改变frame时会调用，方便IB中调试
 */
- (void)prepareForInterfaceBuilder {
    [self updateFrame];
}

/**
 *  用于IB中调试
 */
- (void)updateFrame {
    [_textButton setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) - CGRectGetHeight(self.frame), CGRectGetHeight(self.frame))];
    [self.dropArrow setFrame: CGRectMake(CGRectGetWidth(self.frame) - CGRectGetHeight(self.frame), 0, CGRectGetHeight(self.frame), CGRectGetHeight(self.frame))];
    CGFloat vInset = self.bounds.size.height / 5;
    CGFloat hInset = self.bounds.size.height / 8;
    self.dropArrow.imageEdgeInsets = UIEdgeInsetsMake(vInset, hInset, vInset, hInset);
    CGFloat fontsize = (_textButton.bounds.size.height * 3.0f / 7.0f);
    [_textButton.titleLabel setFont:[UIFont systemFontOfSize:(CGFloat)fontsize]];
}
#pragma mark - Action
-(void)dropdownClick:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBottomView" object:nil userInfo:nil];
    if (!_maxRows) {
        self.heightDrop = _listItems.count > 5 ? (5 * self.dropListTableView.rowHeight + .2f * _textButton.bounds.size.height) : (self.dropListTableView.rowHeight * _listItems.count + .2f * _textButton.bounds.size.height);
    }
    if (self.dropListTableView.frame.size.height == 0) {
        [self.dropListTableView reloadData];
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:.25 animations:^{
            [weakSelf.dropListTableView setFrame:CGRectMake(0,weakSelf.dropListTableView.frame.origin.y, weakSelf.dropListTableView.frame.size.width, weakSelf.heightDrop)];
            
            CGRect frameTemp = weakSelf.frame;
            frameTemp.size.height = weakSelf.textButton.frame.size.height + weakSelf.heightDrop;
            weakSelf.frame = frameTemp;
            [weakSelf.superview bringSubviewToFront:weakSelf];
        }completion:^(BOOL finished){
            
        }];
    }else{
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:.25 animations:^{
            [weakSelf.dropListTableView setFrame:CGRectMake(0,weakSelf.dropListTableView.frame.origin.y, weakSelf.dropListTableView.frame.size.width, 0)];
            CGRect frameTemp = weakSelf.frame;
            frameTemp.size.height = weakSelf.textButton.frame.size.height + 0;
            weakSelf.frame = frameTemp;
        } completion:nil];
    }
}

#pragma mark - UITableView Delegate&DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:14];;
    cell.textLabel.text = _listItems[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dropdownClick:self.dropArrow];
    NSString *btnTitle = _listItems[indexPath.row];
    [_textButton setTitle:btnTitle forState:UIControlStateNormal];
    
    [self.xlsn0wDelegate dropMenu:self didSelectRow:indexPath.row];

    if (self.ClickDropDown) {
        self.ClickDropDown(indexPath.row);
    }
}

- (void)closeMenu {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:.25 animations:^{
        [weakSelf.dropListTableView setFrame:CGRectMake(0,weakSelf.dropListTableView.frame.origin.y, weakSelf.dropListTableView.frame.size.width, 0)];
        CGRect frameTemp = weakSelf.frame;
        frameTemp.size.height = weakSelf.textButton.frame.size.height + 0;
        weakSelf.frame = frameTemp;
    }completion:^(BOOL finished){
        
    }];
    
}

- (void)reloadData {
    self.maxRows = self.listItems.count;
    self.defaultTitle = self.listItems[0];
    [self.dropListTableView reloadData];
}

#pragma mark - cell分割线填满
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Setter Getter
- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = cornerRadius > 0 ? true : false;
}

- (void)setMaxRows:(NSInteger)maxRows {
    _maxRows = maxRows;
    if (!_maxRows) {
        _maxRows = _listItems.count;
    }
    if (_maxRows <= _listItems.count) {
       self. heightDrop = self.dropListTableView.rowHeight * _maxRows + .2f * _textButton.bounds.size.height;
    }else{
        self.heightDrop = self.dropListTableView.rowHeight * _listItems.count + .2f * _textButton.bounds.size.height;
    }
}

- (void)setArrowImage:(UIImage *)arrowImage {
    _arrowImage = arrowImage;
    [self.dropArrow setImage:arrowImage forState:UIControlStateNormal];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = _borderColor.CGColor;
    self.dropListTableView.layer.borderColor = _borderColor.CGColor;
}

-(void)setListItems:(NSArray *)listItems {
    _listItems = listItems;
    [_textButton setTitle:@"" forState:UIControlStateNormal];
}

-(void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [_textButton setTitleColor:_textColor forState:UIControlStateNormal];
}

- (void)setDefaultTitle:(NSString *)defaultTitle {
    _defaultTitle = defaultTitle;
    [_textButton setTitle:_defaultTitle forState:UIControlStateNormal];
}

- (void)setComBackgroundColor:(UIColor *)comBackgroundColor {
    _comBackgroundColor = comBackgroundColor;
    _textButton.backgroundColor = _comBackgroundColor;
    self.dropArrow.backgroundColor = _comBackgroundColor;
}

- (void)setTitleSize:(NSInteger)titleSize {
    _textButton.titleLabel.font = [UIFont systemFontOfSize:titleSize];
}

- (void)setTestString:(NSString *)testString {
    _testString = testString;
    [_textButton setTitle:_testString forState:UIControlStateNormal];
}

- (NSString *)value {
    return _textButton.titleLabel.text;
}

@end
