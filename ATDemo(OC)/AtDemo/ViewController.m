//
//  ViewController.m

#import "ViewController.h"
#import "ListViewController.h"

#import "TableViewOCCell.h"
#import "ATTextView.h"

#import "HNWKeyboardMonitor.h"

#define k_defaultFont   [UIFont systemFontOfSize:15]
#define k_defaultColor  [UIColor blueColor]
#define k_hightColor    [UIColor redColor]
#define k_max_input     20

@interface ViewController ()<ATTextViewDelegate, HNWKeyboardMonitorDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet ATTextView *textView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewConstraintH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewConstraintB;

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (assign, nonatomic, getter=isNeedShowKeyboard) BOOL bNeedShowKeyboard;

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
    if (self.isNeedShowKeyboard) {
        self.bNeedShowKeyboard = NO;
        [self.textView becomeFirstResponder];
    }
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
//    self.textView.maxTextLength = k_max_input;
    self.textView.placeholder = @"我是测试placeholder";
//    self.textView.placeholderTextColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.75];
    self.textView.font = k_defaultFont;
    self.textView.attributedTextColor = k_defaultColor;
    [self.textView becomeFirstResponder];
}

- (void)initTableView {
    self.tableView.tableFooterView = UIView.new;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(TableViewOCCell.class)
                                               bundle:nil]
         forCellReuseIdentifier:NSStringFromClass(TableViewOCCell.class)];
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
    self.textView.bAtChart = NO;
    [self pushAtVc];
}

- (void)pushAtVc {
    self.bNeedShowKeyboard = YES;
    ListViewController *vc = [[ListViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
    
    __weak typeof(self) weakSelf = self;
    vc.block = ^(NSInteger index, User * _Nonnull user) {
        
        ATTextViewBinding *bindingModel = [[ATTextViewBinding alloc]initWithName:user.name
                                                                          userId:user.userId];
        [weakSelf.textView insertWithBindingModel:bindingModel];
    };
}

- (void)done {
    [self.view endEditing:YES];
    
    NSArray *results = self.textView.atUserList;

    NSLog(@"输出打印:");
    for (ATTextViewBinding *model in results) {
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

- (void)atTextViewDidInputSpecialText:(ATTextView *)textView {
    [self pushAtVc];
}
















#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DataModel *model = self.dataArray[indexPath.row];
    return [TableViewOCCell rowHeightWithModel:model];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewOCCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TableViewOCCell.class)];
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
        self.bottomViewConstraintB.constant = info.keyboardEndFrame.size.height-self.view.safeAreaInsets.bottom;
    } else {
        self.bottomViewConstraintB.constant = info.keyboardEndFrame.size.height;
    }
    [UIView animateWithDuration:info.animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardMonitor:(HNWKeyboardMonitor *)keyboardMonitor keyboardWillHide:(HNWKeyboardInfo *)info {
    self.bottomViewConstraintB.constant = 0;
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
