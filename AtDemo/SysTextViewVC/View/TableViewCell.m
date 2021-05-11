//
//  TableViewCell.m
//  AtDemo
//
//  Created by XWH on 2021/4/24.
//

#import "TableViewCell.h"

#import "YYText.h"
#import "TextViewBinding.h"
#import "YYLabel.h"

@interface TableViewCell ()

@property (weak, nonatomic) IBOutlet YYLabel *yyLabel;

@end

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.yyLabel.numberOfLines = 0;
//    [self setupGesture];
}

- (void)setupGesture
{
    UITapGestureRecognizer *contentTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapReply:)];
    [self addGestureRecognizer:contentTap];
}

- (void)onTapReply:(UITapGestureRecognizer *)sender {
    NSLog(@"点击了cell22");
}

- (void)setModel:(DataModel *)model {
    _model = model;
    self.yyLabel.text = model.text;

    NSMutableAttributedString *muAttriSting = [[NSMutableAttributedString alloc]initWithString:model.text];
    muAttriSting.yy_font = [UIFont systemFontOfSize:25];

    for (TextViewBinding *bindingModel in model.userList) {
        [muAttriSting yy_setTextHighlightRange:bindingModel.range
                                         color:UIColor.redColor
                               backgroundColor:UIColor.darkGrayColor
                                     tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            
            for (TextViewBinding *tempBindingModel in model.userList) {
                if (tempBindingModel.range.location == range.location
                && tempBindingModel.range.length == range.length) {
                    NSLog(@"点击了: %@",tempBindingModel.name);
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
