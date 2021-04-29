//
//  LJTextViewBinding.h
//  AtDemo
//
//  Created by HN on 2021/4/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LJTextViewBinding : NSObject

@property (nonatomic, strong) NSString *topicName;
@property (nonatomic, strong) NSNumber *topicId;
@property (nonatomic, strong) NSString *rangePosition;
-(instancetype)initWithTopicName:(NSString*)name topicId:(NSNumber*)tId;

@end

NS_ASSUME_NONNULL_END
