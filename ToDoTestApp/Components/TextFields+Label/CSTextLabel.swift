//
//  CSTitleLabel.swift
//  ToDoTestApp
//
//  Created by Muhammadjon Madaminov on 28/01/25.
//

import UIKit



class CSTextLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //Body textlabel
    convenience init(title: String? = nil, font: UIFont, textAlignment: NSTextAlignment = .center) {
        self.init(frame: .zero)
        self.text = title
        self.font = font
        self.textAlignment = textAlignment
        configure()
    }
    
    //Title textLabel
    convenience init(title: String? = nil, fontSize: CGFloat, textAlignment: NSTextAlignment = .center) {
        self.init(frame: .zero)
        self.text = title
        self.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        self.textAlignment = textAlignment
        titleConfigure()
    }
    
    
    private func titleConfigure() {
        self.textColor = .label
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.9
        numberOfLines = 1
        lineBreakMode = .byTruncatingTail
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configure() {
        self.textColor = .secondaryLabel
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.7
        numberOfLines = 2
        lineBreakMode = .byWordWrapping
        translatesAutoresizingMaskIntoConstraints = false
    }
}

