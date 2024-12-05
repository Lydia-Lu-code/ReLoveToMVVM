//
//  AlertManager.swift
//  ReLoveToMVVM
//
//  Created by Lydia Lu on 2024/12/5.
//

import Foundation
import UIKit

class ProductAlertView {
    static func showProductAlert(
        title: String,
        selectedImage: UIImage?,
        imagePreviewView: UIImageView?,
        onChoosePhoto: @escaping () -> Void,
        onComplete: @escaping (String, Double, UIImage?) -> Void
    ) -> UIAlertController {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        // 建立容器視圖
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // 建立並設置圖片視圖
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = selectedImage ?? UIImage(systemName: "photo")
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(imageView)
        
        // 建立選擇照片按鈕
        let photoButton = UIButton(type: .system)
        photoButton.setTitle("選擇照片", for: .normal)
        photoButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 使用明確的類型
        let choosePhotoAction = UIAction { [weak imageView] (action: UIAction) in
            onChoosePhoto()
        }
        photoButton.addAction(choosePhotoAction, for: .touchUpInside)
        
        container.addSubview(photoButton)
        
        // 設置自動佈局約束
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 160),
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            photoButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            photoButton.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        
        // 設置容器視圖控制器
        let containerVC = UIViewController()
        containerVC.view = container
        alert.setValue(containerVC, forKey: "contentViewController")
        
        // 添加文字輸入欄位
        alert.addTextField { textField in
            textField.placeholder = "商品名稱"
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
        }
        
        alert.addTextField {
            $0.placeholder = "價格"
            $0.keyboardType = .numberPad
        }
        
        // 添加按鈕動作
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "確定", style: .default) { [weak imageView] _ in
            guard let title = alert.textFields?[0].text,
                  let priceText = alert.textFields?[1].text,
                  let price = Double(priceText)
            else { return }
            // 使用選擇的圖片
            onComplete(title, price, selectedImage)
        })
        
        return alert
    }
}


