//
//  PaymentSuccessController.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 9/16/24.
//

import UIKit

class PaymentSuccessController: UIViewController {
    
    @IBOutlet weak var safepayImageView: UIImageView!
    @IBOutlet weak var bottomSheet: UIView!
    
    static func initWithNib() -> PaymentSuccessController? {
        let successController = PaymentSuccessController(nibName: "PaymentSuccessController", bundle: Bundle(for: PaymentSuccessController.self) )
        return successController
    }

    @IBOutlet weak var checkImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

       bottomSheetUI()
    }

    private func bottomSheetUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        bottomSheet.backgroundColor = UIColor.white
        bottomSheet.clipsToBounds = true
        bottomSheet.layer.cornerRadius = 20
        bottomSheet.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        bottomSheet.layer.masksToBounds = false
        bottomSheet.layer.shadowColor = UIColor.black.cgColor
        bottomSheet.layer.shadowOpacity = 0.1
        view.backgroundColor = UIColor.clear
        safepayImageView.image = UIImage.fromPod(named: "safepay")
    }

    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
