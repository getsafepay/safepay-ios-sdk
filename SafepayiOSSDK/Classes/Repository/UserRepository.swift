import Foundation

struct UserRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func checkUserExists(email: String) async throws -> UserExistsResponse {
        let endpoint = "user/v2/exists"
        let queryItems = [URLQueryItem(name: "email", value: email)]
        
        // Call the get method and pass the response type UserExistsResponse.self
        let response: DataResponse<UserExistsResponse> = try await apiClient.getPlus(endpoint: endpoint, 
                                                                                 queryItems: queryItems)
        return response.data
    }
    
    func getAddressMeta(countryCode: String, timeBasedToken: String) async throws -> AddressMeta {
        let endpoint = "user/meta/v2/country"
        let queryItems = [URLQueryItem(name: "cc", value: countryCode)]
        
        let response: DataResponse<AddressMeta> = try await apiClient.get(endpoint: endpoint,
                                                                          queryItems: queryItems,
                                                                          headers: ["Authorization" : "Bearer \(timeBasedToken)"])
        return response.data
    }
    
    func findAddress(addressToken: String, timeBasedToken: String) async throws -> FindAddressResponse {
        let endpoint = "user/address/v2/\(addressToken)"
        
        let response: FindAddressResponse = try await apiClient.get(endpoint: endpoint,
                                                                    headers: ["Authorization" : "Bearer \(timeBasedToken)"])
        return response
    }

}

struct UserExistsResponse: Decodable {
    let exists: Bool
    let isLocal: Bool
    let hasPassword: Bool
    let phone: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case exists
        case isLocal = "is_local"
        case hasPassword = "has_password"
        case phone
        case email
    }
}

struct DataResponse<T: Decodable>: Decodable {
    let data: T
}

// MARK: - Data Model
struct AddressMeta: Codable {
    let required: [String]
    let administrativeArea: AddressComponent?
    let locality: AddressComponent?
    let streetAddress: AddressComponent?
    let postCode: AddressComponent?
    
    enum CodingKeys: String, CodingKey {
        case required
        case administrativeArea = "AdministrativeArea"
        case locality = "Locality"
        case streetAddress = "StreetAddress"
        case postCode = "PostCode"
    }
    
    func getAddressComponentByName(_ name: String) -> AddressComponent? {
        if name == "AdministrativeArea" {
            return administrativeArea
        }
        
        if name == "Locality" {
            return locality
        }
        
        if name == "StreetAddress" {
            return streetAddress
        }
        
        if name == "PostCode" {
            return postCode
        }
        
        return nil
    }
}

// MARK: - Administrative Area Model
struct AddressComponent: Codable {
    let name: String
    let options: [Option]?
    
    var hasOptions: Bool {
        return options != nil
    }
}

// MARK: - Option Model
struct Option: Codable {
    let id: String
    let name: String
}


struct FindAddressResponse: Decodable {
    let data: Address
    let status: StatusData
}
