//
//  YYTextViewCell.m
//  AtDemo
//
//  Created by XWH on 2021/4/24.
//

#import "YYTextViewCell.h"
#import "YYLabel.h"
#import "YYText.h"

#import "User.h"

@interface YYTextViewCell ()

@property (weak, nonatomic) IBOutlet YYLabel *yyLabel;

@end

@implementation YYTextViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.yyLabel.numberOfLines = 0;
}

- (void)setModel:(DataModel *)model {
    _model = model;
    
    NSMutableAttributedString *muAttriSting = [[NSMutableAttributedString alloc]initWithString:model.text];
    muAttriSting.yy_font = [UIFont systemFontOfSize:25];
    for (User *user in model.userList) {
        [muAttriSting yy_setTextHighlightRange:user.range color:[UIColor blueColor] backgroundColor:UIColor.redColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            
            for (User *tempUser in model.userList) {
                if (tempUser.range.location == range.location
                && tempUser.range.length == range.length) {
                    NSLog(@"点击了: %@",tempUser.name);
                }
            }
        }];
        
    }
    self.yyLabel.attributedText = muAttriSting;
}

+ (CGFloat)rowHeightWithModel:(DataModel *)model {
    CGFloat h = LABEL_HEIGHT(model.text, [UIScreen mainScreen].bounds.size.width, 25)+5;
    return h;
}
@end
