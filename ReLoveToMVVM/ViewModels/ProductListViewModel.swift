import Foundation
import UIKit

class ProductListViewModel {
    // MARK: - Properties
    private var products: [Product] = []
    private var productImages: [String: UIImage] = [:]
    private let repository: ProductRepositoryProtocol
    
    // MARK: - Callbacks
    var onProductsUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    // MARK: - Initialization
    init(repository: ProductRepositoryProtocol = ProductRepository()) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    func createProduct(_ product: Product, image: UIImage?) {
        onLoading?(true)
        if let image = image {
            productImages[product.id] = image
        }
        repository.createProduct(product) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleResult(result)
            }
        }
    }
    
    func updateProduct(_ product: Product, image: UIImage?) {
        onLoading?(true)
        // 無論是否為新圖片，都更新圖片快取
        if let image = image {
            productImages[product.id] = image
        }
        
        repository.updateProduct(product) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedProduct):
                    if let index = self?.products.firstIndex(where: { $0.id == updatedProduct.id }) {
                        self?.products[index] = updatedProduct
                    }
                    // 確保在成功時觸發 UI 更新
                    self?.onProductsUpdated?()
                case .failure(let error):
                    self?.handleError(error)
                    // 失敗時移除暫存的圖片
                    self?.productImages.removeValue(forKey: product.id)
                }
                self?.onLoading?(false)
            }
        }
    }
    
    func deleteProduct(id: String) {
        onLoading?(true)
        repository.deleteProduct(id: id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.products.removeAll { $0.id == id }
                    self?.productImages.removeValue(forKey: id)
                    self?.onProductsUpdated?()
                case .failure(let error):
                    self?.handleError(error)
                }
                self?.onLoading?(false)
            }
        }
    }
    
    func fetchProducts() {
        onLoading?(true)
        repository.fetchProducts { [weak self] result in
            DispatchQueue.main.async {
                self?.handleResult(result)
            }
        }
    }
    
    // MARK: - Data Access Methods
    func numberOfProducts() -> Int {
        return products.count
    }
    
    func product(at index: Int) -> Product {
        return products[index]
    }
    
    func getProductImage(for productId: String) -> UIImage? {
        return productImages[productId]
    }
    
    // MARK: - Private Methods
    private func handleResult<T>(_ result: Result<T, APIError>) {
        onLoading?(false)
        switch result {
        case .success(let data):
            if let products = data as? [Product] {
                self.products = products
            } else if let product = data as? Product {
                if let index = self.products.firstIndex(where: { $0.id == product.id }) {
                    self.products[index] = product
                } else {
                    self.products.append(product)
                }
            }
            onProductsUpdated?()
        case .failure(let error):
            handleError(error)
        }
    }
    
    private func handleError(_ error: APIError) {
        let message: String
        switch error {
        case .invalidURL: message = "無效的URL"
        case .noData: message = "沒有收到資料"
        case .decodingError: message = "資料解析錯誤"
        case .networkError: message = "網路連線錯誤"
        case .serverError(let code): message = "伺服器錯誤 (錯誤碼: \(code))"
        case .htmlParsingError: message = "HTML解析失敗"
        case .redirectRequired(let url): message = "需要重新導向到：\(url)"
        }
        onError?(message)
    }
}

// 測試用擴展
extension ProductListViewModel {
    static func previewViewModel() -> ProductListViewModel {
        return ProductListViewModel(repository: MockData.MockProductRepository())
    }
}
