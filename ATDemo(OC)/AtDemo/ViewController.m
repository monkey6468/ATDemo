//
//  ViewController.m

#import "ViewController.h"
#import "ListViewController.h"

#import "TableViewCell.h"
#import "ATTextView.h"

#import "HNWKeyboardMonitor.h"

#define k_defaultFont   [UIFont systemFontOfSize:15]
#define k_defaultColor  [UIColor blueColor]
#define k_hightColor    [UIColor redColor]

@interface ViewController ()<ATTextViewDelegate, HNWKeyboardMonitorDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet ATTextView *textView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewConstraintH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineConstraintB;

@property (strong, nonatomic) NSMutableArray *dataArray;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"ATTextView_OC";
    
    [self settingUI];
    [self initTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [HNWKeyboardMonitor addDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [HNWKeyboardMonitor removeDelegate:self];
}

#pragma mark - UI
- (void)settingUI {
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    
    self.textView.atDelegate = self;
//    self.textView.maxTextLength = 20;
    self.textView.placeholder = @"我是测试placeholder";
    self.textView.placeholderTextColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.75];
    self.textView.font = k_defaultFont;
    self.textView.attributedTextColor = k_defaultColor;
    [self.textView becomeFirstResponder];
}

- (void)initTableView {
    self.tableView.tableFooterView = UIView.new;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TableViewCell class])
                                               bundle:nil]
         forCellReuseIdentifier:NSStringFromClass(TableViewCell.class)];
}

- (void)updateUI {
    CGRect frame = [self.textView.attributedText boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-85, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGFloat h = frame.size.height;
    if (h <= 80) {
        h = 80;
    }
    self.textViewConstraintH.constant = h;
}

#pragma mark - other
- (IBAction)onActionInsert:(UIButton *)sender {
    ListViewController *vc = [[ListViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
//    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:NO completion:nil];
    
    __weak typeof(self) weakSelf = self;
    vc.block = ^(NSInteger index, User * _Nonnull user) {
        [weakSelf updateUIWithUser:user];
    };
}

- (void)updateUIWithUser:(User *)user {
        
    NSString *insertText = [NSString stringWithFormat:@"@%@ ", user.name];
    TextViewBinding *bindingModel = [[TextViewBinding alloc]initWithName:user.name
                                                                  userId:user.userId];

    // 插入前手动判断
//    if (self.textView.text.length+insertText.length > 20) {
//        NSLog(@"已经超出最大输入限制了....");
//        return;
//    }
    
    [self.textView insertText:insertText];
    NSMutableAttributedString *tmpAString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    NSRange range = NSMakeRange(self.textView.selectedRange.location - insertText.length, insertText.length);
    [tmpAString setAttributes:@{NSForegroundColorAttributeName:k_hightColor,
                                NSFontAttributeName:k_defaultFont,
                                TextBindingAttributeName:bindingModel}
                        range:range];

    // 解决光标在插入‘特殊文本’后 移动到文本最后的问题
    NSInteger lastCursorLocation = self.textView.cursorLocation;
    self.textView.attributedText = tmpAString;
    self.textView.selectedRange = NSMakeRange(lastCursorLocation, self.textView.selectedRange.length);
    self.textView.cursorLocation = lastCursorLocation;
}

- (void)done {
    [self.view endEditing:YES];
    
    NSArray *results = self.textView.atUserList;

    NSLog(@"输出打印:");
    for (TextViewBinding *model in results) {
        NSLog(@"user info - name:%@ - location:%ld",model.name, model.range.location);
    }
    
    DataModel *model = [[DataModel alloc]init];
    model.userList = results;
    model.text = self.textView.text;
    [self.dataArray addObject:model];
    
    self.textView.text = nil;
    [self updateUI];
    self.textView.typingAttributes = @{NSFontAttributeName:k_defaultFont, NSForegroundColorAttributeName:k_defaultColor};

    [self.tableView reloadData];
}

#pragma mark - ATTextViewDelegate
- (void)atTextViewDidChange:(ATTextView *)textView {
    NSLog(@"%@",textView.text);
    [self updateUI];
}



















#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DataModel *model = self.dataArray[indexPath.row];
    return [TableViewCell rowHeightWithModel:model];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TableViewCell.class)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSLog(@"点击了cell");
}

#pragma mark HNWKeyboardMonitorDelegate
- (void)keyboardMonitor:(HNWKeyboardMonitor *)keyboardMonitor keyboardWillShow:(HNWKeyboardInfo *)info {
    if (@available(iOS 11.0, *)) {
        self.bottomLineConstraintB.constant = info.keyboardEndFrame.size.height-self.view.safeAreaInsets.bottom;
    } else {
        self.bottomLineConstraintB.constant = info.keyboardEndFrame.size.height;
    }
    [UIView animateWithDuration:info.animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardMonitor:(HNWKeyboardMonitor *)keyboardMonitor keyboardWillHide:(HNWKeyboardInfo *)info {
    self.bottomLineConstraintB.constant = 0;
    [UIView animateWithDuration:info.animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - get data
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
