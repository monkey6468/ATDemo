//
//  ATTextView.m
//  AtDemo
//
//  Created by XWH on 2021/5/12.
//

#import "ATTextView.h"

@interface ATTextView ()<UITextViewDelegate>

@property (assign, nonatomic) NSRange changeRange; /// 改变Range
@property (assign, nonatomic) BOOL isChanged; /// 是否改变

@end

@implementation ATTextView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.font = k_defaultFont;
    self.delegate = self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self awakeFromNib];
    }
    return self;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSArray *results = [self getResultsListArrayWithTextView:textView.attributedText];
    BOOL inRange = NO;
    NSRange tempRange = NSMakeRange(0, 0);
    NSInteger textSelectedLocation = textView.selectedRange.location;
    NSInteger textSelectedLength = textView.selectedRange.length;

    for (NSInteger i = 0; i < results.count; i++) {
        TextViewBinding *bindingModel = results[i];
        NSRange range = bindingModel.range;
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
//        textView.typingAttributes = @{NSFontAttributeName:k_defaultFont,NSForegroundColorAttributeName:k_defaultColor};
        if (_isChanged) {
            NSMutableAttributedString *tmpAString = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
            NSInteger changeLocation = _changeRange.location;
            NSInteger changeLength = _changeRange.length;
            // 修复中文预输入时，删除最后一个崩溃的问题
            if (tmpAString.length == changeLocation) {
                changeLength = 0;
            }
            [tmpAString setAttributes:@{NSForegroundColorAttributeName:k_defaultColor, NSFontAttributeName:k_defaultFont} range:NSMakeRange(changeLocation, changeLength)];
            textView.attributedText = tmpAString;
            _isChanged = NO;
        }
    }
    
    if ([self.atDeleagate respondsToSelector:@selector(atTextViewDidChange:)]) {
        [self.atDeleagate atTextViewDidChange:self];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
   // 解决UITextView富文本编辑会连续的问题，且预输入颜色不变的问题
   if (textView.textStorage.length != 0) {
       textView.typingAttributes = @{NSFontAttributeName:k_defaultFont, NSForegroundColorAttributeName:k_defaultColor};
   }
    
    if ([text isEqualToString:@""]) { // 删除
        NSRange selectedRange = textView.selectedRange;
        if (selectedRange.length) {
            NSMutableAttributedString *tmpAString = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
            [tmpAString deleteCharactersInRange:selectedRange];
            textView.attributedText = tmpAString;
            
            return NO;
        } else {
            NSArray *results = [self getResultsListArrayWithTextView:textView.attributedText];
            for (NSInteger i = 0; i < results.count; i++) {
                TextViewBinding *bindingModel = results[i];
                NSRange tmpRange = bindingModel.range;
                if ((range.location + range.length) == (tmpRange.location + tmpRange.length)) {
                    
                    NSMutableAttributedString *tmpAString = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
                    [tmpAString deleteCharactersInRange:tmpRange];
                    textView.attributedText = tmpAString;
                    
                    return NO;
                }
            }
        }
    } else { // 增加
        NSArray *results = [self getResultsListArrayWithTextView:self.attributedText];
        if ([results count]) {
            for (NSInteger i = 0; i < results.count; i++) {
                TextViewBinding *bindingModel = results[i];
                NSRange tmpRange = bindingModel.range;
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

#pragma mark - other
- (NSArray<TextViewBinding *> *)getResultsListArrayWithTextView:(NSAttributedString *)attributedString {
    __block NSMutableArray *resultArray = [NSMutableArray array];
    NSRegularExpression *iExpression = [NSRegularExpression regularExpressionWithPattern:kATRegular options:0 error:NULL];
    [iExpression enumerateMatchesInString:attributedString.string
                                  options:0
                                    range:NSMakeRange(0, attributedString.string.length)
                               usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange resultRange = result.range;
        NSString *atString = [self.text substringWithRange:result.range];
        TextViewBinding *bindingModel = [attributedString attribute:TextBindingAttributeName atIndex:resultRange.location longestEffectiveRange:&resultRange inRange:NSMakeRange(0, atString.length)];
        if (bindingModel) {
            bindingModel.range = result.range;
            [resultArray addObject:bindingModel];
        }
    }];
    return resultArray;
}

#pragma mark - get data
- (NSArray<TextViewBinding *> *)atUserList {
    NSArray *results = [self getResultsListArrayWithTextView:self.attributedText];
    return results;
}

@end
