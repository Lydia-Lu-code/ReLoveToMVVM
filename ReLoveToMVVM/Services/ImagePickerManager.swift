//
//  ImagePickerManager.swift
//  ReLoveToMVVM
//
//  Created by Lydia Lu on 2024/12/4.
//

import Foundation
import UIKit

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
