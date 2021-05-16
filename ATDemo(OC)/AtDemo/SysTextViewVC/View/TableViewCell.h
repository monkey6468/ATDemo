//
//  TableViewCell.h
//  AtDemo
//
//  Created by XWH on 2021/4/24.
//

#import <UIKit/UIKit.h>

#import "DataModel.h"

#define LABEL_HEIGHT(string,width,font) [string boundingRectWithSize:CGSizeMake(width, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil].size.height

NS_ASSUME_NONNULL_BEGIN

@interface TableViewCell : UITableViewCell

@property (strong, nonatomic) DataModel *model;

+ (CGFloat)rowHeightWithModel:(DataModel *)model;

@end

NS_ASSUME_NONNULL_END
