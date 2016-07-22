//
//  ViewController.swift
//  PokeCam
//
//  Created by miyamo on 2016/07/22.
//  Copyright © 2016年 Zombiyamo. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion
import CoreImage

class ViewController: UIViewController,UITextFieldDelegate {
    //name/CP
    var nameLabel: UILabel!
    var nameString: String!
    var slashString: String!
    var cpString: String!
    
    //textField
    //Camera
    var input:AVCaptureDeviceInput!
    var output:AVCaptureStillImageOutput!
    var session:AVCaptureSession!
    var preView:UIView!
    var camera:AVCaptureDevice!
    var previewLayer = AVCaptureVideoPreviewLayer()

    @IBOutlet weak var captureBtn: UIButton!
    @IBOutlet weak var ballView: UIView!
    @IBOutlet weak var labelView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameString = "ダンボー"
        slashString = "  /  "
        cpString = "CP" + String(arc4random_uniform(1000))
        
         nameLabel = UILabel(frame: CGRectMake(0,0,200,50))
         nameLabel.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
         nameLabel.textColor = UIColor.whiteColor()
         nameLabel.layer.masksToBounds = true
         nameLabel.layer.cornerRadius = 25.0
         nameLabel.text = nameString + slashString + cpString
         nameLabel.textAlignment = NSTextAlignment.Center
         nameLabel.layer.position = CGPoint(x: self.view.bounds.width/2,y: 200)
         nameLabel.numberOfLines = 1
        nameLabel.adjustsFontSizeToFitWidth = true
        //単語の途中で改行されないようにする
        nameLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        nameLabel.userInteractionEnabled = true
         self.labelView.addSubview(nameLabel)
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        changeNameAlertController()
    }
    
    // メモリ管理のため
    override func viewWillAppear(animated: Bool) {
        // スクリーン設定
        setupDisplay()
        // カメラの設定
        setupCamera()
    }
    
    // メモリ管理のため
    override func viewDidDisappear(animated: Bool) {
        // camera stop メモリ解放
        session.stopRunning()
        
        for output in session.outputs {
            session.removeOutput(output as? AVCaptureOutput)
        }
        
        for input in session.inputs {
            session.removeInput(input as? AVCaptureInput)
        }
        session = nil
        camera = nil
    }
    
    func setupDisplay(){
        //スクリーンの幅
        let screenWidth = UIScreen.mainScreen().bounds.size.width;
        //スクリーンの高さ
        let screenHeight = UIScreen.mainScreen().bounds.size.height;
        
        // プレビュー用のビューを生成
        preView = UIView(frame: CGRectMake(0.0, 0.0, screenWidth, screenHeight))
        self.view.sendSubviewToBack(preView)
        
    }
    
    func setupCamera(){
        
        // セッション
        session = AVCaptureSession()
        
        for caputureDevice: AnyObject in AVCaptureDevice.devices() {
            // 背面カメラを取得
            if caputureDevice.position == AVCaptureDevicePosition.Back {
                camera = caputureDevice as? AVCaptureDevice
            }
            // 前面カメラを取得
            //if caputureDevice.position == AVCaptureDevicePosition.Front {
            //    camera = caputureDevice as? AVCaptureDevice
            //}
        }
        
        // カメラからの入力データ
        do {
            input = try AVCaptureDeviceInput(device: camera) as AVCaptureDeviceInput
        } catch let error as NSError {
            print(error)
        }
        
        // 入力をセッションに追加
        if(session.canAddInput(input)) {
            session.addInput(input)
        }
        
        // 静止画出力のインスタンス生成
        output = AVCaptureStillImageOutput()
        // 出力をセッションに追加
        if(session.canAddOutput(output)) {
            session.addOutput(output)
        }
        
        // セッションからプレビューを表示
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
        
        
        previewLayer.frame = preView.frame
        
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        
        // レイヤーをViewに設定
        // これを外すとプレビューが無くなる、けれど撮影はできる
        self.view.layer.addSublayer(previewLayer)
        session.startRunning()
        
        self.view.bringSubviewToFront(self.labelView)
        self.view.bringSubviewToFront(self.ballView)
    }
    
    // タップイベント.
    func tapped(sender: UITapGestureRecognizer){
        print("タップ")
        takeStillPicture()
    }
    @IBAction func captureButton(sender: UIButton){
        takeStillPicture()
    }
    
    func takeStillPicture(){
        
        // ビデオ出力に接続.
        if let connection:AVCaptureConnection? = output.connectionWithMediaType(AVMediaTypeVideo){
            // ビデオ出力から画像を非同期で取得
            output.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: { (imageDataBuffer, error) -> Void in
                
                // 取得画像のDataBufferをJpegに変換
                let imageData:NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
                
                self.view.backgroundColor = UIColor.clearColor()
                
                // JpegからUIImageを作成.
                let pictureImage = UIImage(data: imageData)!
                
                // グラフィックスコンテキストを作る
                let size: CGSize = CGSizeMake(self.view.frame.width, self.view.frame.height)
                UIGraphicsBeginImageContext(size)
                //Retina画質に合わせるためscaleを0に
                UIGraphicsBeginImageContextWithOptions(size, true, 0)
                
                //元画像を描画
                pictureImage.drawInRect(CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                
                //重ね合わせる画像を描画
                self.view.backgroundColor = UIColor.clearColor()
                let labelImage = self.labelView.toImage()!
                labelImage.drawInRect(CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                
                let shrinkedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext();

                
                // アルバムに追加.
                UIImageWriteToSavedPhotosAlbum(shrinkedImage, self, nil, nil)
            })
        }
    }
    
    func changeNameAlertController(){
        let alert:UIAlertController = UIAlertController(title:"ニックネームをつける",
                                                        message: "",
                                                        preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel",
                                                       style: UIAlertActionStyle.Cancel,
                                                       handler:{
                                                        (action:UIAlertAction!) -> Void in
                                                        print("Cancel")
        })
        let defaultAction:UIAlertAction = UIAlertAction(title: "OK",
                                                        style: UIAlertActionStyle.Default,
                                                        handler:{
                                                            (action:UIAlertAction!) -> Void in
                                                            let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                                                            if textFields != nil {
                                                                for textField:UITextField in textFields! {
                                                                    self.nameString = textField.text!
                                                                    self.cpString = "CP" + String(arc4random_uniform(1000))
                                                                    self.nameLabel.text = self.nameString + self.slashString + self.cpString
                                                                    self.labelView.addSubview(self.nameLabel)
                                                                }
                                                            }
        })

        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        //textfiledの追加
        alert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
        })
        
        presentViewController(alert, animated: true, completion: nil)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

