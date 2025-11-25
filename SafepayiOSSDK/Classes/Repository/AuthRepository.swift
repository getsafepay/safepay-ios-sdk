import Foundation

class AuthRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    fileprivate func saveAuthTokenIfAvailable(_ response: LoginResponse) {
        let token = response.data.session
        if token.isEmpty {
            debugPrint("Auth Token is invalid")
            return
        }
        
        apiClient.authToken = token;
        debugPrint("Auth Token saved Token: \(token)")
    }
    
    func createGuestUser(request: CreateGuestUserRequest) async throws -> LoginResponse {
        let endpoint = "user/v1/guest/"
        
        do {
            // Call post and pass LoginResponse.self directly
            let response: LoginResponse = try await self.apiClient.post(endpoint: endpoint, body: request)
            
            saveAuthTokenIfAvailable(response)
            
            return response
        } catch {
            throw error
        }
    }

    func createShopper(request: CreateShopperRequest) async throws -> CreateShopperResponse {
        let endpoint = "/user/v2/"
        
        do {
            // Call post and pass LoginResponse.self directly
            let response: CreateShopperResponse = try await self.apiClient.post(endpoint: endpoint, body: request)
            return response
        } catch {
            throw error
        }
    }

    func loginUser(request: LoginRequest) async throws -> LoginResponse {
        let endpoint = "auth/v2/user/login"
        
        do {
            // Pass LoginResponse.self to the post method, and it will handle decoding
            let response: LoginResponse = try await self.apiClient.post(endpoint: endpoint, body: request)
            saveAuthTokenIfAvailable(response)

            return response
        } catch {
            throw error
        }
    }


}


struct CreateGuestUserRequest: Encodable {
    let firstName: String
    let lastName: String
    let email: String
    let country: String
    let phone: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case country
        case phone
    }
}

struct CreateShopperRequest: Encodable {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let phone: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case password
        case phone
    }
}



struct LoginRequest: Encodable {
    let type: String
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let data: TokenData
}


struct CreateGuestUserResponse: Decodable {
    let data: TokenData
    let status: ResponseStatus
}

struct TokenData: Decodable {
    let session: String
    let token: String
    let refreshToken: String?
    
    enum CodingKeys: String, CodingKey {
        case session
        case token
        case refreshToken = "refresh_token"
    }
}

struct ResponseStatus: Decodable {
    let errors: [String]
    let message: String
}

struct GuestUser: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let country: String
    let phone: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case country
        case phone
    }
}

// MARK: - CreateShopperResponse
struct CreateShopperResponse: Codable {
    let data: ShopperData
}

// MARK: - ShopperData
struct ShopperData: Codable {
    let token: String
    let contacts: [Contact]
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let avatar: String
    let suspended: Int
    let suspendReason: String
    let verified: Int
    let verification: Verification
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case token, contacts, firstName = "first_name", lastName = "last_name", email, phone, avatar, suspended, suspendReason = "suspend_reason", verified, verification, createdAt = "created_at", updatedAt = "updated_at"
    }
}

// MARK: - Contact
struct Contact: Codable {
    let token: String
    let user: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let isDefault: Bool
    let createdAt: Timestamp
    let updatedAt: Timestamp

    enum CodingKeys: String, CodingKey {
        case token, user, firstName = "first_name", lastName = "last_name", email, phone, isDefault = "is_default", createdAt = "created_at", updatedAt = "updated_at"
    }
}

// MARK: - Timestamp
struct Timestamp: Codable {
    let seconds: Int
    let nanos: Int
}

// MARK: - Verification
struct Verification: Codable {
    let userId: String
    let code: String
    let verificationType: Int
    let expiresAt: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id", code, verificationType = "verification_type", expiresAt = "expires_at", createdAt = "created_at", updatedAt = "updated_at"
    }
}
