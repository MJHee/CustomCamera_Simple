//
//  CustomCameraVC.swift
//  zcdb
//
//  Created by HeMengjie on 2017/10/13.
//  Copyright © 2017年 fdzx. All rights reserved.
//

import UIKit
import AVFoundation

typealias SelectImgBlock = (_ image: UIImage) -> Void

let SelfWidth = UIScreen.main.bounds.size.width
let SelfHeight = UIScreen.main.bounds.size.height
//想要的图片大小
let imgWidth = UIScreen.main.bounds.size.width
let imgHeight = imgWidth / 1.3

class CustomCameraVC: UIViewController {
    var session: AVCaptureSession! = nil
    /**
     *  输入设备
     */
    var videoInput: AVCaptureDeviceInput! = nil
    /**
     *  照片输出流
     */
    var stillImageOutput: AVCaptureStillImageOutput! = nil
    /**
     *  预览图层
     */
    var previewLayer: AVCaptureVideoPreviewLayer! = nil
    /**
     *  最后的缩放比例
     */
    var effectiveScale: CGFloat = 0.0
    var backView: UIView! = nil
    //处理图片后回调
    var handleImgBlock: SelectImgBlock! = nil
    //
    var needDismiss: Bool = false
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.session != nil {
            self.session.startRunning()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.needDismiss == true {
            self.needDismiss = false
            self.dismiss(animated: false, completion: nil)
            return
        }
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.session != nil {
            self.session.stopRunning()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        //
        self.backView = UIView(frame: CGRect(x: 0, y: 0, width: SelfWidth, height: SelfHeight - 120))
        self.view.addSubview(self.backView)
        //
        let view: UIView = UIView(frame: CGRect(x: SelfWidth / 2 - 30, y: SelfHeight - 120 + 30, width: 60, height: 60))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 30
        view.layer.masksToBounds = true
        self.view.addSubview(view)
        
        //自定义一个和原生相机一样的按钮
        let button: UIButton = UIButton(type: .roundedRect)
        button.frame = CGRect(x: SelfWidth / 2 - 25, y: SelfHeight - 120 + 35, width: 50, height: 50)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(buttonDown), for: .touchUpInside)
        self.view.addSubview(button)
        
        //在相机中加一个框
        let myLayer: CALayer = CALayer()
        myLayer.bounds = CGRect(x: 0, y: (SelfHeight - imgHeight) / 2, width: imgWidth, height: imgHeight)
        myLayer.position = CGPoint(x: SelfWidth / 2, y: (SelfHeight - 120) / 2)
        myLayer.masksToBounds = true
        myLayer.borderWidth = 1
        myLayer.borderColor = UIColor.white.cgColor
        self.view.layer.addSublayer(myLayer)
        
        let LBtn: UIButton = UIButton(type: .roundedRect)
        LBtn.frame = CGRect(x: 20, y: SelfHeight - 80, width: 40, height: 40)
        LBtn.setTitle("取消", for: .normal)
        LBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        LBtn.setTitleColor(UIColor.white, for: .normal)
        LBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        self.view.addSubview(LBtn)
        
        //
        self.initAVCaptureSession()
        self.effectiveScale = 1.0
    }
    
    //设置相机属性
    func initAVCaptureSession() {
        self.session = AVCaptureSession()
        self.session.sessionPreset = AVCaptureSession.Preset.high
        let device: AVCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) as! AVCaptureDevice
        
        //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
            } catch _ {
            }
            //设置闪光灯为自动
            device.flashMode = AVCaptureDevice.FlashMode.auto
            //解锁
            device.unlockForConfiguration()
        }
        do{
            //
            self.videoInput = try AVCaptureDeviceInput(device: device)
        }catch{
            return
        }
        let captureOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
        self.stillImageOutput = AVCaptureStillImageOutput()
        //输出设置：AVVideoCodecJPEG   输出jpeg格式图片
        let outputSettings: NSDictionary = NSDictionary.init(objects: [AVVideoCodecJPEG], forKeys: [AVVideoCodecKey as NSCopying])
        self.stillImageOutput.outputSettings = outputSettings as! [AnyHashable : Any] as! [String : Any]
        
        if self.session.canAddInput(self.videoInput) == true {
            self.session.addInput(self.videoInput)
        }
        if self.session.canAddOutput(captureOutput) {
            self.session.addOutput(captureOutput)
        }
        if self.session.canAddOutput(self.stillImageOutput) {
            self.session.addOutput(self.stillImageOutput)
        }
        //初始化预览图层
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer.frame = CGRect(x: 0, y: 0, width: SelfWidth, height: SelfHeight - 120)
        self.backView.layer.masksToBounds = true
        self.backView.layer.addSublayer(self.previewLayer)
        
    }
    
    func avOrientationForDeviceOrientation(deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        var result: AVCaptureVideoOrientation = AVCaptureVideoOrientation.landscapeLeft
        if deviceOrientation == UIDeviceOrientation.landscapeLeft {
            result = AVCaptureVideoOrientation.landscapeRight
        }else if deviceOrientation == UIDeviceOrientation.landscapeRight {
            result = AVCaptureVideoOrientation.landscapeLeft
        }else if deviceOrientation == UIDeviceOrientation.portrait {
            result = AVCaptureVideoOrientation.portrait
        }else if deviceOrientation == UIDeviceOrientation.portraitUpsideDown {
            result = AVCaptureVideoOrientation.portraitUpsideDown
        }
        return result
    }
    //拍照
    @objc func buttonDown() {
        let stillImageConnection: AVCaptureConnection = self.stillImageOutput.connection(with: AVMediaType.video)!
        let curDeviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
        let avcaptureOrientation: AVCaptureVideoOrientation = self.avOrientationForDeviceOrientation(deviceOrientation: curDeviceOrientation)
        stillImageConnection.videoOrientation = avcaptureOrientation
        stillImageConnection.videoScaleAndCropFactor = self.effectiveScale
        self.stillImageOutput.captureStillImageAsynchronously(from: stillImageConnection) { (imageDataSampleBuffer, error) in
            let jpegData: NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer!)! as NSData
            self.makeImageView(data: jpegData)
        }
        
    }
    //拍照之后调到相片详情页面
    func makeImageView(data: NSData) {
        let imageDetailVC : ImageDetailVC = ImageDetailVC()
        imageDetailVC.data = data
        imageDetailVC.isFromSelectImgView = false
        imageDetailVC.handleImgBlock = { image in
            if self.handleImgBlock != nil {
                self.handleImgBlock(image)
            }
            self.needDismiss = true
        }
        self.present(imageDetailVC, animated: false, completion: nil)
    }
    //返回
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
}

