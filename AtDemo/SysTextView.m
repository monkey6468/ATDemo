//
//  SysTextView.m
//  AtDemo
//
//  Created by HN on 2021/4/28.
//

#import "SysTextView.h"
#import "ListViewController.h"

@interface SysTextView ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *topicTextView;
@property (copy, nonatomic) NSString *topicString;

/// 改变Range
@property (assign, nonatomic) NSRange changeRange;
/// 是否改变
@property (assign, nonatomic) BOOL isChanged;
/// 光标位置
@property (assign, nonatomic) NSInteger cursorLocation;

@end

@implementation SysTextView

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UITextView Delegate
- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSArray *rangeArray = [self getTopicRangeArray:nil];
    BOOL inRange = NO;
    for (NSInteger i = 0; i < rangeArray.count; i++) {
        NSRange range = NSRangeFromString(rangeArray[i]);
        if (textView.selectedRange.location > range.location && textView.selectedRange.location < range.location + range.length) {
            inRange = YES;
            break;
        }
    }
    if (inRange) {
        textView.selectedRange = NSMakeRange(self.cursorLocation, textView.selectedRange.length);
        return;
    }
    self.cursorLocation = textView.selectedRange.location;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (_isChanged) {
        NSMutableAttributedString *tmpAString = [[NSMutableAttributedString alloc] initWithAttributedString:self.topicTextView.attributedText];
        [tmpAString setAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: [UIFont systemFontOfSize:17] } range:_changeRange];
        _topicTextView.attributedText = tmpAString;
        _isChanged = NO;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@""]) { // 删除
        NSArray *rangeArray = [self getTopicRangeArray:nil];
        for (NSInteger i = 0; i < rangeArray.count; i++) {
            NSRange tmpRange = NSRangeFromString(rangeArray[i]);
            if ((range.location + range.length) == (tmpRange.location + tmpRange.length)) {
                if ([NSStringFromRange(tmpRange) isEqualToString:NSStringFromRange(textView.selectedRange)]) {
                    // 第二次点击删除按钮 删除
                    return YES;
                } else {
                    // 第一次点击删除按钮 选中
                    textView.selectedRange = tmpRange;
                    return NO;
                }
            }
        }
    } else { // 增加
        NSArray *rangeArray = [self getTopicRangeArray:nil];
        if ([rangeArray count]) {
            for (NSInteger i = 0; i < rangeArray.count; i++) {
                NSRange tmpRange = NSRangeFromString(rangeArray[i]);
                if ((range.location + range.length) == (tmpRange.location + tmpRange.length) || !range.location) {
                    _changeRange = NSMakeRange(range.location, text.length);
                    _isChanged = YES;
                    return YES;
                }
            }
        } else {
            // 话题在第一个删除后 重置text color
            if (!range.location) {
                _changeRange = NSMakeRange(range.location, text.length);
                _isChanged = YES;
                return YES;
            }
        }
    }
    return YES;
}


- (void)setTextViewAttributed {
    NSMutableArray *indexArray = [NSMutableArray array];
    for (NSInteger i = 0; i < self.topicTextView.text.length; i++) {
        NSString *indexString = [self.topicTextView.text substringWithRange:NSMakeRange(i, 1)];
        if ([indexString isEqualToString:self.topicString]) {
            [indexArray addObject:@(i)];
        }
    }
    // reset
    NSMutableAttributedString *aText = [[NSMutableAttributedString alloc] initWithString:self.topicTextView.text];
    self.topicTextView.attributedText = aText;
    self.topicTextView.font = [UIFont systemFontOfSize:16.0];

    // change
    if (indexArray.count > 1) {
        NSMutableAttributedString *aText = [[NSMutableAttributedString alloc] initWithString:self.topicTextView.text];
        for (NSInteger i = 0; i < indexArray.count; i++) {
            NSInteger index1 = [indexArray[i] integerValue];
            NSInteger index2 = 0;
            if ((i + 1) < indexArray.count) {
                index2 = [indexArray[i + 1] integerValue];
            }
            if (index2 - index1 > 1) {
                // 多余中间有值才显示
                [aText setAttributes:@{ NSForegroundColorAttributeName: UIColor.redColor } range:NSMakeRange(index1, index2 - index1 + 1)];
                ++i;
            }
        }
        self.topicTextView.attributedText = aText;
        self.topicTextView.font = [UIFont systemFontOfSize:16.0];
    }
}

/**
 *  得到话题Range数组
 *
 *  @return return value description
 */
- (NSArray *)getTopicRangeArray:(NSAttributedString *)attributedString {
    NSAttributedString *traveAStr = attributedString ?: self.topicTextView.attributedText;
    __block NSMutableArray *rangeArray = [NSMutableArray array];
    static NSRegularExpression *iExpression;
    iExpression = iExpression ?: [NSRegularExpression regularExpressionWithPattern:@"#(.*?)#" options:0 error:NULL];
    [iExpression enumerateMatchesInString:traveAStr.string
                                  options:0
                                    range:NSMakeRange(0, traveAStr.string.length)
                               usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange resultRange = result.range;
        NSDictionary *attributedDict = [traveAStr attributesAtIndex:resultRange.location effectiveRange:&resultRange];
        if ([attributedDict[NSForegroundColorAttributeName] isEqual:UIColor.redColor]) {
            [rangeArray addObject:NSStringFromRange(result.range)];
        }
    }];
    return rangeArray;
}
- (IBAction)onActionGetInfo:(id)sender {
    NSArray *results = [self getTopicRangeArray:self.topicTextView.attributedText];
    NSLog(@"输出打印:\n");
    for (id obj in results) {
        NSLog(@"%@",obj);
    }
    NSLog(@"\n\n");
}

- (IBAction)onActionInsert:(UIButton *)sender {
    ListViewController *vc = [[ListViewController alloc]init];
    [self presentViewController:vc animated:NO completion:nil];
    vc.block = ^(NSInteger index, User * _Nonnull user) {
        
        NSString *insertText = [NSString stringWithFormat:@"#%@#", user.name];
        [self.topicTextView insertText:insertText];
        NSMutableAttributedString *tmpAString = [[NSMutableAttributedString alloc] initWithAttributedString:self.topicTextView.attributedText];
        [tmpAString setAttributes:@{ NSForegroundColorAttributeName: UIColor.redColor, NSFontAttributeName: [UIFont systemFontOfSize:17] } range:NSMakeRange(self.topicTextView.selectedRange.location - insertText.length, insertText.length)];
        self.topicTextView.attributedText = tmpAString;
        
    };
}
@end
