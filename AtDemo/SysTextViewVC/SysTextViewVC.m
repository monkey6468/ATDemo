//
//  SysTextViewVC.m
//  AtDemo
//
//  Created by XWH on 2021/4/20.
//

#import "SysTextViewVC.h"
#import "ListViewController.h"

#import "TableViewCell.h"
#import "SZTextView.h"

#import "TextViewBinding.h"

#import "HNWKeyboardMonitor.h"

#define k_defaultFont   [UIFont systemFontOfSize:20]
#define k_defaultColor  [UIColor blackColor]
#define k_hightColor    [UIColor redColor]

@interface SysTextViewVC ()<UITextViewDelegate, HNWKeyboardMonitorDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textViewBg;
@property (strong, nonatomic) UITextView *textView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewConstraintH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineConstraintB;

/// 光标位置
@property (assign, nonatomic) NSInteger cursorLocation;

@property (strong, nonatomic) NSMutableArray *dataArray;

@end

@implementation SysTextViewVC

#pragma mark - life
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"TextViewVC";
    
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
//    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
//        self.automaticallyAdjustsScrollViewInsets = NO;
//    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    
    self.textView.font = k_defaultFont;
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
#define kATRegular @"@[\\u4e00-\\u9fa5\\w\\-\\_]+ "
- (NSArray<NSTextCheckingResult *> *)findAllAt {
    // 找到文本中所有的@
    NSString *string = self.textView.text;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kATRegular options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, [string length])];
    return matches;
}

#pragma mark 插入
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

#define kATFormat  @"@%@ "
- (void)updateUIWithUser:(User *)user {
    NSInteger index = self.textView.text.length;
    if (self.textView.isFirstResponder)
    {
        index = self.textView.selectedRange.location + self.textView.selectedRange.length;
        [self.textView resignFirstResponder];
    }

//    NSString *insertText = [NSString stringWithFormat:@"@%@ ", user.name];

    UITextView *textView = self.textView;
    NSString *insertString = [NSString stringWithFormat:kATFormat,user.name];

    NSMutableString *string = [NSMutableString stringWithString:textView.text];
    [string insertString:insertString atIndex:index];
    self.textView.text = string;
    [self textViewDidChange:self.textView];
    
    [self.textView becomeFirstResponder];
    textView.selectedRange = NSMakeRange(index + insertString.length, 0);
}

#pragma mark 点击完成
- (void)done {
    [self.view endEditing:YES];
    
    NSArray *results = [self findAllAt];
    NSLog(@"输出打印:");

    for (NSTextCheckingResult *match in results) {
        NSLog(@"%@",NSStringFromRange(match.range));
    }
    NSLog(@"\n\n");

//    DataModel *model = [[DataModel alloc]init];
//    model.userList = results;
//    model.text = self.textView.text;
//    [self.dataArray addObject:model];
    
//    self.textView.text = nil;
    [self updateUI];
    self.textView.typingAttributes = @{NSFontAttributeName:k_defaultFont,NSForegroundColorAttributeName:k_defaultColor};

    [self.tableView reloadData];
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

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@""])
    {
        NSRange selectRange = growingTextView.selectedRange;
        if (selectRange.length > 0)
        {
            //用户长按选择文本时不处理
            return YES;
        }
        
        // 判断删除的是一个@中间的字符就整体删除
        NSMutableString *string = [NSMutableString stringWithString:growingTextView.text];
        NSArray *matches = [self findAllAt];
        
        BOOL inAt = NO;
        NSInteger index = range.location;
        for (NSTextCheckingResult *match in matches)
        {
            NSRange newRange = NSMakeRange(match.range.location + 1, match.range.length - 1);
            if (NSLocationInRange(range.location, newRange))
            {
                inAt = YES;
                index = match.range.location;
                [string replaceCharactersInRange:match.range withString:@""];
                break;
            }
        }
        
        if (inAt)
        {
            growingTextView.text = string;
            [self textViewDidChange:growingTextView];
            growingTextView.selectedRange = NSMakeRange(index, 0);
            return NO;
        }
    }
    
    //判断是回车键就发送出去
    if ([text isEqualToString:@"\n"])
    {
        [self done];
        return NO;
    }
    
    return YES;
}

//- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
- (void)textViewDidChange:(UITextView *)growingTextView {
    
    UITextRange *selectedRange = growingTextView.markedTextRange;
    NSString *newText = [growingTextView textInRange:selectedRange];

    if (newText.length < 1)
    {
        // 高亮输入框中的@
        UITextView *textView = self.textView;
        NSRange range = textView.selectedRange;
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:textView.text];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, string.string.length)];
        
        NSArray *matches = [self findAllAt];
        
        for (NSTextCheckingResult *match in matches)
        {
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(match.range.location, match.range.length - 1)];
        }
        
        textView.attributedText = string;
        textView.selectedRange = range;
    }
}
    
- (void)textViewDidChangeSelection:(UITextView *)growingTextView {
//- (void)growingTextViewDidChangeSelection:(HPGrowingTextView *)growingTextView
    // 光标不能点落在@词中间
    NSRange range = growingTextView.selectedRange;
    if (range.length > 0)
    {
        // 选择文本时可以
        return;
    }
    
    NSArray *matches = [self findAllAt];
    
    for (NSTextCheckingResult *match in matches)
    {
        NSRange newRange = NSMakeRange(match.range.location + 1, match.range.length - 1);
        if (NSLocationInRange(range.location, newRange))
        {
            growingTextView.selectedRange = NSMakeRange(match.range.location + match.range.length, 0);
            break;
        }
    }
}




















#pragma mark HNWKeyboardMonitorDelegate
- (void)keyboardMonitor:(HNWKeyboardMonitor *)keyboardMonitor keyboardWillShow:(HNWKeyboardInfo *)info {
    if (@available(iOS 11.0, *)) {
        self.bottomLineConstraintB.constant = -info.keyboardEndFrame.size.height+self.view.safeAreaInsets.bottom;
    } else {
        self.bottomLineConstraintB.constant = -info.keyboardEndFrame.size.height;
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
