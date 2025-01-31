//
//  Previewable.swift
//  ToDoTestApp
//
//  Created by Muhammadjon Madaminov on 28/01/25.
//

import SwiftUI
import UIKit

struct ViewControllerPreview: UIViewControllerRepresentable {
    let viewController: UIViewController

    init(vc: UIViewController) {
        self.viewController = vc
    }

    func makeUIViewController(context: Context) -> UIViewController {
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No dynamic updates needed for static previews
    }
}


struct UIViewPreview: UIViewRepresentable {
    let view: UIView

    init(view: UIView) {
        self.view = view
    }

    func makeUIView(context: Context) -> UIView {
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No dynamic updates needed for static previews
    }
}
