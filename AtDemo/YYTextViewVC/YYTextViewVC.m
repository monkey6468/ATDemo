//
//  YYTextViewVC.m
//  AtDemo
//
//  Created by XWH on 2021/4/20.
//

#import "YYTextViewVC.h"
#import "ListViewController.h"

#import "YYTextViewCell.h"

#import "TextViewBinding.h"

#import "HNWKeyboardMonitor.h"

@interface YYTextViewVC ()<UITextViewDelegate, HNWKeyboardMonitorDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yyTextViewConstraintH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineConstraintB;

/// 改变Range
@property (assign, nonatomic) NSRange changeRange;
/// 是否改变
@property (assign, nonatomic) BOOL isChanged;
/// 光标位置
@property (assign, nonatomic) NSInteger cursorLocation;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (assign, nonatomic) BOOL bInsert; // 插入
@end

@implementation YYTextViewVC

#pragma mark - life
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"YYTextViewVC";
    
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
    
    self.textView.font = [UIFont systemFontOfSize:17];
    [self.textView becomeFirstResponder];
}

- (void)initTableView {
    self.tableView.tableFooterView = UIView.new;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([YYTextViewCell class])
                                               bundle:nil]
         forCellReuseIdentifier:NSStringFromClass(YYTextViewCell.class)];
}

- (void)updateUI {
    CGRect frame = [self.textView.attributedText boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-85, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGFloat h = frame.size.height;
    if (h <= 44) {
        h = 44;
    }
    self.yyTextViewConstraintH.constant = h;
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
    vc.block = ^(NSInteger index, User * _Nonnull user) {
        
        NSString *insertText = [NSString stringWithFormat:@"@%@ ", user.name];
        TextViewBinding *topicBinding = [[TextViewBinding alloc]initWithName:user.name
                                                                      userId:user.userId];
        
        [self.textView insertText:insertText];
        NSMutableAttributedString *tmpAString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
        [tmpAString setAttributes: @{NSForegroundColorAttributeName: UIColor.redColor,
                                     NSFontAttributeName : [UIFont systemFontOfSize:17],
                                     TextBindingAttributeName:topicBinding }
                            range:NSMakeRange(self.textView.selectedRange.location - insertText.length, insertText.length)];
        self.textView.attributedText = tmpAString;

    };
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
    return [YYTextViewCell rowHeightWithModel:model];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YYTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(YYTextViewCell.class)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSArray *results = [self getResultsListArray:nil];
    BOOL inRange = NO;
    NSRange tempRange = NSMakeRange(0, 0);
    for (NSInteger i = 0; i < results.count; i++) {
        TextViewBinding *model = results[i];
        NSRange range = model.range;
        if (textView.selectedRange.location > range.location
            && textView.selectedRange.location < range.location + range.length) {
            inRange = YES;
            tempRange = range;
            break;
        }
    }
    if (inRange) {
        // 解决光标在‘特殊文本’左右时 无法左右移动的问题
        NSInteger location = self.cursorLocation-tempRange.length;
        if (self.cursorLocation<textView.selectedRange.location) {
            location = self.cursorLocation+tempRange.length;
        }
        textView.selectedRange = NSMakeRange(location, textView.selectedRange.length);
    }
    self.cursorLocation = textView.selectedRange.location;

}

- (void)textViewDidChange:(UITextView *)textView {
    if (_isChanged) {
        NSMutableAttributedString *tmpAString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
        [tmpAString setAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: [UIFont systemFontOfSize:17] } range:_changeRange];
        _textView.attributedText = tmpAString;
        if (_bInsert) {
            // 解决光标在‘特殊文本’之后 插入文本 移动到文本最后的问题
            _textView.selectedRange = NSMakeRange(_changeRange.location+_changeRange.length, self.textView.selectedRange.length);
            self.bInsert = NO;
        }
        _isChanged = NO;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
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
    } else { // 增加
        NSArray *results = [self getResultsListArray:nil];
        if ([results count]) {
            for (NSInteger i = 0; i < results.count; i++) {
                TextViewBinding *model = results[i];
                NSRange tmpRange = model.range;
                if ((range.location + range.length) == (tmpRange.location + tmpRange.length) || !range.location) {
                    _changeRange = NSMakeRange(range.location, text.length);
                    
                    _bInsert = YES;
                    _isChanged = YES;
                    [self updateUI];
                    return YES;
                }
            }
        } else {
            // 在第一个删除后 重置text color
            if (!range.location) {
                _changeRange = NSMakeRange(range.location, text.length);
                _isChanged = YES;
                [self updateUI];
                return YES;
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
