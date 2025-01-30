//
//  CSTextField.swift
//  ToDoTestApp
//
//  Created by Muhammadjon Madaminov on 30/01/25.
//

import UIKit

class CSTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        placeholder = "Название"
        
        font = .systemFont(ofSize: 30, weight: .semibold)
        textAlignment = .left
        textColor = .label
        
        autocorrectionType = .no
        autocapitalizationType = .none
        returnKeyType = .done
        translatesAutoresizingMaskIntoConstraints = false
    }
}
