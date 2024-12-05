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
//        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
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
        
        // 直接使用 UIAction 來處理按鈕點擊
        let choosePhotoAction = UIAction { _ in
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
             textField.autocorrectionType = .no  // 關閉自動校正
             textField.autocapitalizationType = .none  // 關閉自動大寫
         }
        
//        alert.addTextField { $0.placeholder = "商品名稱" }
//        alert.addTextField {
//            $0.placeholder = "價格"
//            $0.keyboardType = .numberPad
//        }
        
        // 添加按鈕動作
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "確定", style: .default) { _ in
            guard let title = alert.textFields?[0].text,
                  let priceText = alert.textFields?[1].text,
                  let price = Double(priceText)
            else { return }
            onComplete(title, price, selectedImage)
        })
        
        return alert
    }
}

////***
class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
var completion: ((UIImage) -> Void)?
var viewController: UIViewController?

func showImagePicker(from viewController: UIViewController, completion: @escaping (UIImage) -> Void) {
    self.viewController = viewController
    self.completion = completion
    
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
        actionSheet.addAction(UIAlertAction(title: "拍照", style: .default) { [weak self] _ in
            self?.presentImagePicker(sourceType: .camera)
        })
    }
    
    actionSheet.addAction(UIAlertAction(title: "選擇照片", style: .default) { [weak self] _ in
        self?.presentImagePicker(sourceType: .photoLibrary)
    })
    
    actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel))
    viewController.present(actionSheet, animated: true)
}

private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.sourceType = sourceType
    viewController?.present(picker, animated: true)
}

func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true)
    
    if let image = info[.originalImage] as? UIImage {
        completion?(image)
    }
}
}

