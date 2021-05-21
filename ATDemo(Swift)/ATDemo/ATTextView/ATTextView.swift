//
//  ATTextView.swift
//  ATDemo
//
//  Created by XWH on 2021/5/15.
//

import UIKit

//let kATRegular = "@[\\u{4e00}-\\u{9fa5}\\w\\-\\_]+ "

//let HAS_TEXT_CONTAINER = responds(to: #selector(UITextView.textContainer))
//func HAS_TEXT_CONTAINER_INSETS(_ x: Any) -> UnknownType? {
//    (respondsToSelector as? x)?(#selector(UITextView.textContainerInset))
//}

//private let kAttributedPlaceholderKey = "attributedPlaceholder"
//private let kPlaceholderKey = "placeholder"
//private let kFontKey = "font"
//private let kAttributedTextKey = "attributedText"
//private let kTextKey = "text"
//private let kExclusionPathsKey = "exclusionPaths"
//private let kLineFragmentPaddingKey = "lineFragmentPadding"
//private let kTextContainerInsetKey = "textContainerInset"
//private let kTextAlignmentKey = "textAlignment"

@objc protocol ATTextViewDelegate {
    @objc optional
    func atTextViewDidChange(_ textView: ATTextView) -> Void
    
    @objc optional
    func atTextViewDidBeginEditing(_ textView: ATTextView) -> Void
    
    @objc optional
    func atTextViewDidEndEditing(_ textView: ATTextView) -> Void
}

class ATTextView: UITextView {
    private var changeRange: NSRange! = NSRange(location: 0, length: 0) // 改变Range
    private var isChanged = false // 是否改变
    private var placeholderTextView: UITextView?
    private var max_TextLength = 0
    
    public var attributed_TextColor: UIColor = k_default_attributedTextColor
        
    public weak var atDelegate: ATTextViewDelegate?
    public var cursorLocation = 0
    public var atUserList : [TextViewBinding] {
        get {
            let results : [TextViewBinding] = getResultsListArray(withTextView: self.attributedText)!
            return results
        }
    }
    
    override open var delegate: UITextViewDelegate? {
        get { return self }
        set { _ = newValue } // To satisfy the linter otherwise this would be an empty setter
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
//        maxTextLength = 100000
    }
    
    func getResultsListArray(withTextView attributedString: NSAttributedString) -> [TextViewBinding]? {
        
        var resultArray: [TextViewBinding] = []
        var iExpression: NSRegularExpression? = nil
        do {
            iExpression = try NSRegularExpression(pattern: kATRegular, options: [])
        } catch {
        }
        iExpression?.enumerateMatches(
            in: attributedString.string ,
            options: [],
            range: NSRange(location: 0, length: attributedString.string.count),
            using: { result, flags, stop in
                var resultRange = result!.range
                let atString = attributedString.string[resultRange.location, resultRange.length]
                let bindingModel = attributedString.attribute(NSAttributedString.Key(rawValue: TextBindingAttributeName), at: resultRange.location, longestEffectiveRange: &resultRange, in: NSRange(location: 0, length: atString.count)) as? TextViewBinding
                if let bindingModelNew : TextViewBinding = bindingModel {
                    bindingModelNew.range = result?.range
                    resultArray.append(bindingModelNew)
                }
            })
        return resultArray
    }
}

// MARK: TextView delegate
extension ATTextView: UITextViewDelegate {
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        let results : [TextViewBinding] = getResultsListArray(withTextView: textView.attributedText)!
        var inRange = false
        var tempRange = NSRange(location: 0, length: 0)
        let textSelectedLocation = textView.selectedRange.location
        let textSelectedLength = textView.selectedRange.length

        for i in 0..<results.count {
            let bindingModel = results[i] as TextViewBinding
            let range: NSRange = bindingModel.range
            if textSelectedLength == 0 {
                if textSelectedLocation > range.location && textSelectedLocation < range.location + range.length {
                    inRange = true
                    tempRange = range

                    break
                }
            } else {
                if (textSelectedLocation > range.location && textSelectedLocation < range.location + range.length) || (textSelectedLocation + textSelectedLength > range.location && textSelectedLocation + textSelectedLength < range.location + range.length) {
                    inRange = true
                    break
                }
            }
        }

        if inRange {
            // 解决光标在‘特殊文本’左右时 无法左右移动的问题
            var location = tempRange.location
            if cursorLocation < textSelectedLocation {
                location = tempRange.location + tempRange.length
            }
            textView.selectedRange = NSRange(location: location, length: textSelectedLength)
            if textSelectedLength != 0 {
                // 解决光标在‘特殊文本’内时，文本选中问题
                textView.selectedRange = NSRange(location: textSelectedLocation, length: 0)
            }
        }
        cursorLocation = textView.selectedRange.location
    }
    
    func textViewDidChange(_ textView: UITextView) {
//        if checkAndFilterText(byLength: max_TextLength) {
//            return
//        }

        if textView.markedTextRange == nil {
            if isChanged {
                let tmpAString = NSMutableAttributedString(attributedString: textView.attributedText)
                let changeLocation = changeRange.location
                var changeLength = changeRange!.length
                // 修复中文预输入时，删除最后一个崩溃的问题
                if tmpAString.length == changeLocation {
                    changeLength = 0
                }
//                if changeLength > max_TextLength {
//                    changeLength = max_TextLength
//                }
                tmpAString.setAttributes([
                    NSAttributedString.Key.foregroundColor: attributed_TextColor,
                    NSAttributedString.Key.font: font!
                ], range: NSRange(location: changeLocation, length: changeLength))
                textView.attributedText = tmpAString
                isChanged = false
            }
        }

        if let atDelegateOK = self.atDelegate {
            atDelegateOK.atTextViewDidChange?(textView as! ATTextView)
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 解决UITextView富文本编辑会连续的问题，且预输入颜色不变的问题
        if textView.textStorage.length != 0 {
            textView.typingAttributes = [
                NSAttributedString.Key.font: font!,
                NSAttributedString.Key.foregroundColor: attributed_TextColor
            ]
        }

        if text == "" {
            // 删除
            let selectedRange = textView.selectedRange
            if selectedRange.length != 0 {
                let tmpAString = NSMutableAttributedString(attributedString: textView.attributedText)
                tmpAString.deleteCharacters(in: selectedRange)
                textView.attributedText = tmpAString
                
                let lastCursorLocation = selectedRange.location
                textViewDidChange(textView)
                textView.typingAttributes = [
                    NSAttributedString.Key.font: font!,
                    NSAttributedString.Key.foregroundColor: attributed_TextColor
                ]
                cursorLocation = lastCursorLocation
                textView.selectedRange = NSRange(location: lastCursorLocation, length: 0)
                return false
            } else {
                let results : [TextViewBinding] = getResultsListArray(withTextView: textView.attributedText)!
                for i in 0..<results.count {
                    let bindingModel = results[i] as TextViewBinding
                    let tmpRange: NSRange = bindingModel.range
                    if (range.location + range.length) == (tmpRange.location + tmpRange.length) {
                        
                        let tmpAString = NSMutableAttributedString(attributedString: textView.attributedText)
                        tmpAString.deleteCharacters(in: tmpRange)

                        textView.attributedText = tmpAString
                        
                        textViewDidChange(textView)
                        textView.typingAttributes = [
                            NSAttributedString.Key.font: font!,
                            NSAttributedString.Key.foregroundColor: attributed_TextColor
                        ]
                        return false
                    }
                }
            }
        } else {
            let results : [TextViewBinding] = getResultsListArray(withTextView: textView.attributedText)!
            if results.count != 0 {
                for i in 0..<results.count {
                    let bindingModel = results[i] as TextViewBinding
                    let tmpRange: NSRange = bindingModel.range
                    if ((range.location + range.length) == (tmpRange.location + tmpRange.length) || range.location == 0) {
                        changeRange = NSRange(location: range.location, length: text.count)
                        isChanged = true
                        
                        return true
                    }
                }
            } else {
                // 在第一个删除后 重置text color
                if range.location == 0 {
                    changeRange = NSRange(location: range.location, length: text.count)
                    isChanged = true
                    
                    return true
                }
            }
        }
        return true
    }
}
