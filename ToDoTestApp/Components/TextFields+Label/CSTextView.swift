//
//  CSTextView.swift
//  ToDoTestApp
//
//  Created by Muhammadjon Madaminov on 30/01/25.
//

import UIKit

class CSTextView: UITextView {
    
    var placeholderLabel : UILabel!

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        textAlignment = .left
        font = .preferredFont(forTextStyle: .headline)
        isEditable = true
        translatesAutoresizingMaskIntoConstraints = false
        delegate = self
        configurePlaceholder()
    }
    
    
    func configurePlaceholder() {
        placeholderLabel = UILabel()
        placeholderLabel.text = "Описание.."
        placeholderLabel.font = .italicSystemFont(ofSize: (self.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        self.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (self.font?.pointSize)! / 2)
        placeholderLabel.textColor = .tertiaryLabel
        placeholderLabel.isHidden = !text.isEmpty
    }
}


extension CSTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel?.isHidden = !textView.text.isEmpty
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel?.isHidden = !textView.text.isEmpty
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel?.isHidden = true
    }
}
