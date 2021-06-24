//
//  ATTextView.h
//  AtDemo
//
//  Created by XWH on 2021/5/12.
//

#import <UIKit/UIKit.h>

#import "ATTextViewBinding.h"

/// placeholder 属性参考了【SZTextView】

NS_ASSUME_NONNULL_BEGIN

@class ATTextView;
@protocol ATTextViewDelegate <NSObject>

@optional
- (void)atTextViewDidChange:(ATTextView *)textView;

- (void)atTextViewDidBeginEditing:(ATTextView *)textView;

- (void)atTextViewDidEndEditing:(ATTextView *)textView;

/// 检查到输入特殊文本的回调
- (void)atTextViewDidInputSpecialText:(ATTextView *)textView type:(ATTextViewBindingType)type;

@end

@interface ATTextView : UITextView

/// 特殊文本【艾特、话题】列表，内容可自定义
@property (copy, nonatomic) NSArray <ATTextViewBinding *> *atUserList;
/// 是否为特殊文本【艾特、话题】
@property (assign, nonatomic, getter=isSpecialText) BOOL bSpecialText;

@property (copy, nonatomic) IBInspectable NSString *placeholder;
@property (nonatomic) IBInspectable double fadeTime;
@property (copy, nonatomic) NSAttributedString *attributedPlaceholder;
@property (strong, nonatomic) UIColor *placeholderTextColor UI_APPEARANCE_SELECTOR;

/// 最大长度设置，默认1000
@property (assign, nonatomic) NSInteger maxTextLength;
@property (strong, nonatomic) UIColor *attributedTextColor;
/// 默认特殊文本高亮颜色，默认UIColor.redColor
@property (strong, nonatomic) UIColor *hightTextColor;
@property (assign, nonatomic) NSInteger lineSpacing;
/// 支持自动检测特殊文本【艾特、话题】，默认YES
@property (assign, nonatomic, getter=isSupport) BOOL bSupport;
@property (nonatomic, weak) id<ATTextViewDelegate> atDelegate;

- (void)insertWithBindingModel:(ATTextViewBinding *)bindingModel;

@end

NS_ASSUME_NONNULL_END
