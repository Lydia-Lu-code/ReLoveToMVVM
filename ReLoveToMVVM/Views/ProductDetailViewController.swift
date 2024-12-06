//
//  ProductDetailViewController.swift
//  ReLoveToMVVM
//
//  Created by Lydia Lu on 2024/12/5.
//

import UIKit

class ProductDetailViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: ProductDetailViewModel
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = .systemGray6
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .systemBlue
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initialization
    init(viewModel: ProductDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = viewModel.title
        
        // 設置 scrollView 和 contentStack
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        // 添加圖片視圖
        let imageContainer = UIView()
        imageContainer.addSubview(imageView)
        contentStack.addArrangedSubview(imageContainer)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            
            imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor)
        ])
        
        setupDetailInfo()
    }
    
    private func updateUI() {
        // 設置圖片
        imageView.image = viewModel.productImage
    }
    
    private func setupDetailInfo() {
        // 添加分隔線
        let separator = UIView()
        separator.backgroundColor = .systemGray5
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        contentStack.addArrangedSubview(separator)
        
        // 添加商品資訊
        let components: [(String, String)] = [
            ("價格", viewModel.price),
            ("商品描述", viewModel.description),
            ("運費", viewModel.shippingFee),
            ("商品狀況", viewModel.condition),
            ("所在地區", viewModel.location),
            ("運送方式", viewModel.deliveryMethods),
            ("付款方式", viewModel.paymentMethods),
            ("刊登時間", viewModel.createdDate)
        ]
        
        components.forEach { title, content in
            let containerView = createInfoView(title: title, content: content)
            contentStack.addArrangedSubview(containerView)
        }
    }
    
    private func createInfoView(title: String, content: String) -> UIView {
        let container = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        
        let contentLabel = UILabel()
        contentLabel.text = content
        contentLabel.font = .systemFont(ofSize: 16)
        contentLabel.numberOfLines = 0
        
        [titleLabel, contentLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            contentLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            contentLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])
        
        return container
    }
    
}
