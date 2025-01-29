//
//  CSToggleButton.swift
//  ToDoTestApp
//
//  Created by Muhammadjon Madaminov on 28/01/25.
//

import UIKit


class CSToggleButton: UIButton {
    private let offStrokeColor = UIColor.systemGray.cgColor
    private let onStrokeColor = UIColor.systemYellow.cgColor
    private let strokeWidth: CGFloat = 2.0
    
    var onToggle: ((Bool) -> Void)?
    
    private lazy var checkmarkImage: UIImage? = {
        UIImage(
            systemName: "checkmark",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: bounds.width/2, weight: .bold)
        )?.withTintColor(.yellow, renderingMode: .alwaysOriginal)
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        addTarget(self, action: #selector(toggleState), for: .touchUpInside)
        translatesAutoresizingMaskIntoConstraints = false
        layer.borderWidth = strokeWidth
        backgroundColor = .clear
        updateAppearance()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.width / 2
        checkmarkImage = UIImage(
            systemName: "checkmark",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: bounds.width/2, weight: .bold)
        )?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        updateAppearance()
    }
    
    
    @objc private func toggleState() {
        isSelected.toggle()
        updateAppearance()
        onToggle?(isSelected)
    }
    
    private func updateAppearance() {
        layer.borderColor = isSelected ? onStrokeColor : offStrokeColor
        setImage(isSelected ? checkmarkImage : nil, for: .normal)
        imageView?.contentMode = .scaleAspectFit
    }
    
    func setState(isCompleted: Bool) {
        isSelected = isCompleted
        updateAppearance()
    }
}


import SwiftUI
#Preview {
    UIViewPreview(view: CSToggleButton(frame: .init(x: 0, y: 0, width: 200, height: 200)))
        .frame(width: 40, height: 40)
}
