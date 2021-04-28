//
//  ViewController.m

#import "ViewController.h"
#import "YYTextViewVC.h"
#import "SysTextView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"ATDemo";

    [self performSelector:@selector(pushYYTextViewVC:) withObject:nil afterDelay:1];
}

- (IBAction)pushUITextViewVC:(UIButton *)sender {
    SysTextView *vc = [[SysTextView alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)pushYYTextViewVC:(UIButton *)sender {
    YYTextViewVC *vc = [[YYTextViewVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

// 查找子字符串在父字符串中的所有位置
//- (NSMutableArray*)calculateSubStringCount:(NSString *)content str:(NSString *)tab {
//    int location = 0;
//    NSMutableArray *locationArr = [NSMutableArray new];
//    NSRange range = [content rangeOfString:tab];
//    if (range.location == NSNotFound){
//        return locationArr;
//    }
//    //声明一个临时字符串,记录截取之后的字符串
//    NSString * subStr = content;
//    while (range.location != NSNotFound) {
//        if (location == 0) {
//            location += range.location;
//        } else {
//            location += range.location + tab.length;
//        }
//        //记录位置
//        NSNumber *number = [NSNumber numberWithUnsignedInteger:location];
//        [locationArr addObject:number];
//        //每次记录之后,把找到的字串截取掉
//        subStr = [subStr substringFromIndex:range.location + range.length];
//        range = [subStr rangeOfString:tab];
//    }
//    return locationArr;
//}
@end
