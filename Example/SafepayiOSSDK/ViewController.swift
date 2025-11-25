//
//  ViewController.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 09/01/2024.
//  Copyright (c) 2024 Irfan Gul. All rights reserved.
//

import UIKit
import SafepayiOSSDK

class ViewController: UIViewController {

    @IBOutlet weak var trackerField: UITextField!
    @IBOutlet weak var tBTField: UITextField!
    @IBOutlet weak var addressField: UITextField!

    @IBOutlet weak var lblStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaults()
        setFieldStyle()
    }
    
    func setFieldStyle() {
        trackerField.borderStyle = .none
        trackerField.layer.borderWidth = 1.0
        trackerField.layer.borderColor = UIColor.lightGray.cgColor
        trackerField.layer.cornerRadius = 5.0
        
        tBTField.borderStyle = .none
        tBTField.layer.borderWidth = 1.0
        tBTField.layer.borderColor = UIColor.lightGray.cgColor
        tBTField.layer.cornerRadius = 5.0
        
        addressField.borderStyle = .none
        addressField.layer.borderWidth = 1.0
        addressField.layer.borderColor = UIColor.lightGray.cgColor
        addressField.layer.cornerRadius = 5.0
    }
    
    func setDefaults() {
        trackerField.text = "track_4ca17dfa-ce9d-4809-911b-6a3931db3bec"
        tBTField.text = "xUXTRgITVcHrwrud2sau_w5jIJVyQZ5WwE76SwxHF63RJhSnyqdrcPMr2V5kwS9yz3p-D-ZrWg=="
        addressField.text = "address_5ce54f87-a823-4da6-8990-7b26d048ce00"
    }

    @IBAction func onPress(_ sender: Any) {
        
        let addressToken = (addressField.text?.isEmpty ?? true) ? nil : addressField.text
        
        guard let tracker = trackerField.text, let tbt = tBTField.text else {
            return
        }

        
        let config = SafepayConfiguration(trackerToken: tracker,
                                          sandbox: true,
                                          timeBasedToken: tbt,
                                          showSuccessSheet: true,
                                          addressToken: addressToken)
        
        let paymentSheet = SafepayPaymentSheet(configuration: config)
        paymentSheet.present(from: self) { result in
            switch result {
            case .success:
                self.lblStatus.text = "Payment is successful"
                self.lblStatus.textColor = .green
                print("Success \(result)")
            case .cancelled:
                self.lblStatus.text = "Payment Cancelled by user"
                self.lblStatus.textColor = .red
                print("Cancelled \(result)")
            case .failed(let errorResponse):
                self.lblStatus.text = "Payment Error: \(errorResponse)"
                self.lblStatus.textColor = .red
                print("Failed \(errorResponse)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

