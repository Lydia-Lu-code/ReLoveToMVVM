//
//  NetworkService.swift
//  ReLoveToMVVM
//
//  Created by Lydia Lu on 2024/12/4.
//

import Foundation

class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    private let baseURL = "https://your-api-endpoint.com/api/v1"
    private let session: URLSession
    
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    // NetworkService.swift
    func request<T: Codable>(endpoint: APIEndpoint, body: Data? = nil, completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: baseURL + endpoint.path) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.networkError(NSError(domain: "", code: -1))))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.serverError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data, !data.isEmpty else {
                if T.self == EmptyResponse.self {
                    completion(.success(EmptyResponse() as! T))
                } else {
                    completion(.failure(.noData))
                }
                return
            }
            
            if let htmlString = String(data: data, encoding: .utf8) {
                if let jsonDict = HTMLToJSONParser.extractJSONFromHTML(htmlString) {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: jsonDict)
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        let decodedData = try decoder.decode(T.self, from: jsonData)
                        completion(.success(decodedData))
                        return
                    } catch {
                        completion(.failure(.htmlParsingError))
                        return
                    }
                }
                
                if let redirectURL = HTMLToJSONParser.handleRedirectHTML(htmlString) {
                    completion(.failure(.redirectRequired(redirectURL)))
                    return
                }
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let decodedData = try decoder.decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(.decodingError))
            }
        }
        
        task.resume()
    }

    struct EmptyResponse: Codable {}
}



