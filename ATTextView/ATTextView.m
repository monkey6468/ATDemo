//
//  ATTextView.m
//  AtDemo
//
//  Created by XWH on 2021/5/12.
//

#import "ATTextView.h"

#define kTopY 7.0
#define kLeftX 5.0

@interface ATTextView ()<UITextViewDelegate>

@property (assign, nonatomic) NSRange changeRange; /// 改变Range
@property (assign, nonatomic) BOOL isChanged; /// 是否改变

@property (strong, nonatomic) UIColor *placeholder_color;
@property (strong, nonatomic) UIFont *placeholder_font;
@property (strong, nonatomic, readonly) UILabel *placeholderLabel; // 显示 Placeholder

@property(assign, nonatomic) float placeholdeWidth;

@end

@implementation ATTextView

#pragma mark - life
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.font = k_defaultFont;
    self.delegate = self;
    
    [self setttingUI];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self awakeFromNib];
    }
    return self;
}

- (void)setttingUI {
    float left=kLeftX,top=kTopY,hegiht=30;
    
    self.placeholdeWidth=CGRectGetWidth(self.frame)-2*left;
    
    _placeholderLabel=[[UILabel alloc] initWithFrame:CGRectMake(left, top
                                                                , _placeholdeWidth, hegiht)];
   
    _placeholderLabel.numberOfLines=0;
    _placeholderLabel.lineBreakMode=NSLineBreakByCharWrapping|NSLineBreakByWordWrapping;
    [self addSubview:_placeholderLabel];
    
    
    [self defaultConfig];

}

- (void)layoutSubviews {
    float left=kLeftX,top=kTopY,hegiht=self.bounds.size.height;
    self.placeholdeWidth=CGRectGetWidth(self.frame)-2*left;
    CGRect frame=_placeholderLabel.frame;
    frame.origin.x=left;
    frame.origin.y=top;
    frame.size.height=hegiht;
    frame.size.width=self.placeholdeWidth;
    _placeholderLabel.frame=frame;
    
    [_placeholderLabel sizeToFit];
}

- (void)dealloc {
    [_placeholderLabel removeFromSuperview];
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
    [self updateChangeTextView];
    
    if (!textView.markedTextRange) {
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
            
            [self textViewDidChange:textView];
            textView.typingAttributes = @{NSFontAttributeName:k_defaultFont,NSForegroundColorAttributeName:k_defaultColor};
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
                    
                    [self textViewDidChange:textView];
                    textView.typingAttributes = @{NSFontAttributeName:k_defaultFont,NSForegroundColorAttributeName:k_defaultColor};
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


- (void)updateChangeTextView {
    if (self.placeholder.length == 0 || [self.placeholder isEqualToString:@""]) {
        _placeholderLabel.hidden=YES;
    }
    
    if (self.text.length > 0) {
        _placeholderLabel.hidden=YES;
    }
    else{
        _placeholderLabel.hidden=NO;
    }
    
    NSString *lang = [[self.nextResponder textInputMode] primaryLanguage]; // 键盘输入模式
    
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [self markedTextRange];
        //获取高亮部分
        UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (self.text.length > self.maxTextLength) {
                self.text = [self.text substringToIndex:self.maxTextLength];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (self.text.length > self.maxTextLength) {
             self.text = [ self.text substringToIndex:self.maxTextLength];
        }
    }
    
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

#pragma mark - set data
- (void)defaultConfig {
    self.placeholder_color = [UIColor lightGrayColor];
    self.placeholder_font = k_defaultFont;
    self.maxTextLength = 1000;
    self.layoutManager.allowsNonContiguousLayout = NO;
}

- (void)setText:(NSString *)tex {
    if (tex.length>0) {
        _placeholderLabel.hidden=YES;
    }
    [super setText:tex];
}

- (void)setPlaceholder:(NSString *)placeholder{
    if (placeholder.length == 0 || [placeholder isEqualToString:@""]) {
        _placeholderLabel.hidden = YES;
    } else {
        _placeholderLabel.text = placeholder;
        _placeholder = placeholder;
    }
}

- (void)setPlaceholder_font:(UIFont *)placeholder_font {
    _placeholder_font = placeholder_font;
    _placeholderLabel.font = placeholder_font;
}

- (void)setPlaceholder_color:(UIColor *)placeholder_color {
    _placeholder_color = placeholder_color;
    _placeholderLabel.textColor = placeholder_color;
}


//供外部使用的 api
- (void)setPlaceholderFont:(UIFont *)font {
   self.placeholder_font = font;
}

- (void)setPlaceholderColor:(UIColor *)color {
   self.placeholder_color=color;
}

- (void)setPlaceholderOpacity:(CGFloat)opacity {
   if (opacity<0) {
       opacity=1;
   }
   self.placeholderLabel.layer.opacity=opacity;
}

@end
