//
//  ViewController.swift
//  SystemViewControllers
//
//  Created by 曹家瑋 on 2023/10/11.
//

import UIKit
import SafariServices   // 導入 SafariServices
import MessageUI        // 導入 MessageUI

class ViewController: UIViewController {
    
    @IBOutlet weak var myImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // 分享功能按鈕
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        // 檢查 myImageView 中是否有圖片。如果沒有，則立即退出。
        guard let image = myImageView.image else { return}
        // let text = "Hello, World!"   // 測試觀察用
        
        // UIActivityViewController
        // activityItems:希望與其他app分享的對象、 applicationActivities:提供自定義的分享服務與否。
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        // 為了iPad的兼容性，我們設置 popover 的源視圖。在iPhone上這個設置將被忽略。
        activityController.popoverPresentationController?.sourceView = sender
        
        // 使用 present 來顯示 UIActivityViewController。
        present(activityController, animated: true, completion: nil)
    }
    
    // 開啟網頁按鈕
    @IBAction func safariButtonTapped(_ sender: UIButton) {
        
        // 使用一個指定的 String（ Instagram 的一個頁面的網址）
        if let url = URL(string: "https://www.instagram.com/shoheiohtani/") {
            // 使用創建的 URL 來初始化一個 SFSafariViewController 物件
            let safariViewController = SFSafariViewController(url: url)
            // 呈現 SFSafariViewController，允許用戶在App內部瀏覽網頁
            present(safariViewController, animated: true, completion: nil)
        }
    }
    
    // 此功能觸發時，會彈出選項讓用戶選擇照片來源：相機或照片庫
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        
        // 創建 UIImagePickerController 來選擇或拍攝照片
        let imagePicker = UIImagePickerController()
        // 設定此 view controller 為 imagePicker 的delegate，以處理用戶的圖片選擇或取消選擇
        imagePicker.delegate = self
        
        // 創建一個 action sheet ，用於顯示兩個選項：「Camera」和「Photo Library」
        let alertController = UIAlertController(title: "選取照片來源", message: nil, preferredStyle: .actionSheet)
        
        // 檢查當前設備是否支援相機功能
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // 如果可用，添加一個選擇相機的動作
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
                // 設定照片來源為相機，並呈現
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
            // 把動作加入到alertController
            alertController.addAction(cameraAction)
        }
        
        // 檢查照片庫是否可用
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // 如果可用，添加一個選擇照片庫的動作
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in
                // 設定照片來源為照片庫，並呈現圖像選擇器
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
            // 把動作加入到alertController
            alertController.addAction(photoLibraryAction)
        }
        
        // 添加一個取消動作，允許用戶關閉actionSheet
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // 確保在iPad上正確呈現：actionSheet 在iPad上需要一個來源視圖或條目來正確呈現
        alertController.popoverPresentationController?.sourceView = sender
        present(alertController, animated: true, completion: nil)
    }
    
    // 寄送郵件
    @IBAction func emailButtonTapped(_ sender: UIButton) {
        // 檢查設備是否可以發送郵件
        guard MFMailComposeViewController.canSendMail() else {
            print("Can not send mail")
            return
        }
        
        // 創建郵件編輯控制器
        let mailComposer = MFMailComposeViewController()
        // 設定郵件控制器的代理
        mailComposer.delegate = self
        
        // 設定收件人地址
        mailComposer.setToRecipients(["example@example.com"])
        // 設定郵件主題
        mailComposer.setSubject("Look at this")
        // 設定郵件內容
        mailComposer.setMessageBody("Hello, this is an email from the app I made.", isHTML: false)
        
        // 檢查是否有一個可用的圖片，如果有的話，將它作為附件添加到郵件中
        if let image = myImageView.image,
           let jpegData = image.jpegData(compressionQuality: 0.9) {
            mailComposer.addAttachmentData(jpegData, mimeType: "image/jpeg", fileName: "photo.jpg")
        }
        
        // 呈現郵件編輯控制器
        present(mailComposer, animated: true, completion: nil)
    }
    
}


// 擴展（Extension）ViewController 以遵從 UIImagePickerControllerDelegate 和 UINavigationControllerDelegate
extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // 當用戶選擇了一張圖片後，這個方法將被調用
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // 嘗試從 info 字典中提取用戶選擇的圖片。如果無法將圖片轉換為 UIImage，則直接返回。
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        
        // 將選擇的圖片設置為 myImageView 的 image 屬性，以便在界面上顯示它
        myImageView.image = selectedImage
        // 使用動畫效果關閉圖片選擇器界面
        dismiss(animated: true, completion: nil)
    }
}

// 遵循MFMailComposeViewControllerDelegate協議
extension ViewController: MFMailComposeViewControllerDelegate {
    
    // 當郵件發送完成或用戶取消時，關閉郵件編輯控制器
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
