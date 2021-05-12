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

- (void)atTextViewDidChange:(ATTextView *)textView;

@end

@interface ATTextView : UITextView

@property (assign, nonatomic) NSInteger cursorLocation; /// 光标位置
@property (nonatomic, copy) NSArray <TextViewBinding *>*atUserList; /// 艾特的用户列表，内容可自定义

@property (nonatomic, weak) id<ATTextViewDelegate> atDeleagate;

@end

NS_ASSUME_NONNULL_END
