import Foundation
import Combine
import Alamofire

class APIClient {
    static let shared = APIClient(environment: Constants.currentEnvironment)
    static let debug = true
    private let baseURL: String
    var authToken: String?
    
    private init(environment: Environment) {
        self.baseURL = environment.baseURL
    }
    
    func get<T: Decodable>(endpoint: String, queryItems: [URLQueryItem]? = nil, headers: [String: String] = [:]) async throws -> T {
        guard var urlComponents = URLComponents(string: baseURL + "/" + endpoint) else {
            throw AFError.invalidURL(url: baseURL + "/" + endpoint)
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw AFError.invalidURL(url: urlComponents.string ?? "")
        }
        
        return try await AF.request(url, method: .get, headers: getHeaders(headers))
            .validate()
            .serializingDecodable(T.self)
            .value
    }
    
    func getPlus<T: Decodable>(
        endpoint: String,
        queryItems: [URLQueryItem]? = nil,
        headers: [String: String] = [:]
    ) async throws -> T {
        
        // Construct URL
        guard var urlComponents = URLComponents(string: baseURL + "/" + endpoint) else {
            throw URLError(.badURL)
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        // Make request
        let response = await AF.request(url, method: .get, headers: getHeaders(headers))
            .serializingData()
            .response
        
        guard let data = response.data else {
            throw URLError(.badServerResponse)
        }

        if APIClient.debug {
            let rspString = String(data: data, encoding: .utf8)
            debugPrint("request: \(url)\nresponse: \(String(describing: rspString))")
        }

        // Handle response
        if let statusCode = response.response?.statusCode, 200...299 ~= statusCode {
            return try JSONDecoder().decode(T.self, from: data)
        } else {
            let error = try JSONDecoder().decode(ErrorResponse.self, from: data)
            throw error
        }
    }

    func post<T: Decodable>(endpoint: String, body: Encodable, headers: [String : String] = [:]) async throws -> T {
        guard let url = URL(string: baseURL + "/" + endpoint) else {
            throw AFError.invalidURL(url: baseURL + "/" + endpoint)
        }
        
        let request = AF.request(url, method: .post, parameters: body, encoder: JSONParameterEncoder.default, headers: getHeaders(headers))
        
        let response = await request.serializingResponse(using: .data).response
        
        switch response.result {
        case .success(let data):
            if APIClient.debug {
                let rspString = String(data: data, encoding: .utf8)
                let payload = try JSONEncoder().encode(body)
                debugPrint("request: \(url) payload:\(String(describing: String(data:payload, encoding: .utf8))) \n response: \(String(describing: rspString))")
            }

            if let statusCode = response.response?.statusCode, 200...299 ~= statusCode {
                // Successful response
                return try JSONDecoder().decode(T.self, from: data)
            } else {
                // Error response
                let error =  try JSONDecoder().decode(ErrorResponse.self, from: data)
                throw error
            }
        case .failure(let error):
            throw error
        }
    }
    
    // Add this method to get the headers
    private func getHeaders(_ additionalHeaders: [String: String] = [:]) -> HTTPHeaders {
        var headers = [
            "Content-Type": "application/json"
        ]
        
        let index = additionalHeaders.keys.firstIndex(of: "Authorization")
        if let token = authToken, index == nil {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        if !additionalHeaders.isEmpty {
            headers.merge(additionalHeaders) { (current, _) in current }
        }
        
        return HTTPHeaders(headers)
    }
}
