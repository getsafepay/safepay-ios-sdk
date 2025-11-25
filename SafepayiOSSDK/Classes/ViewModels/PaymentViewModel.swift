import Foundation
import CardinalMobile

class PaymentViewModel: ObservableObject, CardinalValidationDelegate {
    private let userRepository: UserRepository
    private let authRepository: AuthRepository
    private let paymentRepository: PaymentRepository
    public let configuration: SafepayConfiguration
    public let payerAuthRepository: PayerAuthRepository
    private let debouncer = Debouncer()
    
    @Published var errorMessage: String?
    
    @Published var email: String = "" {
        didSet {
            validateEmail(email)
        }
    }
    @Published var phoneNumber: String = ""
    @Published var payManually: Bool?
    @Published var fetchPaymentState: FetchPaymentState?
    @Published var paymentStatus: PaymentStatus = .initial
    @Published var shopperLoginState: ShopperLoginState = .initial
    @Published var getAddressMetaState: GetAddressMetaState = .initial
    @Published var findAddressState: FindAddressState = .initial
    @Published var userExistState: UserExistState = .initial

    var card: Card?
    var billingInfo: BillingInfo?
    var saveCard: Bool = false
    var newPassword: String?
   

    
    init(userRepository: UserRepository = UserRepository(apiClient: APIClient.shared),
         authRepository: AuthRepository = AuthRepository(apiClient: APIClient.shared),
         paymentRepository: PaymentRepository = PaymentRepository(apiClient: APIClient.shared),
         payerAuthRepository: PayerAuthRepository,
         configuration: SafepayConfiguration) {
        self.userRepository = userRepository
        self.authRepository = authRepository
        self.paymentRepository = paymentRepository
        self.payerAuthRepository = payerAuthRepository
        self.configuration = configuration
        Task{
            await fetchPaymentDetails()
        }
    }
    
    
    private func isTrackerInitialStateValid(_ response: FetchPaymentResponse) -> Bool {
        guard response.ok else {
            return false
        }
        
        let tracker = PaymentTracker(initialState: PaymentTrackerState(rawValue: response.data.state) ?? .trackerUnknown, token: response.data.token)
        return tracker.isResumableState()
    }
    
    private func validateEmail(_ email: String) {
        debouncer.call {
            let isEmailValid = EmailValidator.validate(email)
            if isEmailValid {
                if (self.payManually ?? false) {
                    self.userExistState = .userDoesNotExist
                    return
                }
                
                Task { @MainActor in
                    await self.checkUserExists()
                }
            } else {
                self.userExistState = .error(PaymentError(message: "Invalid email format"))
            }
        }
    }
    
    
    //MARK: - API Calls
    
    fileprivate func findAddressIfTokenAvailable() async {
        guard let token = configuration.addressToken, !token.isEmpty else {
            return
        }
        
        await findAddress(addressToken: token)
    }
    
    func fetchPaymentDetails() async {
        
        if configuration.trackerToken.isEmpty || configuration.timeBasedToken.isEmpty {
            fetchPaymentState = .missingRequestParameters
            return
        }
        
        fetchPaymentState = .inProgress
        
        do {
            let response = try await paymentRepository.fetchPayment(trackToken: configuration.trackerToken, timeBasedToken: configuration.timeBasedToken)
            
            if isTrackerInitialStateValid(response) {
                fetchPaymentState = .found(response)
                let countryInfo = CurrencyToCountryUtil.countryAndCode(currencyCode:  response.data.purchaseTotals.quoteAmount.currency)
                await getAddressMeta(countryCode: countryInfo.code)
                await findAddressIfTokenAvailable()
            } else {
                fetchPaymentState = .error(PaymentError.invalidTrackerState())
            }
            
        } catch let e as ErrorResponse {
            fetchPaymentState = .error(PaymentError(message: e.errorMessage))
        } catch {
            if let afError = error.asAFError, let rCode = afError.responseCode, rCode == 401 {
                fetchPaymentState = .error(PaymentError.timeBasedTokenExpired())
            } else {
                fetchPaymentState = .error(PaymentError(message: error.localizedDescription))
            }
        }
    }
    
    func getAddressMeta(countryCode: String) async {
        getAddressMetaState = .inProgress
        
        do {
            let response = try await userRepository.getAddressMeta(countryCode: countryCode, timeBasedToken: configuration.timeBasedToken)
            getAddressMetaState = .success(response)
            
        } catch let e as ErrorResponse {
            getAddressMetaState = .error(PaymentError(message: e.errorMessage))
        } catch {
            if let afError = error.asAFError, let rCode = afError.responseCode, rCode == 401 {
                getAddressMetaState = .error(PaymentError.timeBasedTokenExpired())
            } else {
                getAddressMetaState = .error(PaymentError(message: error.localizedDescription))
            }
        }
    }
    
    func findAddress(addressToken: String) async {
        findAddressState = .inProgress
        
        do {
            let response = try await userRepository.findAddress(addressToken: addressToken, 
                                                                timeBasedToken: configuration.timeBasedToken)
            findAddressState = .success(response.data)
            
        } catch let e as ErrorResponse {
            findAddressState = .error(PaymentError(message: e.errorMessage))
        } catch {
            if let afError = error.asAFError, let rCode = afError.responseCode, rCode == 401 {
                findAddressState = .error(PaymentError.timeBasedTokenExpired())
            } else {
                findAddressState = .error(PaymentError(message: error.localizedDescription))
            }
        }
    }
    
    func cancelPayment() {
        paymentStatus = .cancelled
    }
    
    func checkUserExists() async {
        guard !email.isEmpty else {
            errorMessage = "Email cannot be empty"
            userExistState = .error(PaymentError(message: "Email cannot be empty"))
            return
        }
        
        userExistState = .loading
        do {
            let response = try await userRepository.checkUserExists(email: email)
            userExistState = response.exists ? .userExist : .userDoesNotExist
            shopperLoginState = .initial
            
        } catch let _error as ErrorResponse {
            userExistState = .error(PaymentError(message: _error.errorMessage))
            errorMessage = _error.errorMessage
        } catch {
            userExistState = .error(PaymentError(message: error.localizedDescription))
            errorMessage = error.localizedDescription
        }
    }
    
    func loginShopper() async {
        shopperLoginState = .inProgress
        
        guard let pass = newPassword else {
            shopperLoginState = .error(PaymentError.dataMissing())
            return
        }
        
        do {
            let loginResponse = try await authRepository.loginUser(request: LoginRequest(type: "password", email: email, password: pass))
            
            guard !loginResponse.data.token.isEmpty else {
                shopperLoginState = .error(PaymentError.generalPaymentError())
                return
            }
            
            let paymentMethodResponse = try await paymentRepository.getAllPaymentMethods()
            shopperLoginState = paymentMethodResponse.data.isEmpty ? .noPaymentMethod : .paymentMethodsFound(paymentMethodResponse.data)

        } catch let _error as ErrorResponse {
            self.shopperLoginState = .error(PaymentError(message: _error.errorMessage))
        } catch {
            self.shopperLoginState = .error(PaymentError(message: error.localizedDescription))
        }
    }
    
    func payWithPaymentMethod(paymentMethod: PaymentMethod) async {
        paymentStatus = .inProgress

        do {
            // 2. Call payerAuthenticationSetup
            let trackerToken = configuration.trackerToken
            let address = paymentMethod.address
            let billingInfo = BillingInfo(street1: address.street1, 
                                          street2: address.street2,
                                          city: address.city,
                                          state: address.state,
                                          postalCode: address.postalCode,
                                          country: address.country)

            let authSetupResponse = try await paymentRepository.payerAuthenticationSetup(trackToken: trackerToken, paymentMethod: CardPaymentMethod(card: nil, tokenizedCard: TokenizedCard(token: paymentMethod.token)))
            
            guard let jwt = authSetupResponse.data.action.payerAuthenticationSetup?.cardinalJWT else {
                print("cardinalJWT token is empty")
                paymentStatus = .failed(PaymentError.generalPaymentError())
                return
            }
            
            performPayment(trackerToken: trackerToken, jwt: jwt, billingInfo: billingInfo, doCardOnFile: false)

        } catch let _error as ErrorResponse {
            self.paymentStatus = .failed(PaymentError(message: _error.errorMessage))
        } catch {
            self.paymentStatus = .failed(PaymentError(message: error.localizedDescription))
        }
       
    }
    
    
    func payAsShopperUser() async {
        paymentStatus = .inProgress
        
        guard let card = self.card else {
            paymentStatus = .failed(PaymentError(message: "Card information is missing"))
            return
        }
        
        guard let billingInfo = self.billingInfo else {
            paymentStatus = .failed(PaymentError(message: "Billing information is missing"))
            return
        }
        
        let trackerToken = configuration.trackerToken

        do {
            
            let authSetupResponse = try await paymentRepository.payerAuthenticationSetup(trackToken: trackerToken, paymentMethod: CardPaymentMethod(card: CardDetails(cardNumber: card.cardNumber, expirationMonth: card.expiryMonth, expirationYear: card.expiryYear, cvv: card.cvc), tokenizedCard: nil))
            
            guard let jwt = authSetupResponse.data.action.payerAuthenticationSetup?.cardinalJWT else {
                debugPrint("cardinalJWT token is empty")
                paymentStatus = .failed(PaymentError.generalPaymentError())
                return
            }
            saveCard = true
            performPayment(trackerToken: trackerToken, jwt: jwt, billingInfo: billingInfo, doCardOnFile: saveCard)

        } catch let _error as ErrorResponse {
            self.paymentStatus = .failed(PaymentError(message: _error.errorMessage))
        } catch {
            self.paymentStatus = .failed(PaymentError(message: error.localizedDescription))
        }
       
    }
    
    fileprivate func performPayment(trackerToken: String, jwt: String, billingInfo: BillingInfo, doCardOnFile: Bool? = nil) {
        payerAuthRepository.setupCardinalSession(jwtString: jwt) { consumerSessionId in
            
            Task {
                do {
                    guard !consumerSessionId.isEmpty else {
                        debugPrint("consumerSessionId from setupCardinalSession is empty or null")
                        self.paymentStatus = .failed(PaymentError.generalPaymentError())
                        return
                    }
                    
                    // 3. Call paymentEnrollment
                    let enrollmentResponse = try await self.paymentRepository.paymentEnrollment(trackToken: trackerToken, request: PaymentEnrollmentRequest(payload: UpdatePayloadData(billing: billingInfo, authorization: Authorization(doCapture: false, sdkOnValidateJWT: nil, doCardOnFile: doCardOnFile), authenticationSetup: AuthenticationSetup(sdkReferenceId: consumerSessionId))))
                    guard let payerAuthResponse = enrollmentResponse.data.action.payerAuthenticationEnrollment else {
                        debugPrint("Error: enrollment details are missing")
                        self.paymentStatus = .failed(PaymentError.generalPaymentError())
                        return
                    }
                    
                    if let transactionId = payerAuthResponse.authenticationTransactionId, let payload = payerAuthResponse.payload, payerAuthResponse.authenticationStatus == "REQUIRED" {
                        self.payerAuthRepository.continueValidate(transactionId, payload: payload, validationDelegate: self)
                    } else if payerAuthResponse.authenticationStatus == "FRICTIONLESS" || payerAuthResponse.authenticationStatus == "ATTEMPTED" {
                        let response = try await self.paymentRepository.paymentAuthorization(trackToken: trackerToken, doCapture: false, doCardOnFile: doCardOnFile)
                        if response.status.message == "success" {
                            self.paymentStatus = .success
                        } else {
                            self.paymentStatus = .failed(PaymentError(message: response.status.message))
                        }
                    } else {
                        self.paymentStatus = .failed(PaymentError.generalPaymentError())
                    }
                    
                } catch let _error as ErrorResponse {
                    self.paymentStatus = .failed(PaymentError(message: _error.errorMessage))
                } catch {
                    self.paymentStatus = .failed(PaymentError(message: error.localizedDescription))
                }
            }
            
            
        } didValidate: { validateReponse in
            if !validateReponse.isValidated {
                debugPrint("token is empty error \(validateReponse.errorDescription) , error number \(validateReponse.errorNumber)")
                //TODO: error handling show error
                self.paymentStatus = .failed(PaymentError(message: validateReponse.errorDescription))
            }
        }
    }
    
    func payAsGuestUser() async {
        paymentStatus = .inProgress
        
        guard let card = self.card else {
            paymentStatus = .failed(PaymentError(message: "Card information is missing"))
            return
        }
        
        guard let billingInfo = self.billingInfo else {
            paymentStatus = .failed(PaymentError(message: "Billing information is missing"))
            return
        }
        
        do {
            
            if saveCard {
                // Create Shopper on save card flow
                guard let pass = newPassword else {
                    paymentStatus = .failed(PaymentError.dataMissing())
                    return
                }
                
                let shopperResponse = try await authRepository.createShopper(request: CreateShopperRequest(firstName: card.firstName, lastName: card.lastName, email: email, password: pass, phone: phoneNumber))
                
                guard !shopperResponse.data.token.isEmpty else {
                    paymentStatus = .failed(PaymentError.generalPaymentError())
                    return
                }
                
                let loginResponse = try await authRepository.loginUser(request: LoginRequest(type: "password", email: email, password: pass))
                
                guard !loginResponse.data.token.isEmpty else {
                    paymentStatus = .failed(PaymentError.generalPaymentError())
                    return
                }
                
            } else {
                // Guest user flow
                let loginRespone = try await authRepository.createGuestUser(request: CreateGuestUserRequest(firstName: card.firstName, lastName: card.lastName, email: email, country: billingInfo.country, phone: phoneNumber))
                
                guard !loginRespone.data.session.isEmpty else {
                    errorMessage = "Could not create guest user"
                    return
                }
            }
            
         
            let trackerToken = configuration.trackerToken
            
            // 2. Call payerAuthenticationSetup
            let authSetupResponse = try await paymentRepository.payerAuthenticationSetup(trackToken: trackerToken, paymentMethod: CardPaymentMethod(card: CardDetails(cardNumber: card.cardNumber, expirationMonth: card.expiryMonth, expirationYear: card.expiryYear, cvv: card.cvc), tokenizedCard: nil))
            
            guard let jwt = authSetupResponse.data.action.payerAuthenticationSetup?.cardinalJWT else {
                debugPrint("cardinalJWT token is empty")
                paymentStatus = .failed(PaymentError.generalPaymentError())
                return
            }
            
            performPayment(trackerToken: trackerToken,jwt: jwt,billingInfo: billingInfo, doCardOnFile: self.saveCard ? self.saveCard : nil)
            
        } catch let _error as ErrorResponse {
            self.paymentStatus = .failed(PaymentError(message: _error.errorMessage))
        } catch {
            self.paymentStatus = .failed(PaymentError(message: error.localizedDescription))
        }
    }
    
    
    //Delegate
    func cardinalSession(cardinalSession session: CardinalSession!, stepUpValidated validateResponse: CardinalResponse!, serverJWT: String!) {
        debugPrint("cardinalSession: validation response \(validateResponse.errorDescription)")

        Task {
            switch(validateResponse.actionCode) {

            case .success:
                do {
                    debugPrint("success, serverJWT \(serverJWT!)")
                    self.paymentStatus = .inProgress
                    let payerAuthResponse = try await self.paymentRepository.payerAuthValidate(trackToken: configuration.trackerToken, serverJWT: serverJWT, doCardOnFile: self.saveCard ? self.saveCard : nil)
                    if payerAuthResponse.status.message == "success" {
                        let captureResponse = try await self.paymentRepository.capture(trackToken: configuration.trackerToken)
                        if captureResponse.status.message == "success" {
                            self.paymentStatus = .success
                        } else {
                            self.paymentStatus = .failed(PaymentError(message: captureResponse.status.message))
                        }

                    } else {
                        self.paymentStatus = .failed(PaymentError(message: payerAuthResponse.status.message))
                    }
                } catch let _error as ErrorResponse {
                    self.paymentStatus = .failed(PaymentError(message: _error.errorMessage))
                } catch {
                    self.paymentStatus = .failed(PaymentError(message: error.localizedDescription))
                }
                
                
            case .noAction:
                debugPrint("noAction")
            case .failure:
                //There was a problem authenticating your payment. Please use a different card
                paymentStatus = .failed(PaymentError(message: validateResponse.errorDescription))
                debugPrint("failure")
            case .error:
                //There was a problem authenticating your payment. Please use a different card
                paymentStatus = .failed(PaymentError(message: validateResponse.errorDescription))
                debugPrint("error")
            case .cancel:
                debugPrint("cancel")
                paymentStatus = .cancelled
            case .timeout:
                debugPrint("timeout")
                paymentStatus = .cancelled
            @unknown default:
                debugPrint("unknown")
                
            }
        }
    }
}
