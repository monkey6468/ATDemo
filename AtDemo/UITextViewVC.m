//
//  UITextViewVC.m
//  AtDemo
//
//  Created by HN on 2021/4/28.
//

#import "UITextViewVC.h"
//#import "UITextView+Extention.h"
//#import "TCUITextView.h"

@interface UITextViewVC ()


@end

@implementation UITextViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

}

/**
 *  设置textview字体属性
 */

//- (void)observeValueForKeyPath:(NSString*) path
//                      ofObject:(id)object
//                        change:(NSDictionary*)change
//                       context:(void*)context
//{
//    if (context == TextViewObserverSelectedTextRange && [path isEqual:@"selectedTextRange"] && !self.enableEditInsterText){
//
//        UITextRange *newContentStr = [change objectForKey:@"new"];
//        UITextRange *oldContentStr = [change objectForKey:@"old"];
//        NSRange newRange = [self selectedRange:self selectTextRange:newContentStr];
//        NSRange oldRange = [self selectedRange:self selectTextRange:oldContentStr];
//        if (newRange.location != oldRange.location) {
//
//            //判断光标移动，光标不能处在特殊文本内
//            [self.attributedText enumerateAttribute:SPECIAL_TEXT_NUM inRange:NSMakeRange(0, self.attributedText.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
////                NSLog(@"range = %@",NSStringFromRange(range));
//                if (attrs != nil && attrs != 0) {
//                    if (newRange.location > range.location && newRange.location < (range.location+range.length)) {
//                        //光标距离左边界的值
//                        NSUInteger leftValue = newRange.location - range.location;
//                        //光标距离右边界的值
//                        NSUInteger rightValue = range.location+range.length - newRange.location;
//                        if (leftValue >= rightValue) {
//                            self.selectedRange = NSMakeRange(self.selectedRange.location-leftValue, 0);
//                        }else{
//                            self.selectedRange = NSMakeRange(self.selectedRange.location+rightValue, 0);
//                        }
//                    }
//                }
//
//            }];
//        }
//    }else{
//        [super observeValueForKeyPath:path ofObject:object change:change context:context];
//    }
//    self.typingAttributes = self.defaultAttributes;
//}
//
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    self.typingAttributes = self.defaultAttributes;
//    if ([text isEqualToString:@""] && !self.enableEditInsterText) {//删除
//        __block BOOL deleteSpecial = NO;
//        NSRange oldRange = textView.selectedRange;
//
//        [textView.attributedText enumerateAttribute:SPECIAL_TEXT_NUM inRange:NSMakeRange(0, textView.selectedRange.location) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
//            NSRange deleteRange = NSMakeRange(textView.selectedRange.location-1, 0) ;
//            if (attrs != nil && attrs != 0) {
//                if (deleteRange.location > range.location && deleteRange.location < (range.location+range.length)) {
//                    NSMutableAttributedString *textAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
//                    [textAttStr deleteCharactersInRange:range];
//                    textView.attributedText = textAttStr;
//                    deleteSpecial = YES;
//                    textView.selectedRange = NSMakeRange(oldRange.location-range.length, 0);
//                    *stop = YES;
//                }
//            }
//        }];
//        return !deleteSpecial;
//    }
//
//    //输入了done
//    if ([text isEqualToString:@"\n"]) {
//        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(SETextViewEnterDone:)]) {
//            [self.myDelegate SETextViewEnterDone:self];
//        }
//        if (self.returnKeyType == UIReturnKeyDone) {
//            [self resignFirstResponder];
//            return NO;
//        }
//    }
//
//    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
//        return [self.myDelegate textView:self shouldChangeTextInRange:range replacementText:text];
//    }
//    return YES;
//}
@end
