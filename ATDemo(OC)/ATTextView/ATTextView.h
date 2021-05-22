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
- (void)atTextViewDidInputSpecialText:(ATTextView *)textView;

@end

@interface ATTextView : UITextView

@property (copy, nonatomic) NSArray <ATTextViewBinding *> *atUserList; /// 艾特的用户列表，内容可自定义
@property (assign, nonatomic, getter=isAtChart) BOOL bAtChart; /// 是否为艾特

@property (copy, nonatomic) IBInspectable NSString *placeholder;
@property (nonatomic) IBInspectable double fadeTime;
@property (copy, nonatomic) NSAttributedString *attributedPlaceholder;
@property (strong, nonatomic) UIColor *placeholderTextColor UI_APPEARANCE_SELECTOR;

@property (assign, nonatomic) NSInteger maxTextLength; /// 最大长度设置，默认1000
@property (strong, nonatomic) UIColor *attributedTextColor;
@property (strong, nonatomic) UIColor *hightTextColor; /// 默认特殊文本高亮颜色，默认UIColor.redColor
@property (assign, nonatomic, getter=isSupport) BOOL bSupport; /// 支持自动检测特殊文本，默认YES
@property (nonatomic, weak) id<ATTextViewDelegate> atDelegate;

- (void)insertWithBindingModel:(ATTextViewBinding *)bindingModel;

@end

NS_ASSUME_NONNULL_END
