//
//  APIEndpoints.swift
//  ReLoveToMVVM
//
//  Created by Lydia Lu on 2024/11/26.
//

import Foundation



enum APIEndpoint {
    case getProducts
    case getProduct(id: String)
    case createProduct
    case updateProduct(id: String)
    case deleteProduct(id: String)
    
    var path: String {
        switch self {
        case .getProducts:
            return "/products"
        case .getProduct(let id):
            return "/products/\(id)"
        case .createProduct:
            return "/products"
        case .updateProduct(let id):
            return "/products/\(id)"
        case .deleteProduct(let id):
            return "/products/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getProducts, .getProduct:
            return .get
        case .createProduct:
            return .post
        case .updateProduct:
            return .put
        case .deleteProduct:
            return .delete
        }
    }
}
