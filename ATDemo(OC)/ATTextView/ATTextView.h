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

/// 正在输入的文本
- (void)atTextView:(ATTextView *)textView replacementText:(NSString *)text;

@end

@interface ATTextView : UITextView

@property (copy, nonatomic) NSArray <ATTextViewBinding *> *atUserList; /// 艾特的用户列表，内容可自定义

@property (copy, nonatomic) IBInspectable NSString *placeholder;
@property (nonatomic) IBInspectable double fadeTime;
@property (copy, nonatomic) NSAttributedString *attributedPlaceholder;
@property (strong, nonatomic) UIColor *placeholderTextColor UI_APPEARANCE_SELECTOR;

@property (assign, nonatomic) NSInteger maxTextLength; // 最大长度设置，默认1000
@property (strong, nonatomic) UIColor *attributedTextColor;

@property (nonatomic, weak) id<ATTextViewDelegate> atDelegate;

@end

NS_ASSUME_NONNULL_END
