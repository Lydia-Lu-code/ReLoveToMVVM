import UIKit

class ProductListViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: ProductListViewModel
    private let imagePickerManager: ImagePickerManager
    private var selectedImage: UIImage?
    
    // MARK: - UI Components
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private lazy var collectionView: UICollectionView = {
        let layout = createCollectionViewLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.identifier)
        cv.delegate = self
        cv.dataSource = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    // MARK: - Initialization
    init(viewModel: ProductListViewModel = ProductListViewModel(repository: MockData.MockProductRepository()),
         imagePickerManager: ImagePickerManager = ImagePickerManager()) {
        self.viewModel = viewModel
        self.imagePickerManager = imagePickerManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = ProductListViewModel(repository: MockData.MockProductRepository())
        self.imagePickerManager = ImagePickerManager()
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupNavigationBar()
        viewModel.fetchProducts()
    }
    
    // MARK: - Private Methods - Setup
    private func setupUI() {
        title = "二手商品"
        view.backgroundColor = .systemBackground
        
        setupCollectionView()
        setupActivityIndicator()
        setupRefreshControl()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                      target: self,
                                      action: #selector(showAddProductAlert))
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let itemWidth = (UIScreen.main.bounds.width - 30) / 2
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.5)
        
        return layout
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
        
        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
    }
    
    // MARK: - Private Methods - Actions
    @objc private func refreshData() {
        viewModel.fetchProducts()
    }
    
    @objc private func showAddProductAlert() {
        let alert = ProductAlertView.showProductAlert(
            title: "新增商品",
            selectedImage: selectedImage,  // 使用當前選擇的圖片
            imagePreviewView: nil,
            onChoosePhoto: { [weak self] in
                self?.dismiss(animated: true) {
                    guard let self = self else { return }
                    self.imagePickerManager.showImagePicker(from: self) { image in
                        self.selectedImage = image  // 保存新選擇的圖片
                        // 重新顯示 alert 並使用新的圖片
                        DispatchQueue.main.async {
                            self.showAddProductAlert()  // 重新顯示 alert
                        }
                    }
                }
            },
            onComplete: { [weak self] title, price, _ in  // 這裡使用 _ 因為我們會直接使用 selectedImage
                let newProduct = Product(
                    id: UUID().uuidString,
                    title: title,
                    price: price,
                    description: "測試商品",
                    // 如果有選擇圖片則使用本地路徑
                    imageUrl: self?.selectedImage != nil ? "local://temp_image" : "https://picsum.photos/400",
                    sellerID: "testUser",
                    createdAt: Date()
                )
                // 使用保存的 selectedImage
                self?.viewModel.createProduct(newProduct, image: self?.selectedImage)
                self?.selectedImage = nil  // 清除選擇的圖片
            }
        )
        
        present(alert, animated: true)
    }
    
    private func showEditAlert(for product: Product) {
        // 使用 currentImage 來顯示當前圖片，包括新選擇的圖片
        let currentImage = selectedImage ?? viewModel.getProductImage(for: product.id)
        
        let alert = ProductAlertView.showProductAlert(
            title: "編輯商品",
            selectedImage: currentImage,
            imagePreviewView: nil,
            onChoosePhoto: { [weak self] in
                self?.dismiss(animated: true) {
                    guard let self = self else { return }
                    self.imagePickerManager.showImagePicker(from: self) { image in
                        self.selectedImage = image  // 保存新選擇的圖片
                        DispatchQueue.main.async {
                            self.showEditAlert(for: product)  // 重新顯示編輯視窗
                        }
                    }
                }
            },
            onComplete: { [weak self] title, price, _ in  // 使用 selectedImage 而不是傳入的 image
                let updatedProduct = Product(
                    id: product.id,
                    title: title,
                    price: price,
                    description: product.description,
                    imageUrl: self?.selectedImage != nil ? "local://temp_image" : product.imageUrl,
                    sellerID: product.sellerID,
                    createdAt: product.createdAt
                )
                // 使用 selectedImage 更新產品
                self?.viewModel.updateProduct(updatedProduct, image: self?.selectedImage)
                self?.selectedImage = nil  // 清除暫存圖片
            }
        )
        
        // 設定文字欄位
        alert.textFields?[0].text = product.title
        alert.textFields?[1].text = String(product.price)
        
        present(alert, animated: true)
    }
  
    private func handleImageSelection(completion: @escaping (UIImage) -> Void) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.imagePickerManager.showImagePicker(from: self) { image in
                completion(image)
            }
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "錯誤", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension ProductListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfProducts()
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
            
            let deleteAction = UIAction(title: "刪除",
                                      image: UIImage(systemName: "trash"),
                                      attributes: .destructive) { [weak self] _ in
                self?.viewModel.deleteProduct(id: product.id)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}
