//
//  Checkbox.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 9/15/24.
//

import Foundation
import UIKit

class CheckButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        updateAppearance()
    }
    

    private func updateAppearance() {
        tintColor = Colors.blue
        setTitle("", for: .normal)
        setTitle("", for: .selected)
        setImage(UIImage.fromPod(named: "CheckboxSelected"), for: .selected)
        setImage(UIImage.fromPod(named: "Checkbox"), for: .normal)
    }
}
