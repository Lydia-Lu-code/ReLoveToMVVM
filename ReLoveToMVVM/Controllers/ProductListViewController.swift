import UIKit

class ProductListViewController: UIViewController {
    
    private let viewModel = ProductListViewModel()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupTestButtons()
        viewModel.addTestData()  // 測試數據
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
        let alert = UIAlertController(title: "新增商品", message: nil, preferredStyle: .alert)
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = selectedImage ?? UIImage(systemName: "photo")
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(choosePhoto))
        imageView.addGestureRecognizer(tapGesture)
        container.addSubview(imageView)
        imagePreviewView = imageView
        
        let photoButton = UIButton(type: .system)
        photoButton.setTitle("選擇照片", for: .normal)
        photoButton.translatesAutoresizingMaskIntoConstraints = false
        photoButton.addTarget(self, action: #selector(choosePhoto), for: .touchUpInside)
        container.addSubview(photoButton)
        
        alert.addTextField { textField in
            textField.placeholder = "商品名稱"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "價格"
            textField.keyboardType = .numberPad
        }
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 160),
            
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            
            photoButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            photoButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
        ])
        
        let containerVC = UIViewController()
        containerVC.view = container
        alert.setValue(containerVC, forKey: "contentViewController")
        
        let addAction = UIAlertAction(title: "新增", style: .default) { [weak self] _ in
            guard let title = alert.textFields?[0].text,
                  let priceText = alert.textFields?[1].text,
                  let price = Double(priceText),
                  !title.isEmpty
            else {
                self?.showError("請填寫完整資訊")
                return
            }
            
            let newProduct = Product(
                id: UUID().uuidString,
                title: title,
                price: price,
                description: "測試商品",
                imageUrl: self?.selectedImage != nil ? "local://temp_image" : "https://picsum.photos/400",
                sellerID: "testUser",
                createdAt: Date()
            )
            
            self?.viewModel.createProduct(newProduct, image: self?.selectedImage)
            self?.selectedImage = nil
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func choosePhoto() {
       dismiss(animated: true) { [weak self] in
           guard let self = self else { return }
           self.imagePickerManager.showImagePicker(from: self) { image in
               self.selectedImage = image
               DispatchQueue.main.async {
                   self.showAddProductAlert()
               }
           }
       }
    }
  
    
    
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
    
    private func showEditAlert(for product: Product) {
        let alert = UIAlertController(title: "編輯商品", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = product.title
        }
        alert.addTextField { textField in
            textField.text = String(product.price)
            textField.keyboardType = .numberPad
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "更新", style: .default) { [weak self] _ in
            guard let title = alert.textFields?[0].text,
                  let priceText = alert.textFields?[1].text,
                  let price = Double(priceText)
            else { return }
            
            let updatedProduct = Product(
                id: product.id,
                title: title,
                price: price,
                description: product.description,
                imageUrl: product.imageUrl,
                sellerID: product.sellerID,
                createdAt: product.createdAt
            )
            
            self?.viewModel.updateProduct(updatedProduct)
        })
        
        present(alert, animated: true)
    }
    
}
