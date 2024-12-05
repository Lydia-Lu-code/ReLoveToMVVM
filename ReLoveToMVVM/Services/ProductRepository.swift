//
//  ProductRepository.swift
//  ReLoveToMVVM
//
//  Created by Lydia Lu on 2024/12/4.
//

import Foundation

protocol ProductRepositoryProtocol {
    func fetchProducts(completion: @escaping (Result<[Product], APIError>) -> Void)
    func createProduct(_ product: Product, completion: @escaping (Result<Product, APIError>) -> Void)
    func updateProduct(_ product: Product, completion: @escaping (Result<Product, APIError>) -> Void)
    //    func deleteProduct(id: String, completion: @escaping (Result<Void, APIError>) -> Void)
    func deleteProduct(id: String, completion: @escaping (Result<Bool, APIError>) -> Void)

}

class ProductRepository: ProductRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func fetchProducts(completion: @escaping (Result<[Product], APIError>) -> Void) {
        networkService.request(endpoint: .getProducts, body: nil, completion: completion)
    }
    
    func createProduct(_ product: Product, completion: @escaping (Result<Product, APIError>) -> Void) {
        let data = try? JSONEncoder().encode(product)
        networkService.request(endpoint: .createProduct, body: data, completion: completion)
    }
    
    func updateProduct(_ product: Product, completion: @escaping (Result<Product, APIError>) -> Void) {
        let data = try? JSONEncoder().encode(product)
        networkService.request(endpoint: .updateProduct(id: product.id), body: data, completion: completion)
    }
    
    func deleteProduct(id: String, completion: @escaping (Result<Bool, APIError>) -> Void) {
        networkService.request(endpoint: .deleteProduct(id: id), body: nil) { (result: Result<Bool, APIError>) in
            completion(result)
        }
    }
    
//    func deleteProduct(id: String, completion: @escaping (Result<EmptyResponse, APIError>) -> Void) {
//        networkService.request(endpoint: .deleteProduct(id: id), body: nil, completion: completion)
//    }
//    func deleteProduct(id: String, completion: @escaping (Result<Void, APIError>) -> Void) {
//        networkService.request(endpoint: .deleteProduct(id: id), body: nil, completion: completion)
//    }
}
