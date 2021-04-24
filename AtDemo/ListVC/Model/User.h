//
//  User.h
//  AtDemo
//
//  Created by HN on 2021/4/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject

@property (copy, nonatomic) NSString *atName; // 带@
@property (copy, nonatomic) NSString *name;
@property (nonatomic, assign) NSRange range;

@end

NS_ASSUME_NONNULL_END
