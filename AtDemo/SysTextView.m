//
//  SysTextView.m
//  AtDemo
//
//  Created by HN on 2021/4/28.
//

#import "SysTextView.h"
#import "ListViewController.h"
#import "TextViewBinding.h"


@interface SysTextView ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;

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

#pragma mark - UITextViewDelegate
- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSArray *results = [self getResultsListArray:nil];
    BOOL inRange = NO;
//    NSRange tempRange = NSMakeRange(0, 0);
    for (NSInteger i = 0; i < results.count; i++) {
        TextViewBinding *model = results[i];
        NSRange range = model.range;
        if (textView.selectedRange.location > range.location && textView.selectedRange.location < range.location + range.length) {
            inRange = YES;
//            tempRange = range;
            break;
        }
    }
    if (inRange) {
        textView.selectedRange = NSMakeRange(self.cursorLocation, textView.selectedRange.length);
//        NSInteger location = self.cursorLocation-tempRange.length;
//        if (self.cursorLocation<textView.selectedRange.location) {
//            location = self.cursorLocation+tempRange.length;
//        }
//        textView.selectedRange = NSMakeRange(location, textView.selectedRange.length);
        return;
    }
    self.cursorLocation = textView.selectedRange.location;

}

- (void)textViewDidChange:(UITextView *)textView {
    if (_isChanged) {
        NSMutableAttributedString *tmpAString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
        [tmpAString setAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: [UIFont systemFontOfSize:17] } range:_changeRange];
        _textView.attributedText = tmpAString;
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
                    return YES;
                } else {
                    // 第一次点击删除按钮 选中
                    textView.selectedRange = tmpRange;
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
                    _isChanged = YES;
                    return YES;
                }
            }
        } else {
            // 在第一个删除后 重置text color
            if (!range.location) {
                _changeRange = NSMakeRange(range.location, text.length);
                _isChanged = YES;
                return YES;
            }
        }
    }
    return YES;
}

/**
 *  得到数组
 *
 *  @return return value description
 */
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

- (IBAction)onActionGetInfo:(id)sender {
    NSArray *results = [self getResultsListArray:self.textView.attributedText];
    NSLog(@"\n输出打印:");
    for (TextViewBinding *model in results) {
        NSLog(@"user info - name:%@ - location:%ld",model.name, model.range.location);
    }
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

@end
