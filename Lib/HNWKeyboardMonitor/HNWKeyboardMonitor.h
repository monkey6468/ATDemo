//
//  HNWKeyboardMonitor.h
//  huinongwang
//
//  Created by yangyongzheng on 2019/8/12.
//  Copyright © 2019 cnhnb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HNWKeyboardInfo : NSObject
@property (nonatomic, readonly) CGRect keyboardBeginFrame;
@property (nonatomic, readonly) CGRect keyboardEndFrame;
@property (nonatomic, readonly) double animationDuration;
@end



@class HNWKeyboardMonitor;

@protocol HNWKeyboardMonitorDelegate <NSObject>

@optional
- (void)keyboardMonitor:(HNWKeyboardMonitor *)keyboardMonitor keyboardWillShow:(HNWKeyboardInfo *)info;
- (void)keyboardMonitor:(HNWKeyboardMonitor *)keyboardMonitor keyboardDidShow:(HNWKeyboardInfo *)info;

- (void)keyboardMonitor:(HNWKeyboardMonitor *)keyboardMonitor keyboardWillHide:(HNWKeyboardInfo *)info;
- (void)keyboardMonitor:(HNWKeyboardMonitor *)keyboardMonitor keyboardDidHide:(HNWKeyboardInfo *)info;

- (void)keyboardMonitor:(HNWKeyboardMonitor *)keyboardMonitor keyboardWillChangeFrame:(HNWKeyboardInfo *)info;
- (void)keyboardMonitor:(HNWKeyboardMonitor *)keyboardMonitor keyboardDidChangeFrame:(HNWKeyboardInfo *)info;

@end

@interface HNWKeyboardMonitor : NSObject

/** 添加代理 */
+ (void)addDelegate:(id <HNWKeyboardMonitorDelegate>)delegate;

/** 移除代理 */
+ (void)removeDelegate:(id <HNWKeyboardMonitorDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
