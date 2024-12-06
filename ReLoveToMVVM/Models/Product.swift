//
//  Product.swift
//  ReLoveToMVVM
//
//  Created by Lydia Lu on 2024/11/26.
//

import Foundation

struct Product: Codable {
    let id: String
    let title: String
    let price: Double
    let description: String
    let imageUrl: String
    let sellerID: String
    let createdAt: Date
    // 新增可選的詳細資訊欄位
    let shippingFee: Double?
    let condition: String?
    let location: String?
    let deliveryMethod: [String]?
    let paymentMethods: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, price, description
        case imageUrl = "image_url"
        case sellerID = "seller_id"
        case createdAt = "created_at"
        // 新欄位的 CodingKey
        case shippingFee = "shipping_fee"
        case condition
        case location
        case deliveryMethod = "delivery_method"
        case paymentMethods = "payment_methods"
    }
    
    // 保持原有的初始化方法相容性
    init(id: String,
         title: String,
         price: Double,
         description: String,
         imageUrl: String,
         sellerID: String,
         createdAt: Date) {
        self.id = id
        self.title = title
        self.price = price
        self.description = description
        self.imageUrl = imageUrl
        self.sellerID = sellerID
        self.createdAt = createdAt
        // 新欄位設為 nil
        self.shippingFee = nil
        self.condition = nil
        self.location = nil
        self.deliveryMethod = nil
        self.paymentMethods = nil
    }
    
    // 新增完整的初始化方法
    init(id: String,
         title: String,
         price: Double,
         description: String,
         imageUrl: String,
         sellerID: String,
         createdAt: Date,
         shippingFee: Double? = nil,
         condition: String? = nil,
         location: String? = nil,
         deliveryMethod: [String]? = nil,
         paymentMethods: [String]? = nil) {
        self.id = id
        self.title = title
        self.price = price
        self.description = description
        self.imageUrl = imageUrl
        self.sellerID = sellerID
        self.createdAt = createdAt
        self.shippingFee = shippingFee
        self.condition = condition
        self.location = location
        self.deliveryMethod = deliveryMethod
        self.paymentMethods = paymentMethods
    }
}


