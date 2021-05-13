//
//  ATTextView.h
//  AtDemo
//
//  Created by XWH on 2021/5/12.
//

#import <UIKit/UIKit.h>

#import "TextViewBinding.h"

#define k_defaultFont   [UIFont systemFontOfSize:17]
#define k_defaultColor  [UIColor blackColor]
#define k_hightColor    [UIColor redColor]
#define kATRegular      @"@[\\u4e00-\\u9fa5\\w\\-\\_]+ "

NS_ASSUME_NONNULL_BEGIN

@class ATTextView;
@protocol ATTextViewDelegate <NSObject>

@optional
- (void)atTextViewDidChange:(ATTextView *)textView;

- (void)atTextViewDidBeginEditing:(UITextView *)textView;

- (void)atTextViewDidEndEditing:(UITextView *)textView;

@end

@interface ATTextView : UITextView

@property (assign, nonatomic) NSInteger cursorLocation; /// 光标位置
@property (copy, nonatomic) NSArray <TextViewBinding *>*atUserList; /// 艾特的用户列表，内容可自定义

@property (copy, nonatomic) NSString *placeholder;
@property (assign, nonatomic) CGFloat placeholderOpacity; // 设置透明度
@property (strong, nonatomic) UIColor *placeholderColor; // 设置Placeholder 颜色
@property (strong, nonatomic) UIFont *placeholderFont; // 设置Placeholder 字体
@property (assign, nonatomic) NSInteger maxTextLength; // 最大长度设置，默认1000

@property (nonatomic, weak) id<ATTextViewDelegate> atDelegate;

@end

NS_ASSUME_NONNULL_END
