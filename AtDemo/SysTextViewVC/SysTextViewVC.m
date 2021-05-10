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

#define k_defaultFont   [UIFont systemFontOfSize:17]
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
@property (strong, nonatomic) NSMutableArray *userListArray;

/// 改变Range
@property (assign, nonatomic) NSRange changeRange;
/// 是否改变
@property (assign, nonatomic) BOOL isChanged;

@end

@implementation SysTextViewVC

#pragma mark - life
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"TextViewVC";
    
    self.userListArray = [NSMutableArray array];
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
- (NSArray<TextViewBinding *> *)getResultsListArray:(NSAttributedString *)attributedString {
    __block NSAttributedString *traveAStr = attributedString ?: self.textView.attributedText;
    __block NSMutableArray *rangeArray = [NSMutableArray array];
    static NSRegularExpression *iExpression;
    iExpression = iExpression ?: [NSRegularExpression regularExpressionWithPattern:kATRegular options:0 error:NULL];
    [iExpression enumerateMatchesInString:traveAStr.string
                                  options:0
                                    range:NSMakeRange(0, traveAStr.string.length)
                               usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange resultRange = result.range;
        NSString *ss = [self.textView.text substringWithRange:result.range];
        NSLog(@"xwh: %@", ss);
        NSDictionary *attributedDict = [traveAStr attributesAtIndex:resultRange.location effectiveRange:&resultRange];
        if ([attributedDict[NSForegroundColorAttributeName] isEqual:UIColor.redColor]) {
            TextViewBinding *bindingModel = [traveAStr attribute:@"test" atIndex:resultRange.location longestEffectiveRange:&resultRange inRange:NSMakeRange(0, ss.length)];
            bindingModel.range = result.range;
            [rangeArray addObject:NSStringFromRange(result.range)];
        }
    }];
    return rangeArray;
}

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

- (void)updateUIWithUser:(User *)user
{
    
    NSString *insertText = [NSString stringWithFormat:@"@%@ ", user.name];
    TextViewBinding *bindingModel = [[TextViewBinding alloc]initWithName:user.name
                                                                  userId:user.userId];

    [self.textView insertText:insertText];
    NSMutableAttributedString *tmpAString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    NSRange range = NSMakeRange(self.textView.selectedRange.location - insertText.length, insertText.length);
    [tmpAString setAttributes:@{NSForegroundColorAttributeName:k_hightColor,
                                NSFontAttributeName:k_defaultFont,
                                @"test":bindingModel}
                        range:range];
    user.range = range;
    [self.userListArray addObject:user];

    // 解决光标在插入‘特殊文本’后 移动到文本最后的问题
    NSInteger lastCursorLocation = self.cursorLocation;
    self.textView.attributedText = tmpAString;
    self.textView.selectedRange = NSMakeRange(lastCursorLocation, self.textView.selectedRange.length);
    self.cursorLocation = lastCursorLocation;
}

- (void)done {
    [self.view endEditing:YES];
    
    NSArray *results = [self getResultsListArray:self.textView.attributedText];
    NSLog(@"输出打印:");

    NSMutableArray *data = [NSMutableArray array];
    for (id obj in results) {
        NSRange range = NSRangeFromString(obj);
        NSString *name = [self.textView.text substringWithRange:range];
        
        for (User *user in self.userListArray) {
            NSString *insertText = [NSString stringWithFormat:@"@%@ ", user.name];
            if ([name isEqualToString:insertText]) {
                NSMutableDictionary *dictInfo = [NSMutableDictionary dictionary];
                dictInfo[@"range"] = obj;
                dictInfo[@"name"] = user.name;
                
                [data addObject:dictInfo];
                NSLog(@"%@",dictInfo);
            }
        }
    }
    
    NSArray *newdata = [data valueForKeyPath:@"@distinctUnionOfObjects.self"];

    NSLog(@"\n\n：%@",newdata);
    
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
- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSArray *results = [self getResultsListArray:nil];
    BOOL inRange = NO;
    NSRange tempRange = NSMakeRange(0, 0);
    NSInteger textSelectedLocation = textView.selectedRange.location;
    NSInteger textSelectedLength = textView.selectedRange.length;

    for (NSInteger i = 0; i < results.count; i++) {
        NSRange range = NSRangeFromString(results[i]);
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
//    if (!textView.markedTextRange) {
//        textView.typingAttributes = @{NSFontAttributeName:k_defaultFont,NSForegroundColorAttributeName:k_defaultColor};
//    }
    if (_isChanged) {
        NSMutableAttributedString *tmpAString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
        [tmpAString setAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: [UIFont systemFontOfSize:17] } range:_changeRange];
        _textView.attributedText = tmpAString;
        _isChanged = NO;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
   // 解决UITextView富文本编辑会连续的问题，且预输入颜色不变的问题
   if (textView.textStorage.length != 0) {
       textView.typingAttributes = @{NSFontAttributeName:k_defaultFont,NSForegroundColorAttributeName:k_defaultColor};
   }
    
    if ([text isEqualToString:@""]) { // 删除
        NSArray *rangeArray = [self getResultsListArray:nil];
        for (NSInteger i = 0; i < rangeArray.count; i++) {
            NSRange tmpRange = NSRangeFromString(rangeArray[i]);
            if ((range.location + range.length) == (tmpRange.location + tmpRange.length)) {
                // 第一次点击删除按钮 选中
                NSMutableAttributedString *tmpAString = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
                [tmpAString deleteCharactersInRange:tmpRange];
                textView.attributedText = tmpAString;
                
                [self updateUI];
                return NO;
            }
        }
    } else { // 增加
        NSArray *rangeArray = [self getResultsListArray:nil];
        if ([rangeArray count]) {
            for (NSInteger i = 0; i < rangeArray.count; i++) {
                NSRange tmpRange = NSRangeFromString(rangeArray[i]);
                if ((range.location + range.length) == (tmpRange.location + tmpRange.length) || !range.location) {
                    _changeRange = NSMakeRange(range.location, text.length);
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
