//
//  TextViewBinding.m
//  AtDemo
//
//  Created by HN on 2021/4/29.
//

#import "TextViewBinding.h"

@implementation TextViewBinding

- (instancetype)initWithName:(NSString*)name
                      userId:(NSInteger)userId {
    if (self = [super init]) {
        _name = name;
        _userId = userId;
    }
    return self;
}
@end
