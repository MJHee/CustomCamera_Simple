//
//  ViewController.swift
//  CustomeCamera
//
//  Created by HeMengjie on 2017/10/17.
//  Copyright © 2017年 hmj. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var imagePickerController: UIImagePickerController! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        let cameraBtn: UIButton = UIButton(frame: CGRect(x: 20, y: 100, width: 80, height: 30))
        cameraBtn.backgroundColor = UIColor.red
        cameraBtn.setTitle("拍照", for: .normal)
        cameraBtn.setTitleColor(UIColor.white, for: .normal)
        cameraBtn.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        self.view.addSubview(cameraBtn)
        //
        let selectImgBtn: UIButton = UIButton(frame: CGRect(x: SelfWidth - 100, y: 100, width: 80, height: 30))
        selectImgBtn.backgroundColor = UIColor.red
        selectImgBtn.setTitle("选择照片", for: .normal)
        selectImgBtn.setTitleColor(UIColor.white, for: .normal)
        selectImgBtn.addTarget(self, action: #selector(selectPhoto), for: .touchUpInside)
        self.view.addSubview(selectImgBtn)
        //
        let imagePickerController: UIImagePickerController = UIImagePickerController()
        imagePickerController.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        self.imagePickerController = imagePickerController
    }
    
    //拍照
    @objc func takePhoto() {
        let vc: CustomCameraVC = CustomCameraVC()
        vc.handleImgBlock = { image in
            //对图片进行处理
        }
        self.present(vc, animated: true, completion: nil)
    }
    //选择照片
    @objc func selectPhoto() {
        // album
        self.imagePickerController.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let data: NSData = UIImagePNGRepresentation(image)! as NSData
        weak var weakSelf = self
        picker.dismiss(animated: true) {
            //
            let vc: ImageDetailVC = ImageDetailVC()
            vc.data = data
            vc.isFromSelectImgView = true
            vc.handleImgBlock = { image in
                //处理图片
            }
            weakSelf?.present(vc, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

