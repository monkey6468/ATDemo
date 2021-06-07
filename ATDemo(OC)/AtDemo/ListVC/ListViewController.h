//
//  ListViewController.h
//  AtDemo
//
//  Created by HN on 2021/4/19.
//

#import <UIKit/UIKit.h>

#import "User.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ATType) {
    ATTypeUser     = 0,
    ATTypeTopic,
};

@interface ListViewController : UIViewController

@property (copy, nonatomic) void(^block) (NSInteger index, User *user);
@property (assign, nonatomic) ATType type;

@end

NS_ASSUME_NONNULL_END
