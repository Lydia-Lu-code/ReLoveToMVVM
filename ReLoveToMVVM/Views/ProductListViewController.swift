import UIKit

class ProductListViewController: UIViewController {

    private let activityIndicator = UIActivityIndicatorView(style: .large)
        
    private let imagePickerManager = ImagePickerManager()
    private var selectedImage: UIImage?
    private var imagePreviewView: UIImageView?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let itemWidth = (UIScreen.main.bounds.width - 30) / 2
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.5)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.identifier)
        cv.delegate = self
        cv.dataSource = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    
    private let viewModel: ProductListViewModel = {
        // 使用 Mock Repository 初始化 ViewModel
        let mockRepository = MockData.MockProductRepository()
        return ProductListViewModel(repository: mockRepository)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupTestButtons()

        // 直接呼叫 fetchProducts 來獲取 mock 資料
        viewModel.fetchProducts()

    }
    
    
    
    private func setupUI() {
        title = "二手商品"
        view.backgroundColor = .systemBackground
        
        // 設置 CollectionView
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 設置載入指示器
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // 設置下拉刷新
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func setupBindings() {
        viewModel.onProductsUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.collectionView.refreshControl?.endRefreshing()
            }
        }
        
        viewModel.onLoading = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "錯誤", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func refreshData() {
        viewModel.fetchProducts()
    }
    
    private func setupTestButtons() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAddProductAlert))
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc private func showAddProductAlert() {
        let alert = ProductAlertView.showProductAlert(
            title: "新增商品",
            selectedImage: selectedImage,
            imagePreviewView: imagePreviewView,
            onChoosePhoto: { [weak self] in
                self?.dismiss(animated: true) {
                    guard let self = self else { return }
                    self.imagePickerManager.showImagePicker(from: self) { image in
                        self.selectedImage = image
                        DispatchQueue.main.async {
                            self.showAddProductAlert()
                        }
                    }
                }
            },
            onComplete: { [weak self] title, price, image in
                let newProduct = Product(
                    id: UUID().uuidString,
                    title: title,
                    price: price,
                    description: "測試商品",
                    imageUrl: image != nil ? "local://temp_image" : "https://picsum.photos/400",
                    sellerID: "testUser",
                    createdAt: Date()
                )
                self?.viewModel.createProduct(newProduct, image: image)
                self?.selectedImage = nil
            }
        )
        
        present(alert, animated: true)
    }
    
    private func showEditAlert(for product: Product) {
        // 先取得當前產品的圖片
        let currentImage = viewModel.getProductImage(for: product.id) ??
                          UIImage(named: product.imageUrl) // 如果是本地圖片
        
        let alert = ProductAlertView.showProductAlert(
            title: "編輯商品",
            selectedImage: currentImage, // 使用當前圖片
            imagePreviewView: imagePreviewView,
            onChoosePhoto: { [weak self] in
                self?.dismiss(animated: true) {
                    guard let self = self else { return }
                    self.imagePickerManager.showImagePicker(from: self) { image in
                        self.selectedImage = image
                        DispatchQueue.main.async {
                            self.showEditAlert(for: product)
                        }
                    }
                }
            },
            onComplete: { [weak self] title, price, image in
                let updatedProduct = Product(
                    id: product.id,
                    title: title,
                    price: price,
                    description: product.description,
                    imageUrl: image != nil ? "local://temp_image" : product.imageUrl,
                    sellerID: product.sellerID,
                    createdAt: product.createdAt
                )
                self?.viewModel.updateProduct(updatedProduct, image: image)
                self?.selectedImage = nil
            }
        )

        alert.textFields?[0].text = product.title
        alert.textFields?[1].text = String(product.price)
        
        present(alert, animated: true)
    }

//    private func showEditAlert(for product: Product) {
//        let alert = ProductAlertView.showProductAlert(
//            title: "編輯商品",
//            selectedImage: selectedImage,
//            imagePreviewView: imagePreviewView,
//            onChoosePhoto: { [weak self] in
//                self?.dismiss(animated: true) {
//                    guard let self = self else { return }
//                    self.imagePickerManager.showImagePicker(from: self) { image in
//                        self.selectedImage = image
//                        DispatchQueue.main.async {
//                            self.showEditAlert(for: product)
//                        }
//                    }
//                }
//            },
//            onComplete: { [weak self] title, price, image in
//                let updatedProduct = Product(
//                    id: product.id,
//                    title: title,
//                    price: price,
//                    description: product.description,
//                    imageUrl: image != nil ? "local://temp_image" : product.imageUrl,
//                    sellerID: product.sellerID,
//                    createdAt: product.createdAt
//                )
//                self?.viewModel.updateProduct(updatedProduct)
//                self?.selectedImage = nil
//            }
//        )
//        
//        alert.textFields?[0].text = product.title
//        alert.textFields?[1].text = String(product.price)
//        
//        present(alert, animated: true)
//    }
    
    
    @objc private func testCreateProduct() {
        let newProduct = Product(
            id: UUID().uuidString,
            title: "新測試產品",
            price: 5000,
            description: "這是一個測試創建的產品",
            imageUrl: "https://fakeimg.pl/400x400/282828/eae0d0/?text=Test",
            sellerID: "testUser",
            createdAt: Date()
        )
        
        viewModel.createProduct(newProduct, image: selectedImage)
    }
    
    @objc private func testDeleteProduct() {
        // 刪除第一個產品（如果存在）
        guard viewModel.numberOfProducts() > 0 else { return }
        let productToDelete = viewModel.product(at: 0)
        viewModel.deleteProduct(id: productToDelete.id)
    }
    
}

// MARK: - UICollectionView DataSource & Delegate
extension ProductListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // 在 UICollectionViewDataSource 方法中
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = viewModel.numberOfProducts()
        print("Number of products: \(count)") // 檢查商品數量
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCell.identifier, for: indexPath) as? ProductCell else {
            return UICollectionViewCell()
        }
        
        let product = viewModel.product(at: indexPath.item)
        cell.configure(with: product, viewModel: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let product = viewModel.product(at: indexPath.item)
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "編輯", image: UIImage(systemName: "pencil")) { [weak self] _ in
                self?.showEditAlert(for: product)
            }
            
            let deleteAction = UIAction(title: "刪除", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.viewModel.deleteProduct(id: product.id)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
}
