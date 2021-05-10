//
//  SysTextViewVC.m
//  AtDemo
//
//  Created by XWH on 2021/4/20.
//

#import "SysTextViewVC.h"
#import "ListViewController.h"

#import "TableViewCell.h"

#import "TextViewBinding.h"

#import "HNWKeyboardMonitor.h"

#define k_defaultFont   [UIFont systemFontOfSize:17]
#define k_defaultColor  [UIColor blackColor]
#define k_hightColor    [UIColor redColor]

@interface SysTextViewVC ()<UITextViewDelegate, HNWKeyboardMonitorDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

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
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
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
    if (h <= 44) {
        h = 44;
    }
    self.textViewConstraintH.constant = h;
}

#pragma mark - other
- (NSArray<TextViewBinding *> *)getResultsListArray:(NSAttributedString *)attributedString {
    NSAttributedString *traveAStr = attributedString ?: self.textView.attributedText;
    __block NSMutableArray *results = [NSMutableArray array];
    [traveAStr enumerateAttributesInRange:NSMakeRange(0, traveAStr.length)
                                  options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                               usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        if (attrs[TextBindingAttributeName]) {
            TextViewBinding *bingdingModel = attrs[TextBindingAttributeName];
            bingdingModel.range = range;
            [results addObject:bingdingModel];
        }
    }];
    return results;
}

- (IBAction)onActionInsert:(UIButton *)sender {
    ListViewController *vc = [[ListViewController alloc]init];
    [self presentViewController:vc animated:NO completion:nil];
    
    __weak typeof(self) weakSelf = self;
    vc.block = ^(NSInteger index, User * _Nonnull user) {
        [weakSelf updateUIWithUser:user];
    };
}

- (void)updateUIWithUser:(User *)user
{
    NSString *insertText = [NSString stringWithFormat:@"@%@ ", user.name];
    TextViewBinding *bindingModel = [[TextViewBinding alloc]initWithName:user.name
                                                                  userId:user.userId];
    
    [self.textView insertText:insertText];
    NSMutableAttributedString *tmpAString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    [tmpAString setAttributes: @{NSForegroundColorAttributeName:k_hightColor,
                                 NSFontAttributeName:k_defaultFont,
                                 TextBindingAttributeName:bindingModel}
                        range:NSMakeRange(self.textView.selectedRange.location - insertText.length, insertText.length)];
    // 解决光标在插入‘特殊文本’后 移动到文本最后的问题
    NSInteger lastCursorLocation = self.cursorLocation;
    self.textView.attributedText = tmpAString;
    self.textView.selectedRange = NSMakeRange(lastCursorLocation, self.textView.selectedRange.length);
    self.cursorLocation = lastCursorLocation;
}

- (void)done {
    [self.view endEditing:YES];
    
    NSArray *results = [self getResultsListArray:self.textView.attributedText];
    NSLog(@"\n输出打印:");
    for (TextViewBinding *model in results) {
        NSLog(@"user info - name:%@ - location:%ld",model.name, model.range.location);
    }
    
    DataModel *model = [[DataModel alloc]init];
    model.userList = results;
    model.text = self.textView.text;
    [self.dataArray addObject:model];
    
    self.textView.text = nil;
    [self updateUI];

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
- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSArray *results = [self getResultsListArray:nil];
    BOOL inRange = NO;
    NSRange tempRange = NSMakeRange(0, 0);
    NSInteger textSelectedLocation = textView.selectedRange.location;
    NSInteger textSelectedLength = textView.selectedRange.length;
    
    for (NSInteger i = 0; i < results.count; i++) {
        TextViewBinding *model = results[i];
        NSRange range = model.range;
        if (textSelectedLength == 0) {
            if (textSelectedLocation > range.location
                && textSelectedLocation < range.location + range.length) {
                inRange = YES;
                tempRange = range;
                break;
            }
        } else {
            if ((textSelectedLocation > range.location && textSelectedLocation < range.location + range.length)
                || (textSelectedLocation+textSelectedLength > range.location && textSelectedLocation+textSelectedLength < range.location + range.length)) {
                inRange = YES;
                break;
            }
        }
    }
    
    if (inRange) {
        // 解决光标在‘特殊文本’左右时 无法左右移动的问题
        NSInteger location = tempRange.location;
        if (self.cursorLocation < textSelectedLocation) {
            location = tempRange.location+tempRange.length;
        }
        textView.selectedRange = NSMakeRange(location, textSelectedLength);
        if (textSelectedLength) { // 解决光标在‘特殊文本’内时，文本选中问题
            textView.selectedRange = NSMakeRange(textSelectedLocation, 0);
        }
    }
    self.cursorLocation = textView.selectedRange.location;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (!textView.markedTextRange) {
        textView.typingAttributes = @{NSFontAttributeName:k_defaultFont,NSForegroundColorAttributeName:k_defaultColor};
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // 解决UITextView富文本编辑会连续的问题，且预输入颜色不变的问题
    if (textView.textStorage.length != 0) {
        textView.typingAttributes = @{NSFontAttributeName:k_defaultFont,NSForegroundColorAttributeName:k_defaultColor};
    }
    
    if ([text isEqualToString:@""]) { // 删除
        NSArray *results = [self getResultsListArray:nil];
        for (NSInteger i = 0; i < results.count; i++) {
            TextViewBinding *model = results[i];
            NSRange tmpRange = model.range;
            if ((range.location + range.length) == (tmpRange.location + tmpRange.length)) {
                if ([NSStringFromRange(tmpRange) isEqualToString:NSStringFromRange(textView.selectedRange)]) {
                    // 第二次点击删除按钮 删除
                    [self updateUI];
                    return YES;
                } else {
                    // 第一次点击删除按钮 选中
                    textView.selectedRange = tmpRange;
                    [self updateUI];
                    return NO;
                }
            }
        }
    }
    
    [self updateUI];
    return YES;
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
