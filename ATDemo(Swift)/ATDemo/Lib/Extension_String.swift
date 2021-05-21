//
//  String_Extension.swift
//  ATDemo
//
//  Created by XWH on 2021/5/16.
//

import Foundation

// MARK: - 字符串截取
// https://www.cnblogs.com/qq9070/p/10271009.html
extension String {
    /// String使用下标截取字符串
    /// string[index] 例如："abcdefg"[3] // c
    subscript (i:Int)->String{
        let startIndex = self.index(self.startIndex, offsetBy: i)
        let endIndex = self.index(startIndex, offsetBy: 1)
        return String(self[startIndex..<endIndex])
    }
    /// String使用下标截取字符串
    /// string[index..<index] 例如："abcdefg"[3..<4] // d
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
            return String(self[startIndex..<endIndex])
        }
    }
    /// String使用下标截取字符串
    /// string[index,length] 例如："abcdefg"[3,2] // de
    subscript (index:Int , length:Int) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let endIndex = self.index(startIndex, offsetBy: length)
            return String(self[startIndex..<endIndex])
        }
    }
    // 截取 从头到i位置
    func substring(to:Int) -> String{
        return self[0..<to]
    }
    // 截取 从i到尾部
    func substring(from:Int) -> String{
        return self[from..<self.count]
    }
    
}

import UIKit

extension String {
    
    /**
     Get the height with the string.
     
     - parameter attributes: The string attributes.
     - parameter fixedWidth: The fixed width.
     
     - returns: The height.
     */
    func heightWithStringAttributes(attributes : [NSAttributedString.Key : AnyObject], fixedWidth : CGFloat) -> CGFloat {
        
        guard self.count > 0 && fixedWidth > 0 else {
            return 0
        }
        
        let size: CGSize = CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))
        let text = self as NSString
        let rect = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return rect.size.height
    }
    
    /**
     Get the height with font.
     
     - parameter font:       The font.
     - parameter fixedWidth: The fixed width.
     
     - returns: The height.
     */
    func heightWithFont(font : UIFont = UIFont.systemFont(ofSize: 18), fixedWidth : CGFloat) -> CGFloat {
        
        guard self.count > 0 && fixedWidth > 0 else {
            return 0
        }
        
        let size: CGSize = CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))
        let text = self as NSString
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context:nil)
        
        return rect.size.height
    }
    
    /**
     Get the width with the string.
     
     - parameter attributes: The string attributes.
     
     - returns: The width.
     */
    func widthWithStringAttributes(attributes : [NSAttributedString.Key : AnyObject]) -> CGFloat {
        
        guard self.count > 0 else {
            return 0
        }
        
        let size: CGSize = CGSize(width: CGFloat(MAXFLOAT), height: 0)

        let text = self as NSString
        let rect = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)

        return rect.size.width
    }
    
    /**
     Get the width with the string.
     
     - parameter font: The font.
     
     - returns: The string's width.
     */
    func widthWithFont(font : UIFont = UIFont.systemFont(ofSize: 18)) -> CGFloat {
        
        guard self.count > 0 else {
            return 0
        }
        
        let size: CGSize = CGSize(width: CGFloat(MAXFLOAT), height: 0)
        let text = self as NSString
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context:nil)

        return rect.size.width
    }
}
