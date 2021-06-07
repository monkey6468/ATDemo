//
//  ATTextViewBinding.h
//  AtDemo
//
//  Created by HN on 2021/4/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define ATTextBindingAttributeName @"TextViewBingDingFlagName"

typedef NS_ENUM(NSInteger, ATTextViewBindingType) {
    ATTextViewBindingTypeUser    = 0,
    ATTextViewBindingTypeTopic,
};

@interface ATTextViewBinding : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, assign) ATTextViewBindingType bindingType;

- (instancetype)initWithName:(NSString*)name
                      userId:(NSInteger)userId;

@end

NS_ASSUME_NONNULL_END
