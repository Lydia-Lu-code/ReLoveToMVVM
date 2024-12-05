//
//  MockData.swift
//  ReLoveToMVVM
//
//  Created by Lydia Lu on 2024/12/5.
//
import Foundation
import UIKit

struct MockData {
    // MARK: - Mock Products
    static let mockProducts: [Product] = [
        Product(
            id: "1",
            title: "iPhone 14 Pro Max",
            price: 35000,
            description: "9成新，附充電線和保護殼",
            imageUrl: "https://fakeimg.pl/400x400/282828/eae0d0/?text=iPhone",
            sellerID: "user1",
            createdAt: Date()
        ),
        Product(
            id: "2",
            title: "MacBook Air M1",
            price: 28000,
            description: "2022年購入，電池循環次數低",
            imageUrl: "https://fakeimg.pl/400x400/282828/eae0d0/?text=MacBook",
            sellerID: "user2",
            createdAt: Date()
        ),
        Product(
            id: "3",
            title: "AirPods Pro 2",
            price: 6000,
            description: "幾乎全新，附收據保固",
            imageUrl: "https://fakeimg.pl/400x400/282828/eae0d0/?text=AirPods",
            sellerID: "user3",
            createdAt: Date()
        ),
        Product(
            id: "4",
            title: "iPad Air 5",
            price: 18000,
            description: "面板完美，送原廠皮套",
            imageUrl: "https://fakeimg.pl/400x400/282828/eae0d0/?text=iPad",
            sellerID: "user4",
            createdAt: Date()
        )
    ]
    
    // MARK: - Mock Repository
    class MockProductRepository: ProductRepositoryProtocol {
        var products: [Product] = mockProducts
        
        func fetchProducts(completion: @escaping (Result<[Product], APIError>) -> Void) {
            // 模擬網路延遲
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                completion(.success(self.products))
            }
        }
        
        func createProduct(_ product: Product, completion: @escaping (Result<Product, APIError>) -> Void) {
            // 模擬網路延遲
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.products.append(product)
                completion(.success(product))
            }
        }
        
        func updateProduct(_ product: Product, completion: @escaping (Result<Product, APIError>) -> Void) {
            // 模擬網路延遲
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let index = self.products.firstIndex(where: { $0.id == product.id }) {
                    self.products[index] = product
                    completion(.success(product))
                } else {
                    completion(.failure(.noData))
                }
            }
        }
        
        func deleteProduct(id: String, completion: @escaping (Result<Bool, APIError>) -> Void) {
            // 模擬網路延遲
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let index = self.products.firstIndex(where: { $0.id == id }) {
                    self.products.remove(at: index)
                    completion(.success(true))
                } else {
                    completion(.failure(.noData))
                }
            }
        }
    }
}
