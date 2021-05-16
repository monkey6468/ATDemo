//
//  ListViewController.h
//  AtDemo
//
//  Created by HN on 2021/4/19.
//

#import <UIKit/UIKit.h>

#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface ListViewController : UIViewController

@property (copy, nonatomic) void(^block) (NSInteger index, User *user);

@end

NS_ASSUME_NONNULL_END
