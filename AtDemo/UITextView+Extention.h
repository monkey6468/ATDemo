//
//  UITextView+Extention.h
//  AtDemo
//
//  Created by HN on 2021/4/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (Extention)
/**
 生成set，get方法
 */
@property(nonatomic,assign)NSRange selectedRange;

@end

NS_ASSUME_NONNULL_END
