//
//  YYTextViewVC.m
//  AtDemo
//
//  Created by XWH on 2021/4/20.
//

#import "YYTextViewVC.h"
#import "ListViewController.h"

#import "YYText.h"
#import "YYTextViewCell.h"

#import "HNWKeyboardMonitor.h"

#define NIMInputAtStartChar  @"@"
#define NIMInputAtEndChar    @" " 

@interface YYTextViewVC ()<YYTextViewDelegate, HNWKeyboardMonitorDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet YYTextView *yyTextView;
//@property (strong, nonatomic) NSMutableArray<User *> *usersList;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yyTextViewConstraintH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineConstraintB;

@property (strong, nonatomic) NSMutableArray *dataArray;
@end

@implementation YYTextViewVC

#pragma mark - life
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.usersList = [NSMutableArray array];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"YYTextViewVC";
    
    [self settingUI];
    [self initTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [HNWKeyboardMonitor addDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [HNWKeyboardMonitor removeDelegate:self];
}

#pragma mark - UI
- (void)settingUI {
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@""];

    self.yyTextView.delegate = self;
    self.yyTextView.font = [UIFont systemFontOfSize:25];
    self.yyTextView.attributedText = text;
    self.yyTextView.selectedRange = NSMakeRange(0, 0);

    [self.yyTextView becomeFirstResponder];
}

- (void)initTableView {
    self.tableView.tableFooterView = UIView.new;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([YYTextViewCell class])
                                               bundle:nil]
         forCellReuseIdentifier:NSStringFromClass(YYTextViewCell.class)];
}

#pragma mark - other
- (void)showLogInfo {
//    if (self.usersList.count) {
//        for (User *tempUser in self.usersList) {
//            NSLog(@"user info - name:%@ - location:%ld",tempUser.atName, tempUser.range.location);
//        }
//    } else {
//        NSLog(@"xwh list is a Empty");
//    }
//    NSLog(@"\n\n");
}

- (void)done {
    [self.view endEditing:YES];
    
    [self showLogInfo];
    
//    DataModel *model = [[DataModel alloc]init];
//    model.userList = self.usersList;
//    model.text = self.yyTextView.text;
//    [self.dataArray addObject:model];
//
//    [self.usersList removeAllObjects];
    self.yyTextView.text = nil;
//
//    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DataModel *model = self.dataArray[indexPath.row];
    return [YYTextViewCell rowHeightWithModel:model];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YYTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(YYTextViewCell.class)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

#pragma mark - YYTextViewDelegate
- (void)textViewDidChange:(YYTextView *)textView {
    //
}

- (BOOL)textView:(YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@""]) {
        return YES;
    }
    if ([text isEqualToString:NIMInputAtStartChar]) {
        [self pushListVAtTextInRange:range];
        return NO;
    }
    
    CGRect frame = [textView.attributedText boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGFloat h = frame.size.height;
    if (h <= 44) {
        h = 44;
    }
#warning <#message#>
    // 普通字符串的中间插入，则需要更新插入后元素的location
    self.yyTextViewConstraintH.constant = h;
//    [self.view layoutIfNeeded];
   
    return YES;
    NSLog(@"变动打印:");
    [self showLogInfo];
    return YES;
//#warning 删除，定位不准确
//    if ([text isEqualToString:@""]) {
//        [textView.attributedText enumerateAttribute:YYTextBindingAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
//            NSMutableArray *userListCopy = [NSMutableArray arrayWithArray:self.usersList];
//            // 寻找删除的index
//            NSInteger deleteIndex = 0;
//            User *deleteUser = nil;
//            for (int i = 0; i < userListCopy.count; i++) {
//                User *tempUser = userListCopy[i];
//                NSInteger selectLocation = range.location;
//                NSInteger tempLocation = tempUser.range.location;
//                if (tempLocation == selectLocation) {
//                    deleteIndex = i;
//                    deleteUser = tempUser;
//                    NSLog(@"单个删除: %@ - %ld",tempUser.atName, tempUser.range.location);
//                    [self.usersList removeObject:tempUser];
//                    break;
//                }
//            }
//
//            // 若有删除，则需要更新插入后元素的location
//            if (deleteUser) {
//                for (int i = 0; i < self.usersList.count; i++) {
//                    User *tempUser = self.usersList[i];
//                    if (i >= deleteIndex) {
//                        tempUser.range = NSMakeRange(tempUser.range.location-deleteUser.range.length, tempUser.range.length);
//                    }
//                }
//            } else {
//                NSInteger deleteIndex = range.location;
//                for (int i = 0; i < self.usersList.count; i++) {
//                    User *tempUser = self.usersList[i];
//                    if (tempUser.range.location > deleteIndex) {
//                        tempUser.range = NSMakeRange(tempUser.range.location-range.length, tempUser.range.length);
//                    }
//                }
//            }
//            NSLog(@"删除打印:");
//            [self showLogInfo];
//        }];
//    } else {
//
//
//
//        // 单个字符串处理
//        NSRange effectiveRange;
////        YYTextBinding *binding = [textView.attributedText attribute:YYTextBindingAttributeName atIndex:range.location longestEffectiveRange:&effectiveRange inRange:NSMakeRange(0, textView.attributedText.length-1)];
////        if (binding == nil) {
////            // 字符串插入
////            NSInteger insertIndex = range.location;
////            for (int i = 0; i < self.usersList.count; i++) {
////                User *tempUser = self.usersList[i];
////                if (tempUser.range.location >= insertIndex) {
////                    tempUser.range = NSMakeRange(tempUser.range.location+range.length, tempUser.range.length);
////                }
////            }
////
////            NSLog(@"插入字符串打印:");
////            [self showLogInfo];
////        }
//        NSRange insertRange = range;
//        [textView.attributedText enumerateAttributesInRange:NSMakeRange(0, textView.attributedText.length)
//                                                    options:NSAttributedStringEnumerationReverse
//                                                 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
//            if (attrs[YYTextBindingAttributeName] == nil) {
//                // 字符串插入
//                NSInteger insertIndex = insertRange.location;
//                for (int i = 0; i < self.usersList.count; i++) {
//                    User *tempUser = self.usersList[i];
//                    if (tempUser.range.location >= insertIndex) {
//                        tempUser.range = NSMakeRange(tempUser.range.location+insertRange.length, tempUser.range.length);
//                    }
//                }
//
//                NSLog(@"插入字符串打印:");
//                [self showLogInfo];
//            }
//        }];
////        [textView.attributedText enumerateAttribute:YYTextBindingAttributeName inRange:range options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
////            NSLog(@"插入字符串打印:");
////
////        }];
//
//    }
}

- (void)pushListVAtTextInRange:(NSRange)range {
    ListViewController *vc = [[ListViewController alloc]init];
    [self presentViewController:vc animated:NO completion:nil];
    vc.block = ^(NSInteger index, User * _Nonnull user1) {

        NSString *newAtUserName = [NSString stringWithFormat:@"%@%@%@",NIMInputAtStartChar,user1.name,NIMInputAtEndChar];
        User *newAtUser = [[User alloc]init];
//        newAtUser.atName = newAtUserName;
        newAtUser.range = NSMakeRange(range.location, newAtUserName.length);

//        NSInteger insertIndex = 0;
//        for (int i = 0; i < self.usersList.count; i++) {
//            User *tempUser = self.usersList[i];
//            NSInteger selectLocation = range.location;
//            NSInteger tempLocation = tempUser.range.location;
//            NSInteger tempLength = tempUser.range.length;
//            if (selectLocation >= tempLocation) {
//                insertIndex = i;
//            }
//            // 解决最后插入的问题
//            if (tempLocation+tempLength <= selectLocation) {
//                insertIndex = i+1;
//            }
//        }
//
//        // 中间插入，则需要更新插入后元素的location
//        if (insertIndex < self.usersList.count) {
//            for (int i = 0; i < self.usersList.count; i++) {
//                User *tempUser = self.usersList[i];
//                if (i >= insertIndex) {
//                    tempUser.range = NSMakeRange(tempUser.range.location+user.range.length, tempUser.range.length);
//                }
//            }
//        }
//
//        [self.usersList insertObject:user atIndex:insertIndex];

        // 若地方不对，则需更新usersList
        NSMutableAttributedString *muAttriSting = [[NSMutableAttributedString alloc]initWithAttributedString:self.yyTextView.attributedText];
        
        [muAttriSting insertAttributedString:[[NSAttributedString alloc]initWithString:newAtUserName] atIndex:newAtUser.range.location];
        
        NSRange bindlingRange = newAtUser.range;
        YYTextBinding *binding = [YYTextBinding bindingWithDeleteConfirm:YES];
       
        [muAttriSting yy_setTextBinding:binding range:bindlingRange]; /// Text binding
        [muAttriSting yy_setColor:UIColor.redColor range:bindlingRange];
        
        [muAttriSting yy_setFont:[UIFont systemFontOfSize:25] range:NSMakeRange(0, muAttriSting.length)];
        [self.yyTextView setAttributedText:muAttriSting];
        
//        self.yyTextView.selectedRange = NSMakeRange(bindlingRange.location+bindlingRange.length, 0);
        
        NSLog(@"插入@打印:");
    };
    [self showLogInfo];
}

#pragma mark HNWKeyboardMonitorDelegate
- (void)keyboardMonitor:(HNWKeyboardMonitor *)keyboardMonitor keyboardWillShow:(HNWKeyboardInfo *)info {
    if (@available(iOS 11.0, *)) {
        self.bottomLineConstraintB.constant = -info.keyboardEndFrame.size.height+self.view.safeAreaInsets.bottom;
    } else {
        self.bottomLineConstraintB.constant = -info.keyboardEndFrame.size.height;
    }
    [UIView animateWithDuration:info.animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardMonitor:(HNWKeyboardMonitor *)keyboardMonitor keyboardWillHide:(HNWKeyboardInfo *)info {
    self.bottomLineConstraintB.constant = 0;
    [UIView animateWithDuration:info.animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - get data
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
@end
