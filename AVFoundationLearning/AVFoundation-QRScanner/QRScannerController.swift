//
//  ViewController.swift
//  AVFoundation-QRScanner
//
//  Created by xiabob on 17/3/27.
//  Copyright © 2017年 xiabob. All rights reserved.
//

import UIKit
import AVFoundation

//http://www.appcoda.com/barcode-reader-swift/
class QRScannerController: UIViewController {
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    lazy var qrCodeFrameView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor.green.cgColor
        view.layer.borderWidth = 1
        view.isHidden = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        //需要视频数据
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            //设置输入源,物理设备摄像头等
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            //设置输出源
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            //设置代理对象和方法回调处理的queue，要确保执行队列是串行的
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue(label: "com.xiabob.QRCode"))
            //https://developer.apple.com/reference/avfoundation/avmetadatamachinereadablecodeobject/machine_readable_object_types 设置识别的类型，只有类型匹配才会触发回调
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            //设置videoPreviewLayer
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            //start video capture
            captureSession?.startRunning()
            
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        } catch {
            print(error)
            return
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects.count == 0 {
            print("error for captureOutput")
            return
        }
        
        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObject.type == AVMetadataObjectTypeQRCode {
            //找到二维码对应的位置
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject)
            print("frame:\(barCodeObject)")
            print("string:\(metadataObject.stringValue)")
            print("corners:\(metadataObject.corners)")
            
            DispatchQueue.main.async {
                self.qrCodeFrameView.frame = (barCodeObject?.bounds)!
                self.qrCodeFrameView.isHidden = false
            }
        }
    }
}
