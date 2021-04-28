//
//  SysTextView.m
//  AtDemo
//
//  Created by HN on 2021/4/28.
//

#import "SysTextView.h"
#import "TCUITextView.h"
#import "ListViewController.h"

#define kScreenWidth      [UIScreen mainScreen].bounds.size.width
#define UIColorFromRGB(rgbValue)    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kFontWithSize(size)      [UIFont systemFontOfSize:size]
//#define kSystemColor          [UIColor colorWithHexString:@"#05d380"];

static  CGFloat const headHight = 150;

@interface SysTextView ()<TCUITextViewDelegate> {
    NSInteger   _textViewNumbeAdd;      // 文本输入框数字统计
}
/// 动态文本输入框
@property (nonatomic ,strong) TCUITextView *dynamicTextView;
@property (nonatomic, assign) NSInteger  dynamicTextNumber;

@end

@implementation SysTextView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dynamicTextNumber = 20;
    _textViewNumbeAdd = 0;

    self.view.backgroundColor = [UIColor whiteColor];
//    self.dynamicTextView.in
    [self.view addSubview:self.dynamicTextView];
}

- (TCUITextView *)dynamicTextView{
    if (!_dynamicTextView) {
        _dynamicTextView = [[TCUITextView alloc]initWithFrame:CGRectMake(18, 100, kScreenWidth - 35, headHight - 40)];
        _dynamicTextView.font = kFontWithSize(16);
        _dynamicTextView.textColor = UIColorFromRGB(0x313131);
        _dynamicTextView.placeHoldString = @"分享你的营养控糖经验...";
        _dynamicTextView.placeHoldTextFont = kFontWithSize(15);
        _dynamicTextView.placeHoldTextColor = UIColorFromRGB(0xaaaaaa);
        _dynamicTextView.myDelegate = self;
        _dynamicTextView.backgroundColor = UIColor.lightGrayColor;
        _dynamicTextView.specialTextColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    }
    return _dynamicTextView;
}

#pragma mark ====== TCUITextViewDelegate =======
-(void)textViewDidBeginEditing:(TCUITextView *)textView{
//    [MobClick event:@"105_002013"];
}
-(BOOL)textView:(TCUITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (_dynamicTextView.text.length+text.length > _dynamicTextNumber) {
//        [self.view makeToast:[NSString stringWithFormat:@"动态文字不能超过%ld字",(long)_dynamicTextNumber] duration:1.0 position:CSToastPositionCenter];
        return NO;
    }
    return YES;
}
- (void)textViewDidChangeSelection:(TCUITextView *)textView{
    
    NSString *tString = [NSString stringWithFormat:@"%lu/%ld",(unsigned long)textView.text.length,(long)_dynamicTextNumber];
//    _countLabel.text = tString;
}

#pragma mark ====== 设置特殊文本 =======
- (void)setTextViewAttributedStrings:(NSString *)str{
    [self.dynamicTextView becomeFirstResponder];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, str.length)];
    [self.dynamicTextView insterSpecialTextAndGetSelectedRange:attrStr selectedRange:self.dynamicTextView.selectedRange text:self.dynamicTextView.attributedText];
}
#define kSelfWeak __weak typeof(self) weakSelf = self
#pragma mark ====== @ 他人判断 =======
- (void)textViewDidChange:(TCUITextView *)textView{
    if ([textView.text length]!= 0) {
        NSString *tString = [NSString stringWithFormat:@"%ld/%ld",(long)textView.text.length,_dynamicTextNumber];
//        _countLabel.text = tString;
    }
    if (textView.text.length >= _textViewNumbeAdd) {
        // 输入文本判断
        NSString *textStr = [textView.text substringWithRange:NSMakeRange(textView.text.length - 1, 1)];
        if ([textStr isEqualToString:@"@"] ){//&& _view_show == NO
            textView.text = [textView.text substringToIndex:textView.text.length - 1];
            
            ListViewController *vc = [[ListViewController alloc]init];
            [self presentViewController:vc animated:NO completion:nil];
            kSelfWeak;

            vc.block = ^(NSInteger index, User * _Nonnull user) {
                if (weakSelf.dynamicTextView.text.length + user.name.length + 1 <= _dynamicTextNumber) {
                    [weakSelf setTextViewAttributedStrings:[NSString stringWithFormat:@"@%@ ",user.name]];
                }else{
                    NSLog(@"%@",[NSString stringWithFormat:@"动态文字不能超过%ld字",(long)weakSelf.dynamicTextNumber]);
//                    [weakSelf.view makeToast:[NSString stringWithFormat:@"动态文字不能超过%ld字",(long)weakSelf.dynamicTextNumber] duration:1.0 position:CSToastPositionCenter];
                }
            };
////            TCRemindWhoSeeViewController *remindWhoSeeVC = [TCRemindWhoSeeViewController new];
////            remindWhoSeeVC.remindUsersBlock = ^(NSString *userName, NSInteger userId,NSInteger role_type_ed) {
//                if (weakSelf.dynamicTextView.text.length + userName.length + 1 <= _dynamicTextNumber) {
//                    [weakSelf setTextViewAttributedStrings:[NSString stringWithFormat:@"%@ ",userName]];
//                }else{
//                    [weakSelf.view makeToast:[NSString stringWithFormat:@"动态文字不能超过%ld字",(long)weakSelf.dynamicTextNumber] duration:1.0 position:CSToastPositionCenter];
//                }
//                _view_show = NO;
////            };
//            _view_show = YES;
//            [self.navigationController pushViewController:remindWhoSeeVC animated:YES];
        }
    }
    _textViewNumbeAdd = textView.text.length;
}
@end
