//
//  PasswordView.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 10/28/24.
//

import Foundation

protocol PaymentMethodsViewDelegate: AnyObject {
    func didSelectPaymentMethod(_ paymentMethod: PaymentMethod, _ view: PaymentMethodsView)
    func didAddPaymentMethod(_ view: PaymentMethodsView)
}


class PaymentMethodsView : UIView, PaymentMethodItemDelegate {
    
    @IBOutlet weak var mainStack: UIStackView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var addImgView: UIImageView!
    @IBOutlet weak var addPaymentMethodStack: UIStackView!
    
    weak var delegate: PaymentMethodsViewDelegate?
    
    @IBOutlet var paymentMethodItems: [PaymentMethodItem] = []
    
    var paymentMethods: [PaymentMethod] = [] {
        didSet {
            guard arePaymentMethodsChanged(newPMs: paymentMethods, oldPMs: oldValue) else
            {
                return
            }
            
            populatePaymentMethods()
        }
    }
    
    var selectedPaymentMethod: PaymentMethod? = nil
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func onAddPaymentMethod() {
        debugPrint("tap gesture")
        delegate?.didAddPaymentMethod(self)  // Notify the delegate
    }
    
    fileprivate func arePaymentMethodsChanged(newPMs: [PaymentMethod], oldPMs: [PaymentMethod]) -> Bool {
        if oldPMs.count != newPMs.count {
            return true
        }
        
        for (index, pm) in newPMs.enumerated() {
            let oldPM = oldPMs[index]
            if oldPM.token != pm.token {
                return true
            }
        }
        
        return false
    }
    
    fileprivate func populatePaymentMethods() {
        setupUI()
       if let startIndex = mainStack.arrangedSubviews.firstIndex(of: titleLbl) {
           for (index, paymentMethod) in paymentMethods.enumerated() {
               let view = getPaymentItemView(paymentMethod)
               if index == 0 {
                   view.selected = true
                   selectedPaymentMethod = paymentMethod
               }
               paymentMethodItems.append(view)
               mainStack.insertArrangedSubview(view, at: startIndex + index + 1)
           }
       }
    }
    
    fileprivate func getPaymentItemView(_ paymentMethod: PaymentMethod) -> PaymentMethodItem {
        return PaymentMethodItem(paymentMethod: paymentMethod, delegate: self)
    }
    
    fileprivate func setupUI() {
        let tapGesture =  UITapGestureRecognizer(target: self, action: #selector(onAddPaymentMethod))
        addPaymentMethodStack.addGestureRecognizer(tapGesture)
        
        addImgView.image = UIImage.fromPod(named: "Add")
        addImgView.contentMode = .scaleAspectFit
    }
    
    //MARK: PaymentMethodItem delegate
    func didSelectPaymentMethod(_ item: PaymentMethodItem, paymentMethod: PaymentMethod) {
        selectedPaymentMethod = paymentMethod
        delegate?.didSelectPaymentMethod(paymentMethod, self)  // Notify the delegate
        paymentMethodItems.forEach { view in
            if view.paymentMethod.token != paymentMethod.token {
                view.selected = false
            }
        }
    }
    
}

