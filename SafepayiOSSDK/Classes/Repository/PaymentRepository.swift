import Foundation

class PaymentRepository {

    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func getAllPaymentMethods() async throws -> GetAllPaymentMethodsResponse {
        let endpoint = "user/wallets/v1/"
        return try await self.apiClient.get(endpoint: endpoint)
    }
    
    func fetchPayment(trackToken: String, timeBasedToken: String) async throws -> FetchPaymentResponse {
        let endpoint = "reporter/api/v1/payments/\(trackToken)"
        
        return try await self.apiClient.get(endpoint: endpoint, headers: ["Authorization" : "Bearer \(timeBasedToken)"])
    }
    
    func payerAuthenticationSetup(trackToken: String, paymentMethod: CardPaymentMethod) async throws -> TrackPaymentResponse {
        let endpoint = "order/payments/v3/\(trackToken)"
        
        let request = TrackPaymentRequest(action: "PAYER_AUTH_SETUP", entryMode: paymentMethod.entryMode, payload: PayloadData(paymentMethod: paymentMethod, isMobile: true))
        
        return try await self.apiClient.post(endpoint: endpoint, body: request)
    }

    func paymentEnrollment(trackToken: String, request: PaymentEnrollmentRequest) async throws -> PaymentEnrollmentResponse {
        let endpoint = "order/payments/v3/\(trackToken)"
        
        return try await self.apiClient.post(endpoint: endpoint, body: request)
    }

    func paymentAuthorization(trackToken: String, doCapture: Bool, doCardOnFile: Bool? = nil) async throws -> PaymentAuthorizationResponse {
        let endpoint = "order/payments/v3/\(trackToken)"
        
        let request = UpdatePaymentAuthorizationRequest(payload: AuthorizationPayload(isMobile: true, authorization: Authorization(doCapture: doCapture, sdkOnValidateJWT: nil, doCardOnFile: doCardOnFile)))
        
        return try await self.apiClient.post(endpoint: endpoint, body: request)
    }
    
    func payerAuthValidate(trackToken: String, serverJWT: String, doCardOnFile: Bool?) async throws -> PaymentAuthorizationResponse {
        let endpoint = "order/payments/v3/\(trackToken)"
        
        let request = CapturePaymentRequest(payload: CapturePayload(isMobile: true, authorization: Authorization(doCapture: false, sdkOnValidateJWT: serverJWT, doCardOnFile: doCardOnFile)))
        
        return try await self.apiClient.post(endpoint: endpoint, body: request)
    }
    
    func capture(trackToken: String) async throws -> PaymentCaptureResponse {
        let endpoint = "order/payments/v3/\(trackToken)"
        return try await self.apiClient.post(endpoint: endpoint, body: EmptyRequest())
    }
    
}

// Request models
struct TrackPaymentRequest: Encodable {
    let action: String
    let entryMode: String?
    let payload: PayloadData
    
    enum CodingKeys: String, CodingKey {
        case action, payload
        case entryMode = "entry_mode"
    }
}

struct EmptyRequest: Encodable {
}

struct PayloadData: Encodable {
    let paymentMethod: CardPaymentMethod
    let isMobile: Bool
    
    enum CodingKeys: String, CodingKey {
        case isMobile = "is_mobile"
        case paymentMethod = "payment_method"
    }
}

struct CardPaymentMethod: Encodable {
    let card: CardDetails?
    let tokenizedCard: TokenizedCard?
    
    enum CodingKeys: String, CodingKey {
        case card
        case tokenizedCard = "tokenized_card"
    }
    
    var entryMode: String? {
       return tokenizedCard == nil ? "raw" : "tms"
    }
}

struct TokenizedCard: Encodable {
    let token: String
}

struct CardDetails: Encodable {
    let cardNumber: String
    let expirationMonth: String
    let expirationYear: String
    let cvv: String
    
    enum CodingKeys: String, CodingKey {
        case cardNumber = "card_number"
        case expirationMonth = "expiration_month"
        case expirationYear = "expiration_year"
        case cvv
    }
}

// New request models
struct PaymentEnrollmentRequest: Encodable {
    let payload: UpdatePayloadData
}

struct UpdatePayloadData: Encodable {
    let billing: BillingInfo
    let authorization: Authorization
    let authenticationSetup: AuthenticationSetup

    enum CodingKeys: String, CodingKey {
        case billing, authorization
        case authenticationSetup = "authentication_setup"
    }
}



struct Authorization: Encodable {
    let doCapture: Bool
    let sdkOnValidateJWT: String?
    let doCardOnFile: Bool?
    enum CodingKeys: String, CodingKey {
        case doCapture = "do_capture"
        case sdkOnValidateJWT = "sdk_on_validate_jwt"
        case doCardOnFile = "do_card_on_file"
    }
}

struct AuthenticationSetup: Encodable {
    let successUrl: String?
    let failureUrl: String?
    let deviceFingerprintSessionId: String?
    let sdkReferenceId: String
    
    init(successUrl: String? = nil, failureUrl: String? = nil, deviceFingerprintSessionId: String? = nil, sdkReferenceId: String) {
        self.successUrl = successUrl
        self.failureUrl = failureUrl
        self.deviceFingerprintSessionId = deviceFingerprintSessionId
        self.sdkReferenceId = sdkReferenceId
    }

    enum CodingKeys: String, CodingKey {
        case successUrl = "success_url"
        case failureUrl = "failure_url"
        case deviceFingerprintSessionId = "device_fingerprint_session_id"
        case sdkReferenceId = "sdk_reference_id"
    }
}

// New request models
struct UpdatePaymentAuthorizationRequest: Encodable {
    let payload: AuthorizationPayload
}

struct AuthorizationPayload: Encodable {
    let isMobile: Bool
    let authorization: Authorization
    
    enum CodingKeys: String, CodingKey {
        case isMobile = "is_mobile"
        case authorization = "authorization"
    }
}

struct CapturePayload: Encodable {
    let isMobile: Bool
    let authorization: Authorization
    
    enum CodingKeys: String, CodingKey {
        case isMobile = "is_mobile"
        case authorization = "authorization"
    }
}

struct CapturePaymentRequest: Encodable {
    let payload: CapturePayload
}

// Response models
struct TrackPaymentResponse: Decodable {
    let data: ResponseData
    let status: StatusData
}

struct FetchPaymentResponse: Decodable {
    let ok: Bool
    let data: TrackerData
    
    enum CodingKeys: String, CodingKey {
        case ok, data
    }
}

struct TrackerData: Decodable {
    let token: String
    let environment: String
    let state: String
    let intent: String
    let mode: String
    let entryMode: String
    let client: Client
    let customer: Customer?
    let nextActions: NextActions
    let purchaseTotals: PurchaseTotals

    enum CodingKeys: String, CodingKey {
        case token, environment, state, intent, mode, client, customer
        case nextActions = "next_actions"
        case entryMode = "entry_mode"
        case purchaseTotals = "purchase_totals"
    }
}

struct Client: Decodable {
    let token: String
    let apiKey: String
    let name: String
    let email: String

    // Custom coding keys to map the JSON keys to the struct properties
    enum CodingKeys: String, CodingKey {
        case token
        case apiKey = "api_key"
        case name
        case email
    }
}

struct Customer: Decodable {
    let token: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String

    // Custom coding keys to map the JSON keys to the struct properties
    enum CodingKeys: String, CodingKey {
        case token
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phone
    }
}

struct ResponseData: Decodable {
    let tracker: Tracker
    let action: Action
}

struct Tracker: Decodable {
    let token: String
    let client: String
    let environment: String
    let state: String
    let intent: String
    let mode: String
    let customer: String
    let nextActions: NextActions
    let purchaseTotals: PurchaseTotals
    let metadata: [String: String]

    enum CodingKeys: String, CodingKey {
        case token, client, environment, state, intent, mode, customer, metadata
        case nextActions = "next_actions"
        case purchaseTotals = "purchase_totals"
    }
}

struct NextActions: Decodable {
    let cybersource: Cybersource

    enum CodingKeys: String, CodingKey {
        case cybersource = "CYBERSOURCE"
    }
}

struct Cybersource: Decodable {
    let kind: String
    let requestId: String?

    enum CodingKeys: String, CodingKey {
        case kind
        case requestId = "request_id"
    }
}

struct PurchaseTotals: Decodable {
    let quoteAmount: Amount
    let baseAmount: Amount
    let conversionRate: ConversionRate

    enum CodingKeys: String, CodingKey {
        case quoteAmount = "quote_amount"
        case baseAmount = "base_amount"
        case conversionRate = "conversion_rate"
    }
}

struct Amount: Decodable {
    let currency: String
    let amount: Int
}

struct ConversionRate: Decodable {
    let baseCurrency: String
    let quoteCurrency: String
    let rate: Int

    enum CodingKeys: String, CodingKey {
        case baseCurrency = "base_currency"
        case quoteCurrency = "quote_currency"
        case rate
    }
}

struct Action: Decodable {
    let token: String
    let paymentMethod: PaymentMethodResponse?
    let payerAuthenticationSetup: PayerAuthenticationSetup?
    let payerAuthenticationEnrollment: PayerAuthenticationEnrollment?

    enum CodingKeys: String, CodingKey {
        case token
        case paymentMethod = "payment_method"
        case payerAuthenticationSetup = "payer_authentication_setup"
        case payerAuthenticationEnrollment = "payer_authentication_enrollment"
    }
}

struct PayerAuthenticationEnrollment: Decodable {
    let rid: String?
    let accessToken: String?
    let payload: String?
    let enrollmentStatus: String?
    let stepUpURL: String?
    let veresEnrolled: String?
    let veresEnrolledDescription: String?
    let specificationVersion: String?
    let authenticationStatus: String?
    let authenticationTransactionId: String?
    
    enum CodingKeys: String, CodingKey {
        case rid
        case payload
        case accessToken = "access_token"
        case stepUpURL = "step_up_url"
        case enrollmentStatus = "enrollment_status"
        case veresEnrolled = "veres_enrolled"
        case veresEnrolledDescription = "veres_enrolled_description"
        case specificationVersion = "specification_version"
        case authenticationStatus = "authentication_status"
        case authenticationTransactionId = "authentication_transaction_id"
    }
}

struct PaymentMethodResponse: Decodable {
    let token: String
    let expirationMonth: String
    let expirationYear: String
    let cardTypeCode: String
    let cardType: String
    let binNumber: String
    let lastFour: String

    enum CodingKeys: String, CodingKey {
        case token
        case expirationMonth = "expiration_month"
        case expirationYear = "expiration_year"
        case cardTypeCode = "card_type_code"
        case cardType = "card_type"
        case binNumber = "bin_number"
        case lastFour = "last_four"
    }
}

struct PayerAuthenticationSetup: Decodable {
    let accessToken: String?
    let deviceDataCollectionUrl: String?
    let cardinalJWT: String?


    enum CodingKeys: String, CodingKey {
        case cardinalJWT = "cardinal_jwt"
        case accessToken = "access_token"
        case deviceDataCollectionUrl = "device_data_collection_url"
    }
}

struct StatusData: Decodable {
    let errors: [String]
    let message: String
}

public struct ErrorResponse: Error , Decodable {
    let data: String?
    let status: StatusData?
    let code: String?
    let message: String?
    
    var errorMessage: String {
        return status?.message ?? message ?? PaymentError.generalPaymentError().message
    }
}

// MARK: - Main Response Data
class GetAllPaymentMethodsResponse: Codable {
    var data: [PaymentMethod]
}

// MARK: - Payment Data
class PaymentMethod: Codable {
    let token: String
    let user: String
    let paymentMethodToken: String
    let deduplicationKey: String
    let intent: String
    let last4: String
    let instrumentType: String
    let expiryMonth: String
    let expiryYear: String
    let address: Address
    
    enum CodingKeys: String, CodingKey {
        case token
        case user
        case address
        case paymentMethodToken = "payment_method_token"
        case deduplicationKey = "deduplication_key"
        case intent
        case last4 = "last_4"
        case instrumentType = "instrument_type"
        case expiryMonth = "expiry_month"
        case expiryYear = "expiry_year"
    }
}

struct Address: Codable {
    let token: String
    let owner: String?
    let street1: String
    let street2: String?
    let city: String
    let state: String?
    let postalCode: String?
    let country: String
    
    enum CodingKeys: String, CodingKey {
        case token, owner, street1, street2, city, state, country
        case postalCode = "postal_code"
    }
}


// New response model (assuming it's the same as TrackPaymentResponse)
typealias PaymentEnrollmentResponse = TrackPaymentResponse
typealias PaymentAuthorizationResponse = TrackPaymentResponse
typealias PaymentCaptureResponse = TrackPaymentResponse
