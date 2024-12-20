//
//  ProductDetailViewModel.swift
//  ReLoveToMVVM
//
//  Created by Lydia Lu on 2024/12/5.
//

import Foundation
import UIKit

class ProductDetailViewModel {
    private let product: Product
    private let repository: ProductRepositoryProtocol
    private let image: UIImage?
    
    // 用於綁定 UI 更新
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Initialization
    init(product: Product,
         productImage: UIImage?,
         repository: ProductRepositoryProtocol = ProductRepository()) {
        self.product = product
        self.image = productImage
        self.repository = repository
    }
    
    // 取得圖片
    var productImage: UIImage? {
        return image ?? UIImage(systemName: "photo")
    }
    
    // MARK: - Data Access Methods
    var title: String { product.title }
    var price: String { "NT$ \(Int(product.price))" }
    var description: String { product.description }
    var shippingFee: String {
        guard let fee = product.shippingFee else { return "免運費" }
        return "運費：NT$ \(Int(fee))"
    }
    var condition: String { product.condition ?? "商品狀況未提供" }
    var location: String { product.location ?? "地區未提供" }
    var deliveryMethods: String {
        product.deliveryMethod?.joined(separator: ", ") ?? "未提供運送方式"
    }
    var paymentMethods: String {
        product.paymentMethods?.joined(separator: ", ") ?? "未提供付款方式"
    }
    var createdDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "刊登日期：\(formatter.string(from: product.createdAt))"
    }
    
    private func getLocalImage(for productId: String) -> UIImage? {
        // 從本地取得圖片的邏輯
        return nil // 需要實作
    }
    
}
