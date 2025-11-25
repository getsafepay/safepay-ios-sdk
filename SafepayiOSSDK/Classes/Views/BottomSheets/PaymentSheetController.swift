//
//  PaymentSheetController.swift
//  SafepayiOSSDK
//
//  Created by Irfan Gul on 9/9/24.
//

import UIKit
import Combine
import FlagPhoneNumber

class PaymentSheetController: UIViewController {
    static func initWithNib(viewModel: PaymentViewModel) -> PaymentSheetController? {
        let paymentSheetController = PaymentSheetController(nibName: "PaymentSheetController", bundle: Bundle(for: PaymentSheetController.self) )
        paymentSheetController.viewModel = viewModel
        return paymentSheetController
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomSheet: UIView!

    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var paymentMethodView: PaymentMethodsView!
    @IBOutlet var passwordView: PasswordView!
    @IBOutlet weak var saveCardBtn: CheckButton!
    
    @IBOutlet weak var phoneNoField: PhoneNumberTextField!
    @IBOutlet weak var emailField: EmailField!
    
    @IBOutlet weak var bottomSheetHeightConstraint: NSLayoutConstraint!
    
    //card info
    @IBOutlet weak var cardNoField: CustomTextField!
    @IBOutlet weak var cardExpiryField: CustomTextField!
    @IBOutlet weak var cvcField: CustomTextField!
    
    //billing info
    @IBOutlet weak var lNameField: CustomTextField!
    @IBOutlet weak var fNameField: CustomTextField!
    @IBOutlet weak var streetAddressField: AddressField!
    @IBOutlet weak var cityField: AddressField!
    @IBOutlet weak var countryField: CountryField!
    @IBOutlet weak var stateField: AddressField!
    @IBOutlet weak var zipCodeField: AddressField!
    
    @IBOutlet weak var payButton: PayButton!
    @IBOutlet weak var safepayImageView: UIImageView!

    @IBOutlet weak var paymentErrorView: UIView!
    @IBOutlet weak var paymentErrorLbl: UILabel!
    
    @IBOutlet weak var cardDetailsLbl: UILabel!
    
    @IBOutlet weak var checkboxContainerView: UIView!
    @IBOutlet weak var countryContainerView: UIView!
    @IBOutlet weak var savedCardButtonContainer: UIView!
    @IBOutlet weak var billingLbl: UILabel!

    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var stackCountry: UIStackView!
    @IBOutlet weak var stackName: UIStackView!
    @IBOutlet weak var stackExpiry: UIStackView!
    @IBOutlet weak var cardlblView: UIView!
    @IBOutlet weak var billinglblView: UIView!
    @IBOutlet weak var footerStack: UIStackView!
    
    weak var initialLoader: CustomIndicatorView?
    var keyboardHeight = 0.0
    
    var viewModel: PaymentViewModel? // Your ViewModel
    private var cancellables = Set<AnyCancellable>() // To store subscriptions
    var initialBounds: CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        setupUI()
        setupValidityDelegate()
        bottomSheetUI()
        registerKeyboardNotification()
        dismissKeyboardOnTap()
    }
    
    private func dismissKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resignKeyboard))
        self.bottomSheet.addGestureRecognizer(tapGesture)
    }
    
    @objc func resignKeyboard() {
        bottomSheet.endEditing(true)
    }
    
    private func registerKeyboardNotification() {
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    deinit {
        // Remove observers when no longer needed
        NotificationCenter.default.removeObserver(self)
    }
    
    // Adjust the constraint when the keyboard appears
    @objc func keyboardWillShow(_ notification: Notification) {
       if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
           keyboardHeight = keyboardSize.height
           
           // Adjust the bottom constraint to match the keyboard's height
           bottomConstraint.constant = (keyboardHeight - footerStack.frame.height - 16)
           adjustSheetHeight()

            // Animate the layout changes
            UIView.animate(withDuration: 0.3) {
             self.view.layoutIfNeeded()
            }
       }
    }

    
    // Reset the constraint when the keyboard disappears
    @objc func keyboardWillHide(_ notification: Notification) {
        bottomConstraint.constant = 16
        keyboardHeight = 0
        adjustSheetHeight()

       // Animate the layout changes
       UIView.animate(withDuration: 0.3) {
           self.view.layoutIfNeeded()
       }
    }
    
    private func adjustSheetHeight() {
        let window = UIApplication.shared.windows.first
        let safeareaTopPadding = window?.safeAreaInsets.top ?? 0
        let safeareaBottomPadding = window?.safeAreaInsets.bottom ?? 0
        
        mainStackView.layoutIfNeeded()
        footerStack.layoutIfNeeded()
        let stackHeight = mainStackView.frame.height
        let verticalSpaceBTWStackAndFooter = 20.0
        
        let footerHeight = footerStack.frame.height + safeareaBottomPadding + verticalSpaceBTWStackAndFooter
        let required = (stackHeight + footerHeight + keyboardHeight)
        let superViewHeight = view.frame.height - safeareaTopPadding
        
        let c = required < superViewHeight ? required : superViewHeight
        debugPrint("stack: \(stackHeight) required: \(required) superView: \(superViewHeight) final: \(c)")
       
        UIView.animate(withDuration: 0.3) {
            self.bottomSheetHeightConstraint.constant = c
            self.bottomSheet.layoutIfNeeded()
        }
    }
    
    private func showOverlay(){
        UIView.animate(withDuration: 0.5) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        }
    }
    
    private func dismissBottomsheet( completion: (() -> Void)? = nil){
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        } completion: { complete in
            self.dismiss(animated: true, completion: completion)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let delayInSeconds = 0.1 // Delay time
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
            // Code to execute after delay
            self.showOverlay()
        }
    }
    
    private func showInitialLoader(){
        emailField.isHidden = true
        payButton.isHidden = true
        hideError()
        let loader = CustomIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50), color: Colors.blue)
        loader.isHidden = true
        bottomSheet.addSubview(loader)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.centerXAnchor.constraint(equalTo: bottomSheet.centerXAnchor).isActive = true
        loader.centerYAnchor.constraint(equalTo: bottomSheet.centerYAnchor, constant: -25).isActive = true
        loader.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loader.widthAnchor.constraint(equalToConstant: 50).isActive = true
        loader.startAnimating()
        initialLoader = loader
    }
    
    private func showEmailField() {
        self.emailField.alpha = 0
        self.payButton.alpha = 0
        self.emailField.isHidden = false
        self.payButton.isHidden = false
        hideError()
        UIView.animate(withDuration: 0.5, animations: {
            // Change the alpha to 0 (hidden) or 1 (visible)
            self.emailField.alpha = 1
            self.payButton.alpha = 1
        })
        
        initialLoader?.removeFromSuperview()
        adjustSheetHeight()
    }
    
    private func showFullsheetError(error: PaymentError) {
        showError(error: error)
        initialLoader?.stopAnimating()
        initialLoader?.removeFromSuperview()
        self.emailField.isHidden = true
        self.payButton.isHidden = true
        bottomSheet.setNeedsLayout()
        adjustSheetHeight()
    }
    
    private func showError(error: PaymentError) {
        paymentErrorLbl.text = error.formattedError()
        paymentErrorLbl.isHidden = false
        paymentErrorView.isHidden = false

        paymentErrorLbl.numberOfLines = 3
        adjustSheetHeight()
    }
    
    private func hideError() {
        guard !paymentErrorLbl.isHidden else {
            return
        }
        
        paymentErrorLbl.text = ""
        paymentErrorLbl.isHidden = true
        paymentErrorView.isHidden = true

        adjustSheetHeight()
    }
    
    private func enableUserInteraction(enabled: Bool) {
        payButton.isUserInteractionEnabled = enabled
        emailField.isUserInteractionEnabled = enabled
        phoneNoField.isUserInteractionEnabled = enabled
        passwordView.isUserInteractionEnabled = enabled
        cardNoField.isUserInteractionEnabled = enabled
        cardExpiryField.isUserInteractionEnabled = enabled
        cvcField.isUserInteractionEnabled = enabled
        fNameField.isUserInteractionEnabled = enabled
        lNameField.isUserInteractionEnabled = enabled
        countryContainerView.isUserInteractionEnabled = enabled
        cityField.isUserInteractionEnabled = enabled
        streetAddressField.isUserInteractionEnabled = enabled
        stateField.isUserInteractionEnabled = enabled
        zipCodeField.isUserInteractionEnabled = enabled
        checkboxContainerView.isUserInteractionEnabled = enabled
        savedCardButtonContainer.isUserInteractionEnabled = enabled
    }
    
    private func setAmount(_ amount: Int, currency: String) {
        let symbol = CurrencyUtil.symbolFor(currencyCode: currency)
        let majorAmount = CurrencyUtil.convertMinorToMajor(currencyCode: currency, minorAmount: amount)
        guard let sym = symbol , let majAmt = majorAmount else {
            self.payButton.setTitle("Pay Now", for: .normal)
            self.payButton.setTitle("Pay Now", for: .disabled)
            return
        }
      
        self.payButton.setTitle("Pay \(sym) \(majAmt)", for: .normal)
        self.payButton.setTitle("Pay \(sym) \(majAmt)", for: .disabled)
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
    }
    
    fileprivate func setPlaceholders() {
        emailField.placeholder = "Enter your email address"
        phoneNoField.placeholder = "Mobile phone number"
        cardNoField.placeholder = "Card number"
        cvcField.placeholder = "CVC"
        fNameField.placeholder = "First name"
        lNameField.placeholder = "Last name"
        cityField.placeholder = "City"
        countryField.placeholder = "Country"
        streetAddressField.placeholder = "Street address"
        zipCodeField.placeholder = "Post code"
        stateField.placeholder = "State"
    }
    
    fileprivate func resetFields() {
        debugPrint("reseting fields")
        phoneNoField.text = nil
        cardNoField.text = nil
        cvcField.text = nil
        cardExpiryField.text = nil
        fNameField.text = nil
        lNameField.text = nil
        cityField.text = nil
        zipCodeField.text = nil
        stateField.text = nil
        passwordView.setupWithViewType(.Login)
        saveCardBtn.isSelected = false

        if let addressState = viewModel?.findAddressState {
            handleFindAddressState(addressState)
        }
    }
    
    fileprivate func setValidators() {
        countryField.validator = CityValidator()
        emailField.validator = EmailValidator()
        fNameField.validator = NameValidator()
        lNameField.validator = NameValidator()
        streetAddressField.validator = StreetAddressValidator()
        zipCodeField.validator = StreetAddressValidator()
        stateField.validator = StreetAddressValidator()
        cityField.validator = CityValidator()
    }
    
    private func setupUI() {
        emailField.delegate = self
        emailField.keyboardType = .emailAddress
        phoneNoField.delegate = self
        payButton.setTitle("Pay Rs \(0.0)", for: .normal)
        payButton.isEnabled = false
        phoneNoField.setFlag(countryCode: FPNCountryCode.PK)
   
        safepayImageView.image = UIImage.fromPod(named: "safepay")
        safepayImageView.contentMode = .scaleAspectFit
        setValidators()
        setPlaceholders()
        changeUIElementVisibility(isHidden: true)
        changePhoneFieldVisibilty(isHidden: true)
        passwordView.isHidden = true
        passwordView.delegate = self
        paymentMethodView.delegate = self
        self.cancelBtn.isHidden = true
        hideError()
    }
    
    private func changeUIElementVisibility(isHidden hidden: Bool) {
        // if already hidden just adjust height return
        if hidden && cardNoField.isHidden {
            adjustSheetHeight()
            return
        }
        
        cardNoField.isHidden = hidden
        cardNoField.isUserInteractionEnabled = !hidden

        cardDetailsLbl.isHidden = hidden
        cardlblView.isHidden = hidden
        
        checkboxContainerView.isHidden = hidden
        countryContainerView.isHidden = hidden
        billingLbl.isHidden = hidden
        billinglblView.isHidden = hidden
        
        stackName.isHidden = hidden
        fNameField.isUserInteractionEnabled = !hidden
        lNameField.isUserInteractionEnabled = !hidden

        stackExpiry.isHidden = hidden
        cardExpiryField.isUserInteractionEnabled = !hidden
        cvcField.isUserInteractionEnabled = !hidden

        //Billing Address fields
        stackCountry.isHidden = hidden
        streetAddressField.isHidden = streetAddressField.required ? hidden : true
        streetAddressField.isUserInteractionEnabled = !hidden
        stateField.isHidden = stateField.required ? hidden : true
        zipCodeField.isHidden = zipCodeField.required ? hidden : true
        cityField.isHidden = cityField.required ? hidden : true
        cityField.isUserInteractionEnabled = !hidden
        
        if hidden {
            passwordView.isHidden = true
        }
        
        let payManually = viewModel?.payManually ?? false
        
        let hideSaveCardOption = (viewModel?.shopperLoginState.isShopperLoggedIn() ?? false  || payManually)
        if hideSaveCardOption {
            checkboxContainerView.isHidden = hideSaveCardOption
        }
                
        adjustSheetHeight()
    }
    
    private func changePhoneFieldVisibilty(isHidden hidden: Bool) {
        if self.phoneNoField.isHidden == hidden {
            return
        }

        DispatchQueue.main.async {
            self.phoneNoField.isHidden = hidden
            self.view.layoutIfNeeded()
            self.adjustSheetHeight()
        }
    }
    
    fileprivate func populateSavedAddressIfCountryMatches(address: Address) {
        guard countryField.country?.rawValue == address.country else {
            return
        }
        
        if !address.city.isEmpty {
            cityField.text = address.city
            cityField.validateInput()
        }
        
        if !address.street1.isEmpty {
            streetAddressField.text = address.street1
            streetAddressField.validateInput()
        }
        
        if !address.street1.isEmpty {
            zipCodeField.text = address.postalCode
            zipCodeField.validateInput()
        }
        
        if !address.street1.isEmpty {
            stateField.text = address.state
            stateField.validateInput()
        }
    }
    
    fileprivate func setCountryFields(_ countryInfo: (country: String, code: String)) {
        if let countryCode = FPNCountryCode(rawValue: countryInfo.code) {
            self.countryField.text = countryInfo.country
            self.countryField.country = countryCode
            self.phoneNoField.setFlag(countryCode: countryCode)
        }
    }
    
    fileprivate func populateTrackerResponse(_ response: FetchPaymentResponse) {
        let amount = response.data.purchaseTotals.quoteAmount.amount
        let currency = response.data.purchaseTotals.quoteAmount.currency
        self.setAmount(amount, currency: currency)
        
        let countryInfo = CurrencyToCountryUtil.countryAndCode(currencyCode: currency)
        setCountryFields(countryInfo)
    }
    
    private func setupAddressFields(addressMeta: AddressMeta) {
        let fields = ["AdministrativeArea": self.stateField!,
                      "Locality": self.cityField!,
                      "PostCode": self.zipCodeField!,
                      "StreetAddress": self.streetAddressField!]
      
        for field in fields.values {
            field.required = false
        }
        
        for meta in addressMeta.required {
            guard let field = fields[meta] else {
                continue
            }
            
            guard let addressComponent = addressMeta.getAddressComponentByName(meta) else {
                continue
            }
            
            field.addressComponent =  addressComponent
        }
        
        if !cardNoField.isHidden {
            for field in fields.values {
                field.isHidden = !field.required
            }
            validateInput()
            adjustSheetHeight()
        }
    }
    
    private func setupValidityDelegate() {
        cardNoField.validityDelegate = self
        cardExpiryField.validityDelegate = self
        cvcField.validityDelegate = self
        emailField.validityDelegate = self
        phoneNoField.validityDelegate = self
        fNameField.validityDelegate = self
        lNameField.validityDelegate = self
        streetAddressField.validityDelegate = self
        stateField.validityDelegate = self
        zipCodeField.validityDelegate = self
        cityField.validityDelegate = self
        countryField.validityDelegate  = self
        passwordView.passwordField.validityDelegate = self
    }
    
    private func validateInput() {
        if viewModel?.shopperLoginState == .paymentMethodsFound([]) {
            if paymentMethodView.selectedPaymentMethod == nil {
                payButton.isEnabled = false
                return
            }
           
            payButton.isEnabled = true
            hideError()
            return
        }
        
        let isShopperLoggedIn = viewModel?.shopperLoginState.isShopperLoggedIn() ?? false
        
        let passIsValid = passwordView.isHidden ? true : passwordView.passwordField.inputValid
        let emailIsValid = emailField.inputValid
        let phoneIsValid = isShopperLoggedIn ? true : phoneNoField.inputValid
        let cardNoIsValid = cardNoField.inputValid
        let cardExpiryIsValid = cardExpiryField.inputValid
        let cvcIsValid = cvcField.inputValid
        let fNameIsValid = fNameField.inputValid
        let lNameIsValid = lNameField.inputValid
        let countryIsValid = countryField.inputValid

        let cityIsValid = cityField.required ? cityField.inputValid : true
        let streetAddressIsValid = streetAddressField.required ? streetAddressField.inputValid : true
        let stateIsValid =  stateField.required ? stateField.inputValid : true
        let zipcodeIsValid =  zipCodeField.required ? zipCodeField.inputValid : true

        let allFieldsValid = emailIsValid && phoneIsValid && cardNoIsValid && cardExpiryIsValid && cvcIsValid && fNameIsValid && lNameIsValid && cityIsValid && countryIsValid && streetAddressIsValid && passIsValid && stateIsValid && zipcodeIsValid
        payButton.isEnabled = allFieldsValid
        hideError()
    }
    
    private func defaultValues() {
                emailField.text = "irfangul92@gmail.co"
                phoneNoField.text = "3308582842"
                phoneNoField.setFlag(countryCode: FPNCountryCode.PK)
                cardNoField.text = "4111111111111111"
                cardExpiryField.text = "12/25"
                cvcField.text = "123"
                fNameField.text = "Irfan"
                lNameField.text = "Gul"
                cityField.text = "Karachi"
                streetAddressField.text = "Landhi"
        countryField.text = "Pakistan"
        countryField.country = FPNCountryCode.PK
        
        validateInput()
    }
    
    fileprivate func hideViewAnimated(_ view: UIView, shouldRemoveFromSuperview: Bool = false) {
        if view.superview == nil {
            return
        }
        
        let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            view.alpha = 0
        }
        animation.startAnimation()
        animation.addCompletion { position in
            if position == .end {
                let hideAnimation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
                    view.isHidden = true
                }
                hideAnimation.startAnimation()
                hideAnimation.addCompletion { position in
                    if position == .end {
                        if shouldRemoveFromSuperview {
                            view.removeFromSuperview()
                        }
                        self.adjustSheetHeight()
                    }
                }
            }
        }
    }
    
    fileprivate func showHideLoginWithPassView(isHidden: Bool) {
        if isHidden {
            hideViewAnimated(passwordView, shouldRemoveFromSuperview: true)
            return
        }
        
        passwordView.removeFromSuperview()
        passwordView.setupWithViewType(.Login)
       
        passwordView.isHidden = false
        passwordView.alpha = 0

        if let index = mainStackView.arrangedSubviews.firstIndex(of: emailField) {
            mainStackView.insertArrangedSubview(passwordView, at: index + 1) // Insert after existingView1
            adjustSheetHeight()

            let animation = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut) { [self] in
                passwordView.alpha = 1
            }
            
            animation.startAnimation(afterDelay: 0.3)
            animation.addCompletion { position in
                if position == .end {
                    self.scrollToBottom(animated: true)
                }
            }
        }
    }
    
    fileprivate func showHideSaveCardButton(isHidden: Bool) {
        self.savedCardButtonContainer.isHidden = isHidden
    }
    
    fileprivate func showHideNewPasswordView(_ hidden: Bool) {
        if hidden {
            hideViewAnimated(passwordView, shouldRemoveFromSuperview: true)
            return
        }
        
        passwordView.removeFromSuperview()
        passwordView.setupWithViewType(.NewPassword)
       
        passwordView.isHidden = false
        passwordView.alpha = 0

        if let index = mainStackView.arrangedSubviews.firstIndex(of: checkboxContainerView) {
            mainStackView.insertArrangedSubview(passwordView, at: index + 1) // Insert after existingView1
            adjustSheetHeight()

            let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) { [self] in
                passwordView.alpha = 1
            }
            
            animation.startAnimation(afterDelay: 0.3)
            animation.addCompletion { position in
                if position == .end {
                    self.scrollToBottom(animated: true)
                }
            }
        }
    }
    
    fileprivate func hidePaymentMethodView() {
        paymentMethodView.isHidden = true
        paymentMethodView.removeFromSuperview()
    }
    
    fileprivate func showPaymentMethodView() {
        paymentMethodView.isHidden = false
        paymentMethodView.alpha = 0

        if let index = mainStackView.arrangedSubviews.firstIndex(of: emailField) {
            mainStackView.insertArrangedSubview(paymentMethodView, at: index + 1) // Insert after existingView1
            adjustSheetHeight()

            let animation = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) { [self] in
                paymentMethodView.alpha = 1
            }
            
            animation.startAnimation(afterDelay: 0.3)
            animation.addCompletion { position in
                if position == .end {
                    self.scrollToBottom(animated: true)
                }
            }
        }
    }
    
    func scrollToBottom(animated: Bool) {
        // Calculate the bottom offset
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
        
        // Ensure the offset is not less than zero (to prevent invalid scroll positions)
        if bottomOffset.y > 0 {
            scrollView.setContentOffset(bottomOffset, animated: animated)
        }
    }
    
    // MARK: - Actions and Button events
    @IBAction func onTerms(_ sender: Any) {
        ExternalIntentUtility.openLinkInSafari(Constants.tosLink)
    }
    
    @IBAction func onPrivacy(_ sender: Any) {
        ExternalIntentUtility.openLinkInSafari(Constants.privacyLink)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        if let pms = viewModel?.shopperLoginState.getPaymentMethods() {
            viewModel?.shopperLoginState = .paymentMethodsFound(pms)
        }
    }
    
    @IBAction func onCountryField(_ sender: Any) {
        let listController: FPNCountryListViewController = FPNCountryListViewController(style: .insetGrouped)
        listController.showCountryPhoneCode = false
        listController.setup(repository: phoneNoField.countryRepository)
        listController.title = "Select Country"
        listController.didSelect = { [weak self] country in
            self?.countryField.text = country.name
            self?.countryField.country = country.code
           
            Task {
                await self?.viewModel?.getAddressMeta(countryCode: country.code.rawValue)
            }
        }
        let navigationViewController = UINavigationController(rootViewController: listController)
        
        present(navigationViewController, animated: true, completion: nil)
    }
    
    @IBAction func onSaveCard(_ sender: Any) {
        guard let btn = sender as? UIButton else {
            return
        }
        
        btn.isSelected.toggle()
        
        let isShopperLoggedIn = viewModel?.shopperLoginState.isShopperLoggedIn() ?? false
        if isShopperLoggedIn {
            return
        }
        
        showHideNewPasswordView(!btn.isSelected)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.validateInput()
        }
    }
    
    @IBAction func onPayWithSavedCard(_ sender: Any) {
        viewModel?.payManually = false;
    }
    
    @IBAction func onPayButtonTap(_ sender: Any) {
        Task { @MainActor in
            resignKeyboard()
            let payWithSavedCard = viewModel?.shopperLoginState == .paymentMethodsFound([]);
            if payWithSavedCard &&  paymentMethodView.selectedPaymentMethod != nil {
                await viewModel?.payWithPaymentMethod(paymentMethod: paymentMethodView.selectedPaymentMethod!)
                return
            }
            
            let payAsShopperAndSaveNewCard = viewModel?.shopperLoginState == .noPaymentMethod ||                                  viewModel?.shopperLoginState == .addNewPaymentMethod([])
            let saveCard = saveCardBtn.isSelected;
            
            viewModel?.saveCard = saveCard
            viewModel?.phoneNumber = phoneNoField.text!
            viewModel?.card = Card(cardNumber: cardNoField.text!, expiry: cardExpiryField.text!, cvc: cvcField.text!, firstName: fNameField.text!, lastName: lNameField.text!)
            viewModel?.billingInfo = BillingInfo(street1: streetAddressField.text!, street2: "", city: cityField.text!, state: stateField.optionValueOrText, postalCode: zipCodeField.text!, country: countryField.country!.rawValue.uppercased())
            
            
            if payAsShopperAndSaveNewCard {
                viewModel?.saveCard = true
                await viewModel?.payAsShopperUser()
            } else {
                viewModel?.newPassword = saveCard ? passwordView.getPassword() : nil
                await viewModel?.payAsGuestUser()
            }
        }
    }
    
    @IBAction func onCloseTap(_ sender: Any) {
        if viewModel?.paymentStatus == .inProgress {
            return
        }
        
        dismissBottomsheet() {
            self.viewModel?.cancelPayment()
        }
    }
    
}

//MARK: - UITextField Delegate
extension PaymentSheetController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return true }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            viewModel?.email = updatedText
        }
        return true
    }
}


//MARK: - CustomTextField Delegate
extension PaymentSheetController: ValidityUpdateDelegate {
    func onValidityChanged(_ textField: UITextField, inputValid: Bool) {
        validateInput()
       
        if textField == emailField {
            if(!inputValid) {
                self.changePhoneFieldVisibilty(isHidden: true)
                self.showHideSaveCardButton(isHidden: true)
                self.showHideLoginWithPassView(isHidden: true)
                self.changeUIElementVisibility(isHidden: true)
                self.hidePaymentMethodView()
                self.resetFields()
            }
        }
    }
}

//MARK: - ViewModel Bindings
extension PaymentSheetController {
    
    private func setupBindings() {
        viewModel?.$fetchPaymentState.sink(receiveValue: handleFetchPaymentState).store(in: &cancellables)
        viewModel?.$paymentStatus.sink(receiveValue: handlePaymentStatus).store(in: &cancellables)
        viewModel?.$payManually.sink(receiveValue: handlePayManually).store(in: &cancellables)
        viewModel?.$shopperLoginState.sink(receiveValue: handleShopperLoginState).store(in: &cancellables)
        viewModel?.$getAddressMetaState.sink(receiveValue: handleGetAddressMetaUpdate).store(in: &cancellables)
        viewModel?.$findAddressState.sink(receiveValue: handleFindAddressState).store(in: &cancellables)
        viewModel?.$userExistState.sink(receiveValue: handleUserExistState).store(in: &cancellables)
    }
    
    fileprivate func handlePayManually(_ payManually: Bool?) {
        DispatchQueue.main.async { [weak self] in
            guard let _payManually = payManually else {
                self?.savedCardButtonContainer.isHidden = true
                return
            }
            
            if _payManually {
                self?.hideError()
                self?.showHideLoginWithPassView(isHidden: true)
                self?.changePhoneFieldVisibilty(isHidden: false)
                self?.showHideSaveCardButton(isHidden: false)
            } else {
                self?.hideError()
                self?.changeUIElementVisibility(isHidden: true)
                self?.changePhoneFieldVisibilty(isHidden: true)
                self?.showHideLoginWithPassView(isHidden: false)
                self?.showHideSaveCardButton(isHidden: true)
                self?.resetFields()
            }
        }
    }

    
    func handleFetchPaymentState(_ trackerState: FetchPaymentState?) {
        
        guard let state = trackerState else {
            return
        }
        
        debugPrint("initialState: \(state)")
        DispatchQueue.main.async {
            switch state {
            case .error(let err):
                self.showFullsheetError(error: err)
                debugPrint("error \(err)")
                break
                
            case .found(let response):
                self.showEmailField()
                self.populateTrackerResponse(response)
                break
                
            case .inProgress:
                self.showInitialLoader()
                break
                
            case .inValidState:   //show error
                debugPrint("invalid state")
                break
                
            case .missingRequestParameters:  //show error
                debugPrint("missing request parameter state")
                break
                
            }
        }
        
    }
    
    func handleFindAddressState(_ state: FindAddressState) {
        
        debugPrint("initialState: \(state)")
        DispatchQueue.main.async {
            switch state {
            case .error(let err):
//                self.showFullsheetError(error: err)
                print("Error from address token: code \(err.formattedError())")
                break
                
            case .success(let address):
                self.populateSavedAddressIfCountryMatches(address: address)
                break
                
            case .inProgress, .initial:
                break
                
            }
        }
        
    }
    
    func handleGetAddressMetaUpdate(_ state: GetAddressMetaState) {
        debugPrint("state: \(state)")
        DispatchQueue.main.async {
            switch state {
            case .error(let err):
                self.showError(error: err)
                break
                
            case .success(let response):
                self.setupAddressFields(addressMeta: response)
                break
                
            case .inProgress:
                break
                
            case .initial:   //show error
                break
            }
            
        }
        
    }
    
    func handleShopperLoginState(_ shopperLoginState: ShopperLoginState) {
        
        debugPrint("\(shopperLoginState)")
        
        DispatchQueue.main.async {
            self.passwordView.updateUIForState(shopperLoginState)

            switch shopperLoginState {
            case .error(let err):
                self.showError(error: err)
                debugPrint("error \(err)")
                break
                
            case .paymentMethodsFound(let paymentMethods):
                self.cardDetailsLbl.text = "Add a payment method"
                self.cancelBtn.isHidden = false
                self.paymentMethodView.paymentMethods = paymentMethods
                self.changeUIElementVisibility(isHidden: true)
                self.showHideLoginWithPassView(isHidden: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.showPaymentMethodView()
                    self.validateInput()
                }
                break
                
            case .noPaymentMethod:
                self.cardDetailsLbl.text = "Add a payment method"
                self.cancelBtn.isHidden = true
                self.showHideLoginWithPassView(isHidden: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.changeUIElementVisibility(isHidden: false)
                }
                break
                
            case .inProgress: 
                self.hideError()
                debugPrint("inProgress state")
                break
                
            case .initial:
                debugPrint("initial")
                break
                
            case .addNewPaymentMethod(_):
                self.hideViewAnimated(self.paymentMethodView, shouldRemoveFromSuperview: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.changeUIElementVisibility(isHidden: false)
                    self.validateInput()
                }
                break
            }
        }
        
    }
    
    
    func handlePaymentStatus(_ paymentStatus: PaymentStatus) {
        debugPrint("paymentStatus: \(paymentStatus)")

        DispatchQueue.main.async {
            switch paymentStatus {
            case .failed(let error):
                self.paymentInprogress(false)
                self.showError(error: error)
                debugPrint("error \(error)")
                break
                
            case .inProgress:
                self.paymentInprogress(true)
                self.hideError()
                break
                
            case .cancelled:
                self.paymentInprogress(false)
                break
                
            case .success:
                debugPrint("success state")//show error
                self.paymentInprogress(false)
                break
                
            case .initial:
                debugPrint("initial state")
                break
                
            }
        }
    }
    
    fileprivate func handleUserExistState(_ state: UserExistState) {
        DispatchQueue.main.async { [weak self] in
            debugPrint("UserExistState: \(state)")
            switch state {
            case .initial:
                self?.emailField.isLoading = false
                break
                
            case .error(let err):
                self?.emailField.isLoading = false
                self?.changeUIElementVisibility(isHidden: true)
                self?.changePhoneFieldVisibilty(isHidden: true)
                self?.showHideLoginWithPassView(isHidden: true)
                self?.hidePaymentMethodView()
                self?.resetFields()
                self?.viewModel?.payManually = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.showError(error: err)
                }
                debugPrint("error \(err)")
                break
                
            case .userExist:
                self?.emailField.isLoading = false
                self?.changeUIElementVisibility(isHidden: true)
                self?.changePhoneFieldVisibilty(isHidden: true)
                self?.hidePaymentMethodView()
                self?.resetFields()
                self?.showHideLoginWithPassView(isHidden: false)
                self?.viewModel?.payManually = nil
                break
                
            case .loading:
                self?.emailField.isLoading = true
                break
                
            case .userDoesNotExist:
                self?.emailField.isLoading = false//show error
                self?.changeUIElementVisibility(isHidden: true)
                self?.hidePaymentMethodView()
                self?.resetFields()
                self?.showHideLoginWithPassView(isHidden: true)
                self?.changePhoneFieldVisibilty(isHidden: false)
                self?.viewModel?.payManually = nil
                break
                
            }
        }
    }
    
    private func paymentInprogress(_ loading: Bool) {
        payButton.loading = loading
        enableUserInteraction(enabled: !loading)
    }
}

extension PaymentSheetController: FPNTextFieldDelegate {
    
    /// The place to present/push the listController if you choosen displayMode = .list
    func fpnDisplayCountryList() {
        let listController: FPNCountryListViewController = FPNCountryListViewController(style: .grouped)
        listController.setup(repository: phoneNoField.countryRepository)
        listController.title = "Select Country Code"
        listController.didSelect = { [weak self] country in
            self?.phoneNoField.setFlag(countryCode: country.code)
        }
        let navigationViewController = UINavigationController(rootViewController: listController)
        
        present(navigationViewController, animated: true, completion: nil)
    }
    
    /// Lets you know when a country is selected
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        debugPrint(name, dialCode, code) // Output "France", "+33", "FR"
    }
    
    /// Lets you know when the phone number is valid or not. Once a phone number is valid, you can get it in severals formats (E164, International, National, RFC3966)
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        let phoneField = textField as? PhoneNumberTextField
        if let txt = textField.text, !txt.isEmpty {
            phoneField?.inputValid = isValid
        }
        
        changeUIElementVisibility(isHidden: !isValid)
    }
}

extension PaymentSheetController : PasswordViewDelegate {
    func didTapPayManually() {
        viewModel?.payManually = true
    }
    
    func didTapLogin() {
        Task {
            viewModel?.newPassword = passwordView.getPassword()
            await viewModel?.loginShopper()
        }
    }
    
}

extension PaymentSheetController: PaymentMethodsViewDelegate {
    func didSelectPaymentMethod(_ paymentMethod: PaymentMethod, _ view: PaymentMethodsView) {
        
    }
    
    func didAddPaymentMethod(_ view: PaymentMethodsView) {
        viewModel?.shopperLoginState = .addNewPaymentMethod(view.paymentMethods)
    }
    
}
