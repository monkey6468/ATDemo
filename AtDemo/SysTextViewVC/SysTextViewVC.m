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

- (void)updateUIWithUser:(User *)user {
    NSInteger index = self.textView.text.length;
    if (self.textView.isFirstResponder)
    {
        index = self.textView.selectedRange.location + self.textView.selectedRange.length;
        [self.textView resignFirstResponder];
    }

    NSString *insertText = [NSString stringWithFormat:@"@%@ ", user.name];

    [self.textView insertText:insertText];
    NSMutableAttributedString *tmpAString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    [tmpAString setAttributes: @{NSForegroundColorAttributeName:k_hightColor,
                                 NSFontAttributeName:k_defaultFont}
                        range:NSMakeRange(self.textView.selectedRange.location - insertText.length, insertText.length)];
    // 解决光标在插入‘特殊文本’后 移动到文本最后的问题
    self.textView.attributedText = tmpAString;
    self.textView.selectedRange = NSMakeRange(index + insertText.length, 0);

    self.cursorLocation = self.textView.selectedRange.location;
    
    [self.textView becomeFirstResponder];
}

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
- (void)textViewDidChangeSelection:(UITextView *)growingTextView
{
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

//- (void)textViewDidChangeSelection:(UITextView *)textView {
//    // 光标不能点落在@词中间
//    NSRange range = textView.selectedRange;
//    if (range.length > 0)
//    {
//        // 选择文本时可以
//        return;
//    }
//
//    NSArray *results = [self findAllAt];
//
//    BOOL inRange = NO;
//    NSRange tempRange = NSMakeRange(0, 0);
//    NSInteger textSelectedLocation = textView.selectedRange.location;
//    NSInteger textSelectedLength = textView.selectedRange.length;
//
//    for (NSInteger i = 0; i < results.count; i++) {
//        NSTextCheckingResult *match = results[i];
////        NSRange range = model.range;
//        NSRange range = match.range;
//        if (textSelectedLength == 0) {
//            if (textSelectedLocation > range.location
//                && textSelectedLocation < range.location + range.length) {
//                inRange = YES;
//                tempRange = range;
//                break;
//            }
//        } else {
//            if ((textSelectedLocation > range.location && textSelectedLocation < range.location + range.length)
//                || (textSelectedLocation+textSelectedLength > range.location && textSelectedLocation+textSelectedLength < range.location + range.length)) {
//                inRange = YES;
//                break;
//            }
//        }
//    }
//
//    if (inRange) {
//        // 解决光标在‘特殊文本’左右时 无法左右移动的问题
//        NSInteger location = tempRange.location;
//        if (self.cursorLocation < textSelectedLocation) {
//            location = tempRange.location+tempRange.length;
//        }
//        textView.selectedRange = NSMakeRange(location, textSelectedLength);
//        if (textSelectedLength) { // 解决光标在‘特殊文本’内时，文本选中问题
//            textView.selectedRange = NSMakeRange(textSelectedLocation, 0);
//        }
//    }
//    self.cursorLocation = textView.selectedRange.location;
//}

- (void)textViewDidChange:(UITextView *)growingTextView
{
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

//- (void)textViewDidChange2:(UITextView *)textView {
//    UITextRange *selectedRange = textView.markedTextRange;
//    NSString *newText = [textView textInRange:selectedRange];
//
//    if (newText.length < 1) {
//        // 高亮输入框中的@
//        NSRange range = textView.selectedRange;
//
//        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:textView.text];
//        [string addAttributes:@{NSForegroundColorAttributeName:k_defaultColor,
//                               NSFontAttributeName:k_defaultFont}
//                        range:NSMakeRange(0, string.string.length)];
//
//        NSArray *matches = [self findAllAt];
//
//        for (NSTextCheckingResult *match in matches) {
//            [string addAttributes:@{NSForegroundColorAttributeName:k_hightColor,
//                                   NSFontAttributeName:k_defaultFont}
//                           range:NSMakeRange(match.range.location, match.range.length - 1)];
//        }
//
//        textView.attributedText = string;
//        textView.selectedRange = range;
//    }
//}

- (BOOL)textView:(UITextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
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
}
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    // 解决UITextView富文本编辑会连续的问题，且预输入颜色不变的问题
////    if (textView.textStorage.length != 0) {
////        textView.typingAttributes = @{NSFontAttributeName:k_defaultFont,NSForegroundColorAttributeName:k_defaultColor};
////    }
//
//    if ([text isEqualToString:@""])
//    {
//        NSRange selectRange = textView.selectedRange;
//        if (selectRange.length > 0)
//        {
//            //用户长按选择文本时不处理
//            return YES;
//        }
//
//        // 判断删除的是一个@中间的字符就整体删除
//        NSMutableString *string = [NSMutableString stringWithString:textView.text];
//        NSArray *matches = [self findAllAt];
//
//        BOOL inAt = NO;
//        NSInteger index = range.location;
//        for (NSTextCheckingResult *match in matches) {
//            NSRange newRange = NSMakeRange(match.range.location + 1, match.range.length - 1);
//            if (NSLocationInRange(range.location, newRange)) {
//                inAt = YES;
//                index = match.range.location;
//                [string replaceCharactersInRange:match.range withString:@""];
//                break;
//            }
//        }
//
//        if (inAt) {
//            textView.text = string;
//            textView.selectedRange = NSMakeRange(index, 0);
//            return NO;
//        }
//    }
//
//    //判断是回车键就发送出去
//    if ([text isEqualToString:@"\n"])
//    {
//        [self done];
//        return NO;
//    }
//
//    return YES;
//}

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
