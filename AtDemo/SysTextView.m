//
//  SysTextView.m
//  AtDemo
//
//  Created by HN on 2021/4/28.
//

#import "SysTextView.h"
#import "TCUITextView.h"

#define kScreenWidth      [UIScreen mainScreen].bounds.size.width
#define UIColorFromRGB(rgbValue)    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kFontWithSize(size)      [UIFont systemFontOfSize:size]
//#define kSystemColor          [UIColor colorWithHexString:@"#05d380"];

static  CGFloat const headHight = 150;

@interface SysTextView ()<TCUITextViewDelegate>
/// 动态文本输入框
@property (nonatomic ,strong) TCUITextView *dynamicTextView;

@end

@implementation SysTextView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    self.dynamicTextView.in
    [self.view addSubview:self.dynamicTextView];
}

- (TCUITextView *)dynamicTextView{
    if (!_dynamicTextView) {
        _dynamicTextView = [[TCUITextView alloc]initWithFrame:CGRectMake(18, 10, kScreenWidth - 35, headHight - 40)];
        _dynamicTextView.
        _dynamicTextView.font = kFontWithSize(16);
        _dynamicTextView.textColor = UIColorFromRGB(0x313131);
        _dynamicTextView.placeHoldString = @"分享你的营养控糖经验...";
        _dynamicTextView.placeHoldTextFont = kFontWithSize(15);
        _dynamicTextView.placeHoldTextColor = UIColorFromRGB(0xaaaaaa);
        _dynamicTextView.myDelegate = self;
        _dynamicTextView.specialTextColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    }
    return _dynamicTextView;
}

@end
