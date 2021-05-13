//
//  ATTextView.h
//  AtDemo
//
//  Created by XWH on 2021/5/12.
//

#import <UIKit/UIKit.h>

#import "TextViewBinding.h"

#define k_defaultFont   [UIFont systemFontOfSize:20]
#define k_defaultColor  [UIColor blackColor]
#define k_hightColor    [UIColor redColor]

NS_ASSUME_NONNULL_BEGIN

@class ATTextView;
@protocol ATTextViewDelegate <NSObject>

@optional
- (void)atTextViewDidChange:(ATTextView *)textView;

- (void)atTextViewDidBeginEditing:(ATTextView *)textView;

- (void)atTextViewDidEndEditing:(ATTextView *)textView;

@end

@interface ATTextView : UITextView

@property (assign, nonatomic) NSInteger cursorLocation; /// 光标位置
@property (copy, nonatomic) NSArray <TextViewBinding *> *atUserList; /// 艾特的用户列表，内容可自定义

@property (copy, nonatomic) IBInspectable NSString *placeholder;
@property (nonatomic) IBInspectable double fadeTime;
@property (copy, nonatomic) NSAttributedString *attributedPlaceholder;
@property (retain, nonatomic) UIColor *placeholderTextColor UI_APPEARANCE_SELECTOR;

@property (assign, nonatomic) NSInteger maxTextLength; // 最大长度设置，默认1000

@property (nonatomic, weak) id<ATTextViewDelegate> atDelegate;

@end

NS_ASSUME_NONNULL_END
