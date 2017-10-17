//
//  ViewController.swift
//  CustomeCamera
//
//  Created by HeMengjie on 2017/10/17.
//  Copyright © 2017年 hmj. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        let cameraBtn: UIButton = UIButton(frame: CGRect(x: 20, y: 100, width: 80, height: 30))
        cameraBtn.backgroundColor = UIColor.red
        cameraBtn.setTitle("拍照", for: .normal)
        cameraBtn.setTitleColor(UIColor.white, for: .normal)
        cameraBtn.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        self.view.addSubview(cameraBtn)
    }
    
    //拍照
    @objc func takePhoto() {
        let vc: CustomCameraVC = CustomCameraVC()
        vc.handleImgBlock = { image in
            //对图片进行处理
        }
        self.present(vc, animated: true, completion: nil)
    }
}

