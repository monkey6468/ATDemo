//
//  ListViewController.m
//  AtDemo
//
//  Created by HN on 2021/4/19.
//

#import "ListViewController.h"

@interface ListViewController ()<UITableViewDelegate, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    
    self.tableView.tableFooterView = UIView.new;
}

#pragma mark - other
- (void)done
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    User *user = self.dataArray[indexPath.row];
    cell.textLabel.text = user.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.block) {
        [self done];
        
        User *user = self.dataArray[indexPath.row];
        self.block(indexPath.row, user);
    }
}
#pragma mark - get data
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        for (int i = 0; i < 10; i++) {
            User *user = [[User alloc]init];
            user.name = [NSString stringWithFormat:@"0%d",i];
//            user.range = NSMakeRange(NSNotFound, 0);
            [_dataArray addObject:user];
        }
    }
    return _dataArray;
}
@end
