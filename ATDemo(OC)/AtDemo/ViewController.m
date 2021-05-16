//
//  ViewController.m

#import "ViewController.h"
#import "SysTextViewVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"ATDemo";

    [self performSelector:@selector(pushSysTextViewVC:) withObject:nil afterDelay:1];
}

- (IBAction)pushSysTextViewVC:(UIButton *)sender {
    SysTextViewVC *vc = [[SysTextViewVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
