//
//  ATTextView.m
//  AtDemo
//
//  Created by XWH on 2021/5/12.
//

#import "ATTextView.h"

#define kATRegular                      @"@[\\u4e00-\\u9fa5\\w\\-\\_]+ "
#define kTopicRegular                   @"#(.*?)#+ "
#define kAT                             @"@"
#define kTopic                          @"#"

#define HAS_TEXT_CONTAINER [self respondsToSelector:@selector(textContainer)]
#define HAS_TEXT_CONTAINER_INSETS(x) [(x) respondsToSelector:@selector(textContainerInset)]

static NSString * const kAttributedPlaceholderKey = @"attributedPlaceholder";
static NSString * const kPlaceholderKey = @"placeholder";
static NSString * const kFontKey = @"font";
static NSString * const kAttributedTextKey = @"attributedText";
static NSString * const kTextKey = @"text";
static NSString * const kExclusionPathsKey = @"exclusionPaths";
static NSString * const kLineFragmentPaddingKey = @"lineFragmentPadding";
static NSString * const kTextContainerInsetKey = @"textContainerInset";
static NSString * const kTextAlignmentKey = @"textAlignment";

@interface ATTextView () <UITextViewDelegate>

@property (assign, nonatomic) NSInteger cursorLocation; /// 光标位置

@property (strong, nonatomic) UITextView *placeholderTextView;
@property (assign, nonatomic) NSInteger max_TextLength;
@property (strong, nonatomic) UIColor *attributed_TextColor;

@property (nonatomic, assign) ATTextViewBindingType type;

@end

@implementation ATTextView

#pragma mark - life
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.maxTextLength = 100000;
    self.attributed_TextColor = UIColor.blackColor;
    self.hightTextColor = UIColor.redColor;
    self.bSupport = YES;
    self.delegate = self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self awakeFromNib];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self preparePlaceholder];
    }
    return self;
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [self preparePlaceholder];
    }
    return self;
}
#else
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self preparePlaceholder];
    }
    return self;
}
#endif

- (void)preparePlaceholder
{
    NSAssert(!self.placeholderTextView, @"placeholder has been prepared already: %@", self.placeholderTextView);
    // the label which displays the placeholder
    // needs to inherit some properties from its parent text view

    // account for standard UITextViewPadding

    CGRect frame = self.bounds;
    self.placeholderTextView = [[UITextView alloc] initWithFrame:frame];
    self.placeholderTextView.opaque = NO;
    self.placeholderTextView.backgroundColor = [UIColor clearColor];
    self.placeholderTextView.textColor = [UIColor colorWithWhite:0.7f alpha:0.7f];
    self.placeholderTextView.textAlignment = self.textAlignment;
    self.placeholderTextView.editable = NO;
    self.placeholderTextView.scrollEnabled = NO;
    self.placeholderTextView.userInteractionEnabled = NO;
    self.placeholderTextView.font = self.font;
    self.placeholderTextView.isAccessibilityElement = NO;
    self.placeholderTextView.contentOffset = self.contentOffset;
    self.placeholderTextView.contentInset = self.contentInset;

    if ([self.placeholderTextView respondsToSelector:@selector(setSelectable:)]) {
        self.placeholderTextView.selectable = NO;
    }

    if (HAS_TEXT_CONTAINER) {
        self.placeholderTextView.textContainer.exclusionPaths = self.textContainer.exclusionPaths;
        self.placeholderTextView.textContainer.lineFragmentPadding = self.textContainer.lineFragmentPadding;
    }

    if (HAS_TEXT_CONTAINER_INSETS(self)) {
        self.placeholderTextView.textContainerInset = self.textContainerInset;
    }

    if (_attributedPlaceholder) {
        self.placeholderTextView.attributedText = _attributedPlaceholder;
    } else if (_placeholder) {
        self.placeholderTextView.text = _placeholder;
    }

    [self setPlaceholderVisibleForText:self.text];

    self.clipsToBounds = YES;

    // some observations
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(textDidChange:)
                          name:UITextViewTextDidChangeNotification object:self];

    [self addObserver:self forKeyPath:kAttributedPlaceholderKey
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kPlaceholderKey
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kFontKey
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kAttributedTextKey
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kTextKey
              options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kTextAlignmentKey
              options:NSKeyValueObservingOptionNew context:nil];

    if (HAS_TEXT_CONTAINER) {
        [self.textContainer addObserver:self forKeyPath:kExclusionPathsKey
                                options:NSKeyValueObservingOptionNew context:nil];
        [self.textContainer addObserver:self forKeyPath:kLineFragmentPaddingKey
                                options:NSKeyValueObservingOptionNew context:nil];
    }

    if (HAS_TEXT_CONTAINER_INSETS(self)) {
        [self addObserver:self forKeyPath:kTextContainerInsetKey
                  options:NSKeyValueObservingOptionNew context:nil];
    }
}

#pragma mark - other limt length
- (BOOL)checkAndFilterTextByLength:(NSInteger)limitMaxLength {
    BOOL beyondLimits = NO;
    
    if (self && limitMaxLength > 0) {
        NSAttributedString *oldText = self.attributedText;
        // 没有标记的文本，则对已输入的文字进行字数统计和限制
        if (!self.markedTextRange && oldText.length > limitMaxLength) {
            beyondLimits = YES;
            self.attributedText = [oldText attributedSubstringFromRange:NSMakeRange(0, limitMaxLength)];
        }
    }
    
    return beyondLimits;
}

- (void)setPlaceholder:(NSString *)placeholderText
{
    _placeholder = [placeholderText copy];
    _attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderText];

    [self resizePlaceholderFrame];
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholderText
{
    _placeholder = attributedPlaceholderText.string;
    _attributedPlaceholder = [attributedPlaceholderText copy];

    [self resizePlaceholderFrame];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self resizePlaceholderFrame];
}

- (void)resizePlaceholderFrame
{
    CGRect frame = self.placeholderTextView.frame;
    frame.size = self.bounds.size;
    self.placeholderTextView.frame = frame;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:kAttributedPlaceholderKey]) {
        self.placeholderTextView.attributedText = [change valueForKey:NSKeyValueChangeNewKey];
    }
    else if ([keyPath isEqualToString:kPlaceholderKey]) {
        self.placeholderTextView.text = [change valueForKey:NSKeyValueChangeNewKey];
    }
    else if ([keyPath isEqualToString:kFontKey]) {
        self.placeholderTextView.font = [change valueForKey:NSKeyValueChangeNewKey];
    }
    else if ([keyPath isEqualToString:kAttributedTextKey]) {
        NSAttributedString *newAttributedText = [change valueForKey:NSKeyValueChangeNewKey];
        [self setPlaceholderVisibleForText:newAttributedText.string];
    }
    else if ([keyPath isEqualToString:kTextKey]) {
        NSString *newText = [change valueForKey:NSKeyValueChangeNewKey];
        [self setPlaceholderVisibleForText:newText];
    }
    else if ([keyPath isEqualToString:kExclusionPathsKey]) {
        self.placeholderTextView.textContainer.exclusionPaths = [change objectForKey:NSKeyValueChangeNewKey];
        [self resizePlaceholderFrame];
    }
    else if ([keyPath isEqualToString:kLineFragmentPaddingKey]) {
        self.placeholderTextView.textContainer.lineFragmentPadding = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        [self resizePlaceholderFrame];
    }
    else if ([keyPath isEqualToString:kTextContainerInsetKey]) {
        NSValue *value = [change objectForKey:NSKeyValueChangeNewKey];
        self.placeholderTextView.textContainerInset = value.UIEdgeInsetsValue;
    }
    else if ([keyPath isEqualToString:kTextAlignmentKey]) {
        NSNumber *alignment = [change objectForKey:NSKeyValueChangeNewKey];
        self.placeholderTextView.textAlignment = alignment.intValue;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor
{
    self.placeholderTextView.textColor = placeholderTextColor;
}

- (UIColor *)placeholderTextColor
{
    return self.placeholderTextView.textColor;
}

- (void)textDidChange:(NSNotification *)aNotification
{
    [self setPlaceholderVisibleForText:self.text];
}

- (BOOL)becomeFirstResponder
{
    [self setPlaceholderVisibleForText:self.text];

    return [super becomeFirstResponder];
}

- (void)setPlaceholderVisibleForText:(NSString *)text
{
    if (text.length < 1) {
        if (self.fadeTime > 0.0) {
            if (![self.placeholderTextView isDescendantOfView:self]) {
                self.placeholderTextView.alpha = 0;
                [self addSubview:self.placeholderTextView];
                [self sendSubviewToBack:self.placeholderTextView];
            }
            [UIView animateWithDuration:_fadeTime animations:^{
                self.placeholderTextView.alpha = 1;
            }];
        }
        else {
            [self addSubview:self.placeholderTextView];
            [self sendSubviewToBack:self.placeholderTextView];
            self.placeholderTextView.alpha = 1;
        }
    }
    else {
        if (self.fadeTime > 0.0) {
            [UIView animateWithDuration:_fadeTime animations:^{
                self.placeholderTextView.alpha = 0;
            }];
        }
        else {
            [self.placeholderTextView removeFromSuperview];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:kAttributedPlaceholderKey];
    [self removeObserver:self forKeyPath:kPlaceholderKey];
    [self removeObserver:self forKeyPath:kFontKey];
    [self removeObserver:self forKeyPath:kAttributedTextKey];
    [self removeObserver:self forKeyPath:kTextKey];
    [self removeObserver:self forKeyPath:kTextAlignmentKey];

    if (HAS_TEXT_CONTAINER) {
        [self.textContainer removeObserver:self forKeyPath:kExclusionPathsKey];
        [self.textContainer removeObserver:self forKeyPath:kLineFragmentPaddingKey];
    }

    if (HAS_TEXT_CONTAINER_INSETS(self)) {
        [self removeObserver:self forKeyPath:kTextContainerInsetKey];
    }
}




















#pragma mark - UITextViewDelegate
- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSArray *results = [self getResultsListArrayWithTextView:textView.attributedText];
    BOOL inRange = NO;
    NSRange tempRange = NSMakeRange(0, 0);
    NSInteger textSelectedLocation = textView.selectedRange.location;
    NSInteger textSelectedLength = textView.selectedRange.length;

    for (NSInteger i = 0; i < results.count; i++) {
        ATTextViewBinding *bindingModel = results[i];
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
    if (self.bSpecialText && [self.atDelegate respondsToSelector:@selector(atTextViewDidInputSpecialText: type:)] && self.isSupport) {
        [self.atDelegate atTextViewDidInputSpecialText:self type:self.type];
    }
    
    if ([self checkAndFilterTextByLength:self.max_TextLength]) {
        return;
    }
    
    if ([self.atDelegate respondsToSelector:@selector(atTextViewDidChange:)]) {
        [self.atDelegate atTextViewDidChange:self];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (self.isSupport) {
        if ([text isEqualToString:kAT]
            || [text isEqualToString:kTopic]) {
            if ([text isEqualToString:kAT]) {
                self.type = ATTextViewBindingTypeUser;
            } else {
                self.type = ATTextViewBindingTypeTopic;
            }
            self.bSpecialText = YES;
        } else {
            self.bSpecialText = NO;
        }
    }
    
    // 解决UITextView富文本编辑会连续的问题，且预输入颜色不变的问题
    if (textView.textStorage.length != 0) {
        textView.typingAttributes = @{NSFontAttributeName:self.font, NSForegroundColorAttributeName:self.attributed_TextColor};
    }

    if ([text isEqualToString:@""]) { // 删除
        NSRange selectedRange = textView.selectedRange;
        if (selectedRange.length) {
            
            NSMutableAttributedString *tmpAString = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
            [tmpAString deleteCharactersInRange:selectedRange];
            textView.attributedText = tmpAString;
            
            NSInteger lastCursorLocation = selectedRange.location;
            [self textViewDidChange:textView];
            textView.typingAttributes = @{NSFontAttributeName:self.font,NSForegroundColorAttributeName:self.attributed_TextColor};
            self.cursorLocation = lastCursorLocation;
            textView.selectedRange = NSMakeRange(lastCursorLocation, 0);
            
            return NO;
        } else {
            NSArray *results = [self getResultsListArrayWithTextView:textView.attributedText];
            for (NSInteger i = 0; i < results.count; i++) {
                ATTextViewBinding *bindingModel = results[i];
                NSRange tmpRange = bindingModel.range;
                if ((range.location + range.length) == (tmpRange.location + tmpRange.length)) {
                    
                    NSMutableAttributedString *tmpAString = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
                    [tmpAString deleteCharactersInRange:tmpRange];
                    textView.attributedText = tmpAString;
                    
                    NSInteger lastCursorLocation = selectedRange.location-tmpRange.length;
                    [self textViewDidChange:textView];
                    textView.typingAttributes = @{NSFontAttributeName:self.font,NSForegroundColorAttributeName:self.attributed_TextColor};
                    self.cursorLocation = lastCursorLocation;
                    textView.selectedRange = NSMakeRange(lastCursorLocation, 0);
                    
                    return NO;
                }
            }
        }
    } else { // 增加
        textView.typingAttributes = @{NSFontAttributeName:self.font, NSForegroundColorAttributeName:self.attributed_TextColor};
    }
     return YES;
 }

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([self.atDelegate respondsToSelector:@selector(atTextViewDidBeginEditing:)]) {
        [self.atDelegate atTextViewDidBeginEditing:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([self.atDelegate respondsToSelector:@selector(atTextViewDidEndEditing:)]) {
        [self.atDelegate atTextViewDidEndEditing:self];
    }
}


#pragma mark - other binding
- (NSArray<ATTextViewBinding *> *)getResultsListArrayWithTextView:(NSAttributedString *)attributedString {
    __block NSMutableArray *resultArray = [NSMutableArray array];
    
    // user type
    NSRegularExpression *iExpression = [NSRegularExpression regularExpressionWithPattern:kATRegular options:0 error:NULL];
    [iExpression enumerateMatchesInString:attributedString.string
                                  options:0
                                    range:NSMakeRange(0, attributedString.string.length)
                               usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange resultRange = result.range;
        NSString *atString = [attributedString.string substringWithRange:result.range];
        ATTextViewBinding *bindingModel = [attributedString attribute:ATTextBindingAttributeName atIndex:resultRange.location longestEffectiveRange:&resultRange inRange:NSMakeRange(0, atString.length)];
        if (bindingModel) {
            bindingModel.range = result.range;
            [resultArray addObject:bindingModel];
        }
    }];
    
    // topic type
    NSArray *topicArray = [self getTopicResultsListArrayWithTextView:attributedString];
    [resultArray addObjectsFromArray:topicArray];
    return resultArray;
}

- (NSArray<ATTextViewBinding *> *)getTopicResultsListArrayWithTextView:(NSAttributedString *)attributedString {
    __block NSMutableArray *resultArray = [NSMutableArray array];
    // topic type
    NSRegularExpression *iExpressionTopic = [NSRegularExpression regularExpressionWithPattern:kTopicRegular options:0 error:NULL];
    [iExpressionTopic enumerateMatchesInString:attributedString.string
                                       options:0
                                         range:NSMakeRange(0, attributedString.string.length)
                                    usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange resultRange = result.range;
        NSString *atString = [attributedString.string substringWithRange:result.range];
        ATTextViewBinding *bindingModel = [attributedString attribute:ATTextBindingAttributeName atIndex:resultRange.location longestEffectiveRange:&resultRange inRange:NSMakeRange(0, atString.length)];
        if (bindingModel) {
            bindingModel.range = result.range;
            [resultArray addObject:bindingModel];
        }
    }];
    return resultArray;
}

- (void)insertWithBindingModel:(ATTextViewBinding *)bindingModel {
    BOOL isAt = self.isSpecialText;
    if (self.isSpecialText) {
        self.bSpecialText = NO;
    }
    
    NSString *insertText;
    if (bindingModel.bindingType == ATTextViewBindingTypeUser) {
        insertText = isAt == NO ? [NSString stringWithFormat:@"@%@ ", bindingModel.name] : [NSString stringWithFormat:@"%@ ", bindingModel.name];
    } else {
//        if (self.bTopicFirst) {
//            NSArray *topicArray = [self getTopicResultsListArrayWithTextView:self.attributedText];
//            if (topicArray.count == 1) {
//                ATTextViewBinding *bindingModel = topicArray.firstObject;
//                NSRange selectedRange = bindingModel.range;
//
//                NSMutableAttributedString *tmpAString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
//                [tmpAString deleteCharactersInRange:selectedRange];
//                self.attributedText = tmpAString;
//
//                NSInteger lastCursorLocation = selectedRange.location;
//                [self textViewDidChange:self];
//                self.selectedRange = NSMakeRange(lastCursorLocation, 0);
//            }
//
//            self.cursorLocation = 0;
//            self.selectedRange = NSMakeRange(self.cursorLocation, self.selectedRange.length);
//        }
        
        insertText = isAt == NO ? [NSString stringWithFormat:@"#%@# ", bindingModel.name] : [NSString stringWithFormat:@"%@# ", bindingModel.name];
    }

    // 插入前手动判断
    if (self.text.length+insertText.length > _max_TextLength) {
        NSLog(@"已经超出最大输入限制了....");
        return;
    }
    
    [self insertText:insertText];
    NSMutableAttributedString *tmpAString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    NSRange range = range = isAt == NO ? NSMakeRange(self.selectedRange.location - insertText.length, insertText.length) : NSMakeRange(self.selectedRange.location - insertText.length - 1, insertText.length + 1);
    [tmpAString setAttributes:@{NSForegroundColorAttributeName:self.hightTextColor,
                                NSFontAttributeName:self.font,
                                ATTextBindingAttributeName:bindingModel}
                        range:range];

    // 解决光标在插入‘特殊文本’后 移动到文本最后的问题
    NSInteger lastCursorLocation = self.cursorLocation;
    self.attributedText = tmpAString;
    self.selectedRange = NSMakeRange(lastCursorLocation, self.selectedRange.length);
    self.cursorLocation = lastCursorLocation;
}

#pragma mark - get data
- (NSArray<ATTextViewBinding *> *)atUserList {
    NSArray *results = [self getResultsListArrayWithTextView:self.attributedText];
    return results;
}

#pragma mark - set data
- (void)setMaxTextLength:(NSInteger)maxTextLength {
    _max_TextLength = maxTextLength;
}

- (void)setAttributedTextColor:(UIColor *)attributedTextColor {
    _attributed_TextColor = attributedTextColor;
}

- (void)setBSupport:(BOOL)bSupport {
    _bSupport = bSupport;
}

@end
