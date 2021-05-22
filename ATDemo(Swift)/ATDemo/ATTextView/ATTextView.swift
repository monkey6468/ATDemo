//
//  ATTextView.swift
//  ATDemo
//
//  Created by XWH on 2021/5/15.
//

import UIKit
// placeholder 属性参考了【RSKPlaceholderTextView】

@objc protocol ATTextViewDelegate {
    @objc optional
    func atTextViewDidChange(_ textView: ATTextView) -> Void
    
    @objc optional
    func atTextViewDidBeginEditing(_ textView: ATTextView) -> Void
    
    @objc optional
    func atTextViewDidEndEditing(_ textView: ATTextView) -> Void
}

class ATTextView: UITextView {
    
    // MARK: - Private Properties
    private var placeholderAttributes: [NSAttributedString.Key: Any] {
        var placeholderAttributes = self.typingAttributes
        if placeholderAttributes[.font] == nil {
            placeholderAttributes[.font] = self.font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
        }
        
        if placeholderAttributes[.paragraphStyle] == nil {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = self.textAlignment
            paragraphStyle.lineBreakMode = self.textContainer.lineBreakMode
            placeholderAttributes[.paragraphStyle] = paragraphStyle
        }
        
        placeholderAttributes[.foregroundColor] = self.placeholderTextColor
        return placeholderAttributes
    }
    
    private var placeholderInsets: UIEdgeInsets {
        let placeholderInsets = UIEdgeInsets(top: self.contentInset.top + self.textContainerInset.top,
                                             left: self.contentInset.left + self.textContainerInset.left,
                                             bottom: self.contentInset.bottom + self.textContainerInset.bottom,
                                             right: self.contentInset.right + self.textContainerInset.right)
        return placeholderInsets
    }
    
    private lazy var placeholderLayoutManager: NSLayoutManager = NSLayoutManager()
    private lazy var placeholderTextContainer: NSTextContainer = NSTextContainer()
    
    // MARK: - Open Properties
    /// The attributed string that is displayed when there is no other text in the placeholder text view. This value is `nil` by default.
    @NSCopying open var attributedPlaceholder: NSAttributedString? {
        didSet {
            guard self.attributedPlaceholder != oldValue else {
                return
            }
            if let attributedPlaceholder = self.attributedPlaceholder {
                let attributes = attributedPlaceholder.attributes(at: 0, effectiveRange: nil)
                if let font = attributes[.font] as? UIFont,
                   self.font != font {
                    self.font = font
                    self.typingAttributes[.font] = font
                }
                
                if let foregroundColor = attributes[.foregroundColor] as? UIColor,
                    self.placeholderTextColor != foregroundColor {
                    self.placeholderTextColor = foregroundColor
                }
                
                if let paragraphStyle = attributes[.paragraphStyle] as? NSParagraphStyle,
                    self.textAlignment != paragraphStyle.alignment {
                    let mutableParagraphStyle = NSMutableParagraphStyle()
                    mutableParagraphStyle.setParagraphStyle(paragraphStyle)
                    self.textAlignment = paragraphStyle.alignment
                    self.typingAttributes[.paragraphStyle] = mutableParagraphStyle
                }
            }
            
            guard self.isEmpty == true else {
                return
            }
            self.setNeedsDisplay()
        }
    }
    
    /// Determines whether or not the placeholder text view contains text.
    open var isEmpty: Bool { return self.text.isEmpty }
    
    /// The string that is displayed when there is no other text in the placeholder text view. This value is `nil` by default.
    @IBInspectable open var placeholder: NSString? {
        get {
            return self.attributedPlaceholder?.string as NSString?
        }
        set {
            if let newValue = newValue as String? {
                self.attributedPlaceholder = NSAttributedString(string: newValue, attributes: self.placeholderAttributes)
            } else {
                self.attributedPlaceholder = nil
            }
        }
    }
    
    /// The color of the placeholder. This property applies to the entire placeholder string. The default placeholder color is `UIColor(white: 0.7, alpha: 0.7)`.
    @IBInspectable open var placeholderTextColor: UIColor = UIColor(white: 0.7, alpha: 0.7) {
        didSet {
            if let placeholder = self.placeholder as String? {
                self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: self.placeholderAttributes)
            }
        }
    }
    
    // MARK: - Superclass Properties
    open override var attributedText: NSAttributedString! { didSet { self.setNeedsDisplay() } }
    open override var bounds: CGRect { didSet { self.setNeedsDisplay() } }
    open override var contentInset: UIEdgeInsets { didSet { self.setNeedsDisplay() } }
    open override var font: UIFont? {
        didSet {
            if let placeholder = self.placeholder as String? {
                self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: self.placeholderAttributes)
            }
        }
    }
    
    open override var textAlignment: NSTextAlignment {
        didSet {
            if let placeholder = self.placeholder as String? {
                self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: self.placeholderAttributes)
            }
        }
    }
    
    open override var textContainerInset: UIEdgeInsets { didSet { self.setNeedsDisplay() } }
    open override var typingAttributes: [NSAttributedString.Key: Any] {
        didSet {
            if let placeholder = self.placeholder as String? {
                self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: self.placeholderAttributes)
            }
        }
    }
    
    // MARK: - Object Lifecycle
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInitializer()
    }
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.commonInitializer()
    }
    
    // MARK: - Superclass API
    open override func caretRect(for position: UITextPosition) -> CGRect {
        guard self.text.isEmpty == true,
            let attributedPlaceholder = self.attributedPlaceholder,
            attributedPlaceholder.length > 0 else {
            return super.caretRect(for: position)
        }
        
        var caretRect = super.caretRect(for: position)
        let placeholderLineFragmentUsedRect = self.placeholderLineFragmentUsedRectForGlyphAt0GlyphIndex(attributedPlaceholder: attributedPlaceholder)
        
        let userInterfaceLayoutDirection: UIUserInterfaceLayoutDirection
        if #available(iOS 10.0, *) {
            userInterfaceLayoutDirection = self.effectiveUserInterfaceLayoutDirection
        }
        else {
            userInterfaceLayoutDirection = UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute)
        }
        
        let placeholderInsets = self.placeholderInsets
        switch userInterfaceLayoutDirection {
        case .rightToLeft:
            caretRect.origin.x = placeholderInsets.left + placeholderLineFragmentUsedRect.maxX - self.textContainer.lineFragmentPadding
        case .leftToRight:
            fallthrough
        @unknown default:
            caretRect.origin.x = placeholderInsets.left + placeholderLineFragmentUsedRect.minX + self.textContainer.lineFragmentPadding
        }
        return caretRect
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard self.isEmpty == true else {
            return
        }
        
        guard let attributedPlaceholder = self.attributedPlaceholder else {
            return
        }
        
        var inset = self.placeholderInsets
        inset.left += self.textContainer.lineFragmentPadding
        inset.right += self.textContainer.lineFragmentPadding
        
        let placeholderRect = rect.inset(by: inset)
        attributedPlaceholder.draw(in: placeholderRect)
    }
    
   
    
    
    
    
    
    // MARK: - Private Properties
    private var changeRange: NSRange! = NSRange(location: 0, length: 0) // 改变Range
    private var isChanged = false // 是否改变
    private var placeholderTextView: UITextView?
    private var max_TextLength = 0
    
    // MARK: - Open Properties
    
    /// 输入文本  attributedTextColor 。默认UIColor.black
    public var attributedTextColor: UIColor = k_default_attributedTextColor
        
    public weak var atDelegate: ATTextViewDelegate?
    public var cursorLocation = 0
    
    /// 获取所有 特殊文本 数组
    public var atUserList : [TextViewBinding] {
        get {
            let results : [TextViewBinding] = getResultsListArray(withTextView: self.attributedText)!
            return results
        }
    }
}

// MARK: - PlaceHolder 私有API
extension ATTextView {
    
    private func commonInitializer() {
        
        self.contentMode = .topLeft
        
        NotificationCenter.default.addObserver(self, selector: #selector(ATTextView.handleTextViewTextDidChangeNotification(_:)), name: UITextView.textDidChangeNotification, object: self)
    }
    
    @objc internal func handleTextViewTextDidChangeNotification(_ notification: Notification) {
        
        guard let object = notification.object as? ATTextView, object === self else {
            
            return
        }
        self.setNeedsDisplay()
    }
    
    private func placeholderLineFragmentUsedRectForGlyphAt0GlyphIndex(attributedPlaceholder: NSAttributedString) -> CGRect {
        
        if self.placeholderTextContainer.layoutManager == nil {
            
            self.placeholderLayoutManager.addTextContainer(self.placeholderTextContainer)
        }
        
        let placeholderTextStorage = NSTextStorage(attributedString: attributedPlaceholder)
        placeholderTextStorage.addLayoutManager(self.placeholderLayoutManager)
        
        self.placeholderTextContainer.lineFragmentPadding = self.textContainer.lineFragmentPadding
        self.placeholderTextContainer.size = CGSize(width: self.textContainer.size.width, height: 0.0)
        
        self.placeholderLayoutManager.ensureLayout(for: self.placeholderTextContainer)
        
        return self.placeholderLayoutManager.lineFragmentUsedRect(forGlyphAt: 0, effectiveRange: nil)
    }
}

// MARK: - 艾特【特殊文本】 私有API
extension ATTextView {
    
    override open var delegate: UITextViewDelegate? {
        get { return self }
        set { _ = newValue } // To satisfy the linter otherwise this would be an empty setter
    }
    
    override func awakeFromNib() {
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


// MARK: UITextViewDelegate
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
                    NSAttributedString.Key.foregroundColor: attributedTextColor,
                    NSAttributedString.Key.font: font!
                ], range: NSRange(location: changeLocation, length: changeLength))
                textView.attributedText = tmpAString
                isChanged = false
            }
        }

        if let atDelegateOK = self.atDelegate {
            atDelegateOK.atTextViewDidChange!(textView as! ATTextView)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let atDelegateOK = self.atDelegate {
            atDelegateOK.atTextViewDidBeginEditing!(textView as! ATTextView)
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if let atDelegateOK = self.atDelegate {
            atDelegateOK.atTextViewDidEndEditing!(textView as! ATTextView)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 解决UITextView富文本编辑会连续的问题，且预输入颜色不变的问题
        if textView.textStorage.length != 0 {
            textView.typingAttributes = [
                NSAttributedString.Key.font: font!,
                NSAttributedString.Key.foregroundColor: attributedTextColor
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
                    NSAttributedString.Key.foregroundColor: attributedTextColor
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
                            NSAttributedString.Key.foregroundColor: attributedTextColor
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
