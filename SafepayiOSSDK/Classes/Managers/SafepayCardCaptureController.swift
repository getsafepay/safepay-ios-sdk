import Foundation

public enum SafepayCardCaptureEnvironment: String {
    case development
    case sandbox
    case production
}

public struct SafepayCardCaptureConfiguration {
    public let environment: SafepayCardCaptureEnvironment
    public let authToken: String
    public let tracker: String

    public init(
        environment: SafepayCardCaptureEnvironment,
        authToken: String,
        tracker: String
    ) {
        self.environment = environment
        self.authToken = authToken
        self.tracker = tracker
    }
}

public struct SafepayCardCapturePaymentMethod {
    public let token: String
    public let expirationMonth: String
    public let expirationYear: String
    public let cardTypeCode: String
    public let cardType: String
    public let binNumber: String
    public let lastFour: String

    public init(
        token: String,
        expirationMonth: String,
        expirationYear: String,
        cardTypeCode: String,
        cardType: String,
        binNumber: String,
        lastFour: String
    ) {
        self.token = token
        self.expirationMonth = expirationMonth
        self.expirationYear = expirationYear
        self.cardTypeCode = cardTypeCode
        self.cardType = cardType
        self.binNumber = binNumber
        self.lastFour = lastFour
    }
}

public struct SafepayCardCaptureResult {
    public let accessToken: String
    public let deviceDataCollectionURL: String
    public let paymentMethod: SafepayCardCapturePaymentMethod
    public let cardinalJWT: String?

    public init(
        accessToken: String,
        deviceDataCollectionURL: String,
        paymentMethod: SafepayCardCapturePaymentMethod,
        cardinalJWT: String?
    ) {
        self.accessToken = accessToken
        self.deviceDataCollectionURL = deviceDataCollectionURL
        self.paymentMethod = paymentMethod
        self.cardinalJWT = cardinalJWT
    }
}

public final class SafepayCardCaptureController {
    public let configuration: SafepayCardCaptureConfiguration
    public let cardFieldView: SafepayCardFieldView

    private let paymentRepository: PaymentRepository

    public init(
        configuration: SafepayCardCaptureConfiguration,
        cardFieldView: SafepayCardFieldView = SafepayCardFieldView()
    ) {
        self.configuration = configuration
        self.cardFieldView = cardFieldView

        let apiClient = APIClient(environment: configuration.environment.sdkEnvironment)
        apiClient.authToken = configuration.authToken
        self.paymentRepository = PaymentRepository(apiClient: apiClient)
    }

    public func validate() -> Bool {
        cardFieldView.currentCardDetails().complete
    }

    public func fetchValidity() async -> Bool {
        validate()
    }

    public func focus() {
        cardFieldView.focus()
    }

    public func blur() {
        cardFieldView.blur()
    }

    public func clear() {
        cardFieldView.clear()
    }

    public func submit() async throws -> SafepayCardCaptureResult {
        let paymentMethod = try buildPaymentMethod()
        // Web device data collection flow, so the result carries an access token and DDC URL.
        let response = try await paymentRepository.payerAuthenticationSetup(
            trackToken: configuration.tracker,
            paymentMethod: paymentMethod,
            isMobile: nil
        )

        guard
            let setup = response.data.action.payerAuthenticationSetup,
            let accessToken = setup.accessToken,
            let deviceDataCollectionURL = setup.deviceDataCollectionUrl,
            let paymentMethodResponse = response.data.action.paymentMethod
        else {
            throw PaymentError.dataMissing()
        }

        return SafepayCardCaptureResult(
            accessToken: accessToken,
            deviceDataCollectionURL: deviceDataCollectionURL,
            paymentMethod: SafepayCardCapturePaymentMethod(
                token: paymentMethodResponse.token,
                expirationMonth: paymentMethodResponse.expirationMonth,
                expirationYear: paymentMethodResponse.expirationYear,
                cardTypeCode: paymentMethodResponse.cardTypeCode,
                cardType: paymentMethodResponse.cardType,
                binNumber: paymentMethodResponse.binNumber,
                lastFour: paymentMethodResponse.lastFour
            ),
            cardinalJWT: setup.cardinalJWT
        )
    }

    private func buildPaymentMethod() throws -> CardPaymentMethod {
        let details = cardFieldView.currentCardDetails(includeSensitiveData: true)

        guard details.complete else {
            throw PaymentError.invalidCardDetails()
        }

        guard
            let cardNumber = details.number,
            let cvc = details.cvc,
            let expiryMonth = details.expiryMonth,
            let expiryYear = details.expiryYear
        else {
            throw PaymentError.dataMissing()
        }

        return CardPaymentMethod(
            card: CardDetails(
                cardNumber: cardNumber,
                expirationMonth: String(format: "%02d", expiryMonth),
                expirationYear: String(expiryYear),
                cvv: cvc
            ),
            tokenizedCard: nil
        )
    }
}

private extension SafepayCardCaptureEnvironment {
    var sdkEnvironment: Environment {
        switch self {
        case .development:
            return .development
        case .sandbox:
            return .sandbox
        case .production:
            return .production
        }
    }
}
