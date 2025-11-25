//
//  PasswordView.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 10/28/24.
//

import Foundation

enum PasswordViewType {
    case NewPassword
    case Login
}

protocol PasswordViewDelegate: AnyObject {
    func didTapPayManually()
    func didTapLogin()
}


class PasswordView : UIView {
    
    @IBOutlet weak var loginBtn: CustomButton!
    @IBOutlet weak var payManuallyBtn: CustomButton!
    @IBOutlet weak var btnStack: UIStackView!
    @IBOutlet weak var bottomDescriptionLbl: UILabel!
    @IBOutlet weak var passwordField: PasswordTextField!
    @IBOutlet weak var upperDescriptionLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    weak var delegate: PasswordViewDelegate?
    
    @IBAction func onPayManually(_ sender: Any) {
        delegate?.didTapPayManually()
    }
    
    @IBAction func onLogin(_ sender: Any) {
        passwordField.validateInput()
        if passwordField.inputValid {
            delegate?.didTapLogin()
        }
    }
    
    fileprivate func setupForNewPasswordView() {
        passwordField.isSecureTextEntry = true
        passwordField.text = nil
        upperDescriptionLbl.isHidden = true
        bottomDescriptionLbl.isHidden = false
        btnStack.isHidden = true
        titleLbl.text = "Enter Your Password"
    }
    
    fileprivate func setupForLoginView() {
        passwordField.isSecureTextEntry = true
        passwordField.text = nil
        upperDescriptionLbl.isHidden = false
        bottomDescriptionLbl.isHidden = true
        btnStack.isHidden = false
        titleLbl.text = "Enter Your Password"
    }
    
    fileprivate func enableDisableUserInteraction(enabled: Bool) {
        passwordField.isUserInteractionEnabled = enabled
        btnStack.isUserInteractionEnabled = enabled
        loginBtn.isUserInteractionEnabled = enabled
    }
    
    fileprivate func showLoginLoading(isLoading: Bool) {
        loginBtn.loading = isLoading
    }
    
    func getPassword() -> String? { return passwordField.text }
    
    func setupWithViewType(_ passwordViewType: PasswordViewType) {
        switch passwordViewType {
        case .NewPassword:
            setupForNewPasswordView()
            break
        case .Login:
            setupForLoginView()
            break
        }
    }
    
    func updateUIForState(_ loginState: ShopperLoginState) {
        switch loginState {
        case .initial:
            break
        case .error(_), .noPaymentMethod:
            showLoginLoading(isLoading: false)
            enableDisableUserInteraction(enabled: true)
            break
        case .inProgress:
            showLoginLoading(isLoading: true)
            enableDisableUserInteraction(enabled: false)
            break
        case .paymentMethodsFound(_):
            showLoginLoading(isLoading: false)
            enableDisableUserInteraction(enabled: true)
            break
        case .addNewPaymentMethod(_):
            break
        }
    }
}

