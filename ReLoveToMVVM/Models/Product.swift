//
//  Product.swift
//  ReLoveToMVVM
//
//  Created by Lydia Lu on 2024/11/26.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case serverError(Int)
    case decodingError
    case noData
    case htmlParsingError
    case redirectRequired(String)
}

struct Product: Codable {
    let id: String
    let title: String
    let price: Double
    let description: String
    let imageUrl: String
    let sellerID: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, price, description
        case imageUrl = "image_url"
        case sellerID = "seller_id"
        case createdAt = "created_at"
    }
}
