//
//  HNWKeyboardMonitor.m
//  huinongwang
//
//  Created by yangyongzheng on 2019/8/12.
//  Copyright © 2019 cnhnb. All rights reserved.
//

#import "HNWKeyboardMonitor.h"

@implementation HNWKeyboardInfo

+ (HNWKeyboardInfo *)keyboardInfoWithNotification:(NSNotification *)noti {
    HNWKeyboardInfo *info = [[HNWKeyboardInfo alloc] init];
    info->_keyboardBeginFrame = [noti.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    info->_keyboardEndFrame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    info->_animationDuration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    return info;
}

@end



#define HNWSharedKeyboardMonitor [HNWKeyboardMonitor sharedMonitor]

@interface HNWKeyboardMonitor ()
@property (nonatomic, strong) NSHashTable *delegateContainer;
@end

@implementation HNWKeyboardMonitor

#pragma mark - Lifecycle
- (instancetype)init {
    if (self = [super init]) {
        [self setupDefaultConfiguration];
    }
    return self;
}

+ (HNWKeyboardMonitor *)sharedMonitor {
    static HNWKeyboardMonitor *monitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monitor = [[HNWKeyboardMonitor alloc] init];
    });
    return monitor;
}

+ (void)load {
    if (self == [HNWKeyboardMonitor self]) {
        [HNWKeyboardMonitor sharedMonitor];
    }
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - Public
+ (void)addDelegate:(id<HNWKeyboardMonitorDelegate>)delegate {
    if (delegate) {
        @synchronized (HNWSharedKeyboardMonitor.delegateContainer) {
            [HNWSharedKeyboardMonitor.delegateContainer addObject:delegate];
        }
    }
}

+ (void)removeDelegate:(id<HNWKeyboardMonitorDelegate>)delegate {
    @synchronized (HNWSharedKeyboardMonitor.delegateContainer) {
        [HNWSharedKeyboardMonitor.delegateContainer removeObject:delegate];
    }
}

#pragma mark - Notifications
- (void)keyboardWillShowNotification:(NSNotification *)noti {
    [self performDelegateSelector:@selector(keyboardMonitor:keyboardWillShow:)
                 withKeyboardInfo:[HNWKeyboardInfo keyboardInfoWithNotification:noti]];
}

- (void)keyboardDidShowNotification:(NSNotification *)noti {
    [self performDelegateSelector:@selector(keyboardMonitor:keyboardDidShow:)
                 withKeyboardInfo:[HNWKeyboardInfo keyboardInfoWithNotification:noti]];
}

- (void)keyboardWillHideNotification:(NSNotification *)noti {
    [self performDelegateSelector:@selector(keyboardMonitor:keyboardWillHide:)
                 withKeyboardInfo:[HNWKeyboardInfo keyboardInfoWithNotification:noti]];
}

- (void)keyboardDidHideNotification:(NSNotification *)noti {
    [self performDelegateSelector:@selector(keyboardMonitor:keyboardDidHide:)
                 withKeyboardInfo:[HNWKeyboardInfo keyboardInfoWithNotification:noti]];
}

- (void)keyboardWillChangeFrameNotification:(NSNotification *)noti {
    [self performDelegateSelector:@selector(keyboardMonitor:keyboardWillChangeFrame:)
                 withKeyboardInfo:[HNWKeyboardInfo keyboardInfoWithNotification:noti]];
}

- (void)keyboardDidChangeFrameNotification:(NSNotification *)noti {
    [self performDelegateSelector:@selector(keyboardMonitor:keyboardDidChangeFrame:)
                 withKeyboardInfo:[HNWKeyboardInfo keyboardInfoWithNotification:noti]];
}

#pragma mark - Misc
- (void)setupDefaultConfiguration {
    self.delegateContainer = [NSHashTable weakObjectsHashTable];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(keyboardWillShowNotification:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(keyboardDidShowNotification:)
                                               name:UIKeyboardDidShowNotification
                                             object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(keyboardWillHideNotification:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(keyboardDidHideNotification:)
                                               name:UIKeyboardDidHideNotification
                                             object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(keyboardWillChangeFrameNotification:)
                                               name:UIKeyboardWillChangeFrameNotification
                                             object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(keyboardDidChangeFrameNotification:)
                                               name:UIKeyboardDidChangeFrameNotification
                                             object:nil];
}

- (void)performDelegateSelector:(SEL)aSelector withKeyboardInfo:(HNWKeyboardInfo *)keyboardInfo {
    NSArray *allDelegates = self.delegateContainer.allObjects;
    for (id <HNWKeyboardMonitorDelegate> delegate in allDelegates) {
        if ([self.delegateContainer containsObject:delegate] && [delegate respondsToSelector:aSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [delegate performSelector:aSelector withObject:self withObject:keyboardInfo];
#pragma clang diagnostic pop
        }
    }
}

@end
