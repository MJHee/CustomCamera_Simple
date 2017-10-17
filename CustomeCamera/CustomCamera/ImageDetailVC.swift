//
//  ImageDetailVC.swift
//  zcdb
//
//  Created by HeMengjie on 2017/10/13.
//  Copyright © 2017年 fdzx. All rights reserved.
//

import UIKit


class ImageDetailVC: UIViewController {
    var data: NSData! = nil
    //
    var imageIm: UIImage! = nil
    //处理图片后回调
    var handleImgBlock: SelectImgBlock! = nil
    //
    var isFromSelectImgView: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        //
        self.imageIm = UIImage(data: self.data as Data)
        let imageSize: CGSize = self.imageIm.size
        if (imageSize.width * 1.0 / imgWidth) == (imageSize.height * 1.0 / imgHeight) {
        }else {
            self.handleImage()
        }
        //截取之后将图片显示在相机时页面
        let imageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: (SelfHeight - imgHeight) / 2, width: imgWidth, height: imgHeight))
        imageView.center = CGPoint(x: SelfWidth / 2, y: (SelfHeight - 120) / 2)
        imageView.image = self.imageIm
        self.view.addSubview(imageView)
        //
        let button: UIButton = UIButton(type: .roundedRect)
        button.frame = CGRect(x: 15, y: SelfHeight - 50, width: 40, height: 40)
        button.setTitle("重拍", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        self.view.addSubview(button)
        
        let myLayer: CALayer = CALayer()
        myLayer.bounds = CGRect(x: 0, y: (SelfHeight - imgHeight) / 2, width: imgWidth, height: imgHeight)
        myLayer.position = CGPoint(x: SelfWidth / 2, y: (SelfHeight - 120) / 2)
        myLayer.masksToBounds = true
        myLayer.borderWidth = 1
        myLayer.borderColor = UIColor.white.cgColor
        self.view.layer.addSublayer(myLayer)
        
        //
        let rightButton: UIButton = UIButton(type: .roundedRect)
        rightButton.frame = CGRect(x: SelfWidth - 90, y: SelfHeight - 50, width: 80, height: 40)
        rightButton.setTitle("使用照片", for: .normal)
        rightButton.setTitleColor(UIColor.white, for: .normal)
        rightButton.addTarget(self, action: #selector(rightButtonClick), for: .touchUpInside)
        self.view.addSubview(rightButton)
    }
    //处理图片
    func handleImage() {
        //截取照片，截取到自定义框内的照片
        let imgSize: CGSize = self.imageIm.size
        let height: CGFloat = imgSize.height * SelfWidth / imgSize.width
        self.imageIm = self.imageWithScaleToSize(image: self.imageIm, size: CGSize(width: SelfWidth, height: height))
        var rect: CGRect = CGRect(x: 0, y: (SelfHeight - imgHeight) / 2 * 2, width: imgWidth * 2, height: imgHeight * 2)
        if self.isFromSelectImgView == true {
            rect = CGRect(x: 0, y: 0, width: imgWidth * 2, height: imgHeight * 2)
        }
        self.imageIm = self.imageFromImageInRect(image: self.imageIm, rect: rect)
    }
    //使用图片
    @objc func rightButtonClick() {
        if self.isFromSelectImgView == false {
            //将图片存储到相册
            UIImageWriteToSavedPhotosAlbum(self.imageIm, self, nil, nil)
        }
        //退出本页面并将图片传到上个页面
        if self.handleImgBlock != nil {
            self.handleImgBlock(self.imageIm)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    //截取图片
    func imageWithScaleToSize(image: UIImage, size: CGSize) -> UIImage {
        
        /*
         UIGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale)
         CGSize size：指定将来创建出来的bitmap的大小
         BOOL opaque：设置透明YES代表透明，NO代表不透明
         CGFloat scale：代表缩放,0代表不缩放
         创建出来的bitmap就对应一个UIImage对象
         */
        UIGraphicsBeginImageContextWithOptions(size, false, 2.0)//此处将画布放大两倍，这样在retina屏截取时不会影响像素
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let scaledImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    func imageFromImageInRect(image: UIImage, rect: CGRect) -> UIImage {
        let sourceImgRef: CGImage = image.cgImage!
        let newImageRef: CGImage = sourceImgRef.cropping(to: rect)!
        let newImage: UIImage = UIImage(cgImage: newImageRef)
        return newImage
    }
    
    //返回
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
}
