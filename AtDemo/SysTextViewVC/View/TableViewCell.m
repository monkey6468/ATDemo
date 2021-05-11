//
//  TableViewCell.m
//  AtDemo
//
//  Created by XWH on 2021/4/24.
//

#import "TableViewCell.h"

#import "M80AttributedLabel.h"
#import "TextViewBinding.h"

@interface TableViewCell () <M80AttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet M80AttributedLabel *yyLabel;

@end

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.yyLabel.numberOfLines = 0;
    self.yyLabel.delegate = self;
    self.yyLabel.font = [UIFont systemFontOfSize:25];
}

- (void)setModel:(DataModel *)model {
    _model = model;
    self.yyLabel.text = model.text;

    for (TextViewBinding *bindingModel in model.userList) {
        [self.yyLabel addCustomLink:bindingModel forRange:bindingModel.range linkColor:UIColor.redColor];
        self.yyLabel.underLineForLink = NO;
    }
}

#pragma mark - M80AttributedLabelDelegate
- (void)m80AttributedLabel:(M80AttributedLabel *)label
             clickedOnLink:(id)linkData{
    TextViewBinding *tempBindingModel = (TextViewBinding *)linkData;
    NSLog(@"点击了: %@",tempBindingModel.name);
}

+ (CGFloat)rowHeightWithModel:(DataModel *)model {
    CGFloat h = LABEL_HEIGHT(model.text, [UIScreen mainScreen].bounds.size.width, 25)+5;
    return h;
}
@end
