//
//  SysTextView.h
//  AtDemo
//
//  Created by HN on 2021/4/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SysTextView : UIViewController

/// 话题 id
@property (nonatomic, assign) NSInteger  topicId;
/// 话题标题
@property (nonatomic, copy) NSString *topicTiele;
/// 是否可以选择话题
@property (nonatomic, assign) BOOL  isCanChooseTopic;

@end

NS_ASSUME_NONNULL_END
