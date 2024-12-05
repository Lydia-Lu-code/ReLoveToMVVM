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
    
    func fetchProducts() {
        onLoading?(true)
        repository.fetchProducts { [weak self] result in
            DispatchQueue.main.async {
                self?.handleResult(result)
            }
        }
    }
    
    // 更新產品和圖片的方法
    func updateProduct(_ product: Product, image: UIImage?) {
        onLoading?(true)
        if let image = image {
            productImages[product.id] = image
        }
        repository.updateProduct(product) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedProduct):
                    if let index = self?.products.firstIndex(where: { $0.id == updatedProduct.id }) {
                        self?.products[index] = updatedProduct
                        self?.onProductsUpdated?()
                    }
                case .failure(let error):
                    self?.handleError(error)
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
                    // 從本地數組和圖片快取中移除
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
    
//    func updateProduct(_ product: Product) {
//        onLoading?(true)
//        repository.updateProduct(product) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.handleResult(result)
//            }
//        }
//    }
//    
//    func deleteProduct(id: String) {
//        onLoading?(true)
//        repository.deleteProduct(id: id) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.handleResult(result)
//            }
//        }
//    }
    
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
        case .invalidURL:
            message = "無效的URL"
        case .noData:
            message = "沒有收到資料"
        case .decodingError:
            message = "資料解析錯誤"
        case .networkError:
            message = "網路連線錯誤"
        case .serverError(let code):
            message = "伺服器錯誤 (錯誤碼: \(code))"
        case .htmlParsingError:
            message = "HTML解析失敗，無法處理伺服器回應"
        case .redirectRequired(let url):
            message = "需要重新導向到：\(url)"
        }
        onError?(message)
    }
}

// ﻿測試檔案用
extension ProductListViewModel {
    static func previewViewModel() -> ProductListViewModel {
        return ProductListViewModel(repository: MockData.MockProductRepository())
    }
}


//class ProductListViewModel {
//    // MARK: - Properties
//    private var products: [Product] = []
//    
//    // 回調閉包
//    var onProductsUpdated: (() -> Void)?
//    var onError: ((String) -> Void)?
//    var onLoading: ((Bool) -> Void)?
//    
//    private var loadingTimer: Timer?
//    private let minimumLoadingTime: TimeInterval = 1.0
//    private var loadingStartTime: Date?
//    
//    private let repository: ProductRepositoryProtocol
//    
//    init(repository: ProductRepositoryProtocol = ProductRepository()) {
//        self.repository = repository
//    }
//    
//    var productImages: [String: UIImage] = [:]
//    
//    func showAddProductAlert(on viewController: UIViewController, completion: @escaping (Product) -> Void) {
//        let alert = UIAlertController(title: "新增商品", message: nil, preferredStyle: .alert)
//        
//        // UI Setup
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        imageView.layer.cornerRadius = 8
//        imageView.clipsToBounds = true
//        imageView.backgroundColor = .systemGray6
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        alert.view.addSubview(imageView)
//        
//        NSLayoutConstraint.activate([
//            imageView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 60),
//            imageView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
//            imageView.widthAnchor.constraint(equalToConstant: 200),
//            imageView.heightAnchor.constraint(equalToConstant: 120),
//            alert.view.heightAnchor.constraint(equalToConstant: 380)
//        ])
//        
//        // Text Fields
//        alert.addTextField { $0.placeholder = "商品名稱" }
//        alert.addTextField {
//            $0.placeholder = "價格"
//            $0.keyboardType = .numberPad
//        }
//        
//        // Actions
//        alert.addAction(UIAlertAction(title: "選擇照片", style: .default) { _ in
//            // Photo picker implementation
//        })
//        
//        alert.addAction(UIAlertAction(title: "新增", style: .default) { _ in
//            guard let title = alert.textFields?[0].text,
//                  let priceText = alert.textFields?[1].text,
//                  let price = Double(priceText) else { return }
//            
//            let product = Product(
//                id: UUID().uuidString,
//                title: title,
//                price: price,
//                description: "測試商品",
//                imageUrl: "local://temp_image",
//                sellerID: "testUser",
//                createdAt: Date()
//            )
//            completion(product)
//        })
//        
//        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
//        viewController.present(alert, animated: true)
//    }
//    
//    func createProduct(_ product: Product, image: UIImage?) {
//        onLoading?(true)
//        if let image = image {
//            productImages[product.id] = image
//        }
//        products.append(product)
//        onProductsUpdated?()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.onLoading?(false)
//        }
//    }
//    
//    func getProductImage(for productId: String) -> UIImage? {
//        return productImages[productId]
//    }
//  
//    
//    // 獲取所有產品
//    func fetchProducts() {
//        onLoading?(true)
//        repository.fetchProducts { [weak self] result in
//            DispatchQueue.main.async {
//                self?.onLoading?(false)
//                switch result {
//                case .success(let products):
//                    self?.products = products
//                    self?.onProductsUpdated?()
//                case .failure(let error):
//                    self?.handleError(error)
//                }
//            }
//        }
//    }
//    
//
//    // 更新產品
//    func updateProduct(_ product: Product) {
//        onLoading?(true)
//        
//        NetworkManager.shared.updateProduct(product) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.onLoading?(false)
//                
//                switch result {
//                case .success(let updatedProduct):
//                    if let index = self?.products.firstIndex(where: { $0.id == updatedProduct.id }) {
//                        self?.products[index] = updatedProduct
//                        self?.onProductsUpdated?()
//                    }
//                    
//                case .failure(let error):
//                    self?.handleError(error)
//                }
//            }
//        }
//    }
//    
//    func deleteProduct(id: String) {
//        onLoading?(true)
//        
//        // 從本地數組中移除
//        products.removeAll { $0.id == id }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
//            self?.onProductsUpdated?()
//            self?.onLoading?(false)
//        }
//    }
//    
//    
//    // MARK: - 測試數據 (可選)
//    func addTestData() {
//        onLoading?(true)  // 開始 loading
//        
//        // 延遲加載資料，模擬網路請求
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
//            guard let self = self else { return }
//            
//            self.products = [
//                Product(
//                    id: "1",
//                    title: "iPhone 14 Pro Max",
//                    price: 35000,
//                    description: "9成新，附充電線和保護殼",
//                    imageUrl: "https://fakeimg.pl/400x400/282828/eae0d0/?text=iPhone",
//                    sellerID: "user1",
//                    createdAt: Date()
//                ),
//                Product(
//                    id: "2",
//                    title: "MacBook Air M1",
//                    price: 28000,
//                    description: "2022年購入，電池循環次數低",
//                    imageUrl: "https://fakeimg.pl/400x400/282828/eae0d0/?text=MacBook",
//                    sellerID: "user2",
//                    createdAt: Date()
//                ),
//                Product(
//                    id: "3",
//                    title: "AirPods Pro 2",
//                    price: 6000,
//                    description: "幾乎全新，附收據保固",
//                    imageUrl: "https://fakeimg.pl/400x400/282828/eae0d0/?text=AirPods",
//                    sellerID: "user3",
//                    createdAt: Date()
//                ),
//                Product(
//                    id: "4",
//                    title: "iPad Air 5",
//                    price: 18000,
//                    description: "面板完美，送原廠皮套",
//                    imageUrl: "https://fakeimg.pl/400x400/282828/eae0d0/?text=iPad",
//                    sellerID: "user4",
//                    createdAt: Date()
//                )
//            ]
//            
//            self.onProductsUpdated?()  // 更新資料
//            self.onLoading?(false)     // 停止 loading
//        }
//    }
//    
//    
//    // MARK: - 數據訪問方法
//    func numberOfProducts() -> Int {
//        return products.count
//    }
//    
//    func product(at index: Int) -> Product {
//        return products[index]
//    }
//    
//    // MARK: - 錯誤處理
//    private func handleError(_ error: APIError) {
//        let message: String
//        switch error {
//        case .invalidURL:
//            message = "無效的URL"
//        case .noData:
//            message = "沒有收到資料"
//        case .decodingError:
//            message = "資料解析錯誤"
//        case .networkError:
//            message = "網路連線錯誤"
//        case .serverError(let code):
//            message = "伺服器錯誤 (錯誤碼: \(code))"
//        case .htmlParsingError:
//            message = "HTML解析失敗，無法處理伺服器回應"
//        case .redirectRequired(let url):
//            message = "需要重新導向到：\(url)"
//        }
//        onError?(message)
//    }
//    
//    
//    
//}
