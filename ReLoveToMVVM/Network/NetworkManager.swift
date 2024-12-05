import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://your-api-endpoint.com/api/v1"
    private let session: URLSession
    
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    // 通用網路請求方法
    private func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Data? = nil,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            // 打印原始響應數據
            if let data = data, let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw response data: \(rawResponse)")
            }
            
            // 錯誤處理
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.networkError(NSError(domain: "", code: -1))))
                return
            }
            
            // 狀態碼檢查
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.serverError(httpResponse.statusCode)))
                return
            }
            
            // 檢查是否有數據
            guard let data = data, !data.isEmpty else {
                if T.self == EmptyResponse.self || T.self == Void.self {
                    completion(.success(EmptyResponse() as! T))
                } else {
                    completion(.failure(.noData))
                }
                return
            }
            
            // 嘗試將數據轉換為字符串
            if let htmlString = String(data: data, encoding: .utf8) {
                // 嘗試從 HTML 中提取 JSON
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
                
                // 檢查是否為重定向 HTML
                if let redirectURL = HTMLToJSONParser.handleRedirectHTML(htmlString) {
                    completion(.failure(.redirectRequired(redirectURL)))
                    return
                }
            }
            
            // 標準 JSON 解碼
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let decodedData = try decoder.decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError))
            }
        }
        
        task.resume()
    }
    
    // 佔位結構體，用於不需要返回數據的操作
    struct EmptyResponse: Codable {}
    
    // MARK: - Products API
    
    // 獲取所有產品
    func fetchProducts(completion: @escaping (Result<[Product], APIError>) -> Void) {
        request(endpoint: "/products", completion: completion)
    }
    
    // 獲取特定產品
    func fetchProduct(id: String, completion: @escaping (Result<Product, APIError>) -> Void) {
        request(endpoint: "/products/\(id)", completion: completion)
    }
    
    // 創建新產品
    func createProduct(_ product: Product, completion: @escaping (Result<Product, APIError>) -> Void) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(product)
            
            request(
                endpoint: "/products",
                method: .post,
                body: data,
                completion: completion
            )
        } catch {
            completion(.failure(.decodingError))
        }
    }
    
    // 更新產品
    func updateProduct(_ product: Product, completion: @escaping (Result<Product, APIError>) -> Void) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(product)
            
            request(
                endpoint: "/products/\(product.id)",
                method: .put,
                body: data,
                completion: completion
            )
        } catch {
            completion(.failure(.decodingError))
        }
    }
    
    // 刪除產品
    func deleteProduct(id: String, completion: @escaping (Result<Void, APIError>) -> Void) {
        request(
            endpoint: "/products/\(id)",
            method: .delete,
            completion: completion as! (Result<EmptyResponse, APIError>) -> Void
        )
    }
}


//****
protocol NetworkServiceProtocol {
    func request<T: Codable>(endpoint: APIEndpoint, body: Data?, completion: @escaping (Result<T, APIError>) -> Void)
}


