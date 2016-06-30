//
//  ViewController.swift
//  kasukudo
//
//  Created by Miho Takamura on 2016/04/27.
//  Copyright © 2016年 Miho Takamura. All rights reserved.
//

import UIKit
import CoreMotion
import AudioToolbox
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var MotionManager: CMMotionManager!
    var audioPlayer:AVAudioPlayer! //
    
    @IBOutlet var xLabel: UILabel!
    @IBOutlet var yLabel: UILabel!
    @IBOutlet var zLabel: UILabel!
    
    
   /* @IBOutlet var webview : UIWebView!
    @IBOutlet var searchBar: UISearchBar!
    var targetURL = "https://www.google.co.jp"
    */
    
    var input:AVCaptureDeviceInput!
    var output:AVCaptureVideoDataOutput!
    var session:AVCaptureSession!
    var camera:AVCaptureDevice!
    var imageView:UIImageView!
    
    @IBOutlet var boardimageView: UIImageView!
    
    var eyecount: Int = 0
    
    /** 画像認識 **/
    var detector:CIDetector?
    @IBOutlet private weak var outputTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        
        //*****音楽再生*****
        //再生するaudioファイルのパスを取得,Stringに！！
        let audioPath = NSURL(fileURLWithPath: String(NSBundle.mainBundle().pathForResource("20000hz",ofType:"mp3")!))
        do{
            //audioを再生するプレイヤーを作成する
            audioPlayer = try AVAudioPlayer(contentsOfURL: audioPath)
            //無限に再生する
            audioPlayer.numberOfLoops = -1
        }catch{
            print("Error")
        }
        
        //バックグラウンドでも再生できるカテゴリに設定する!!!!!!!!!!!!!!!!!!!!!!!!!
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch  {
            fatalError("カテゴリ設定失敗")
        }
        //sessionのアクティブ化
        do {
            try session.setActive(true)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            // audio session有効化失敗時の処理
            // (ここではエラーとして停止している）
            fatalError("session有効化失敗")
        }
        //*****音楽再生のプログラム終了*****
 
        
        //何秒に一回写真を撮る　　  //selector:のあと"takeStillPicture"でもいいけど警告になる
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.takeStillPicture), userInfo: nil, repeats: true)
        
        NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: #selector(ViewController.hantei), userInfo: nil, repeats: true)
        
        
        /*
        webview.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        loadAddressURL()
        */
        // MotionManagerを生成.
        MotionManager = CMMotionManager()
        
        // 更新周期を設定.
        MotionManager.accelerometerUpdateInterval = 0.1
        
        // 加速度の取得を開始.
        MotionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: {(accelerometerData:CMAccelerometerData?, error:NSError?) -> Void in
           // self.myXLabel.text = "x=\(accelerometerData!.acceleration.x)"
            //xは一応関係なし
            self.yLabel.text = "y=\(accelerometerData!.acceleration.y)"
            if accelerometerData!.acceleration.y > -0.5 {
                
                //アラート表示
               let alert: UIAlertController = UIAlertController(title: "BAD", message: "姿勢が悪いです", preferredStyle: .Alert)
                let alertAction = UIAlertAction(title: "OK", style: .Default) { action in
                }
                alert.addAction(alertAction)
                self.presentViewController(alert, animated: true, completion: nil)
                
                
                self.yLabel.backgroundColor = UIColor.blueColor()
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    
                
            } else {
                self.yLabel.backgroundColor = UIColor.clearColor()
            }
            //y<0.5
            self.zLabel.text = "z=\(accelerometerData!.acceleration.z)"
            //z>0.6
        })
        
        

    }
    
    override func viewWillAppear(animated: Bool) {
        // スクリーン設定
        setupDisplay()
        // カメラの設定
        setupCamera()
    }
    
    // メモリ解放
  /*  override func viewDidDisappear(animated: Bool) {
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
    }*/
    
    func setupDisplay(){
        //スクリーンの幅
        let screenWidth = UIScreen.mainScreen().bounds.size.width;
        //スクリーンの高さ
        let screenHeight = UIScreen.mainScreen().bounds.size.height;
        
        // プレビュー用のビューを生成
        imageView = UIImageView()
        imageView.frame = CGRectMake(0.0, 0.0, screenWidth, screenHeight)
    }
    
    func setupCamera(){
        // AVCaptureSession: キャプチャに関する入力と出力の管理
        session = AVCaptureSession()
        
        // sessionPreset: キャプチャ・クオリティの設定
        session.sessionPreset = AVCaptureSessionPresetHigh
        //        session.sessionPreset = AVCaptureSessionPresetPhoto
        //        session.sessionPreset = AVCaptureSessionPresetHigh
        //        session.sessionPreset = AVCaptureSessionPresetMedium
        //        session.sessionPreset = AVCaptureSessionPresetLow
        
        // AVCaptureDevice: カメラやマイクなどのデバイスを設定
        for caputureDevice: AnyObject in AVCaptureDevice.devices() {
            // 前面カメラを取得
            if caputureDevice.position == AVCaptureDevicePosition.Front { //背面Front を　Backに
                camera = caputureDevice as? AVCaptureDevice
            }
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
        
        // AVCaptureStillImageOutput:静止画
        // AVCaptureMovieFileOutput:動画ファイル
        // AVCaptureVideoDataOutput:動画フレームデータ
        
        // AVCaptureVideoDataOutput:動画フレームデータを出力に設定
        output = AVCaptureVideoDataOutput()
        // 出力をセッションに追加
        if(session.canAddOutput(output)) {
            session.addOutput(output)
        }
        
        // ピクセルフォーマットを 32bit BGR + A とする
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey : Int(kCVPixelFormatType_32BGRA)]
        
        // フレームをキャプチャするためのサブスレッド用のシリアルキューを用意
        output.setSampleBufferDelegate(self, queue: dispatch_get_main_queue())
        
        output.alwaysDiscardsLateVideoFrames = true
        
        // ビデオ出力に接続
        // let connection = output.connectionWithMediaType(AVMediaTypeVideo)
        
        session.startRunning()
        
        // deviceをロックして設定
        // swift 2.0
        do {
            try camera.lockForConfiguration()
            // フレームレート
            camera.activeVideoMinFrameDuration = CMTimeMake(1, 30)
            
            camera.unlockForConfiguration()
        } catch _ {
        }
    }
    
    
    // 新しいキャプチャの追加で呼ばれる
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        // キャプチャしたsampleBufferからUIImageを作成
        let image:UIImage = self.captureImage(sampleBuffer)
        
        
        // originalImage = self.captureImage(sampleBuffer)//付け足し
        
        // 画像を画面に表示
        dispatch_async(dispatch_get_main_queue()) {
            self.imageView.image = image
            // UIImageViewをビューに追加
            
            //ここを消すとプレビューがなくなるけど撮影はできる!!!!!!!!
            //self.view.addSubview(self.imageView)
        }
    }
    
    // sampleBufferからUIImageを作成
    func captureImage(sampleBuffer:CMSampleBufferRef) -> UIImage{
        
        // Sampling Bufferから画像を取得
        let imageBuffer:CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        // pixel buffer のベースアドレスをロック
        CVPixelBufferLockBaseAddress(imageBuffer, 0)
        
        let baseAddress:UnsafeMutablePointer<Void> = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
        
        let bytesPerRow:Int = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width:Int = CVPixelBufferGetWidth(imageBuffer)
        let height:Int = CVPixelBufferGetHeight(imageBuffer)
        
        // 色空間
        let colorSpace:CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        
        let bitsPerCompornent: Int = 8
        // swift 2.0
        let newContext:CGContextRef = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace,  CGImageAlphaInfo.PremultipliedFirst.rawValue|CGBitmapInfo.ByteOrder32Little.rawValue)!
        
        let imageRef:CGImageRef = CGBitmapContextCreateImage(newContext)!
        let resultImage = UIImage(CGImage: imageRef, scale: 1.0, orientation: UIImageOrientation.Right)
        
        //  ImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        return resultImage
    }
    
    func takeStillPicture(){
        if var connection:AVCaptureConnection? = output.connectionWithMediaType(AVMediaTypeVideo){
            // アルバムに追加
            // UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, nil, nil)
            //  imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
            detectFaces()
        }
    }
    
    //ここから先表情認識のため追加
    private func detectFaces() {
        
        //let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        //  dispatch_async(queue) {
        
        self.boardimageView.image = self.imageView.image
      
        //CGImageで90度回転してしまうから、ここで元から90度回転させておく
        UIGraphicsBeginImageContextWithOptions(self.imageView.image!.size, true, 0)
        self.imageView.image!.drawInRect(CGRectMake(0, 0, self.imageView.image!.size.width, self.imageView.image!.size.height))
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // create CGImage from image on storyboard.
        guard let image = self.imageView.image, cgImage = image.CGImage else {
            return
        }
        let ciImage = CIImage(CGImage: cgImage)
        
        self.boardimageView.image = image
        
        
        // set CIDetectorTypeFace.
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
        // set options
        let options = [CIDetectorSmile : true, CIDetectorEyeBlink : true]
        
        // get features from image
        let features = detector.featuresInImage(ciImage, options: options)
        
        var resultString = "DETECTED FACES:\n\n"
        
        //  self.boardimageView.image = image
        
        for feature in features as! [CIFaceFeature] {
            
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            
            
            resultString.appendContentsOf("bounds: \(NSStringFromCGRect(feature.bounds))\n")
            resultString.appendContentsOf("hasSmile: \(feature.hasSmile ? "YES" : "NO")\n")
            resultString.appendContentsOf("faceAngle: \(feature.hasFaceAngle ? String(feature.faceAngle) : "NONE")\n")
            resultString.appendContentsOf("leftEyeClosed: \(feature.leftEyeClosed ? "YES" : "NO")\n")
            resultString.appendContentsOf("rightEyeClosed: \(feature.rightEyeClosed ? "YES" : "NO")\n")
            resultString.appendContentsOf("\n")
            
            //付け足し　判定
            if (feature.leftEyeClosed || feature.rightEyeClosed) {
                eyecount += 1
            }
            
        }
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.outputTextView.text = "\(resultString)"
        }
    }
    
    func hantei() {
        if(eyecount < 15) {
            //ここになにか
            //アラート表示
            let alert: UIAlertController = UIAlertController(title: "BAD", message: "瞬きが少ないですよよ！", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "OK", style: .Default) { action in
            }
            alert.addAction(alertAction)
            self.presentViewController(alert, animated: true, completion: nil)
            //  self.outputTextView.backgroundColor = UIColor.cyanColor()
        } else {
            //
            //アラート表示
            let alert: UIAlertController = UIAlertController(title: "GOOD MABATAKI", message: "まばたきいいよ！", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "OK", style: .Default) { action in
            }
            alert.addAction(alertAction)
            self.presentViewController(alert, animated: true, completion: nil)
            // self.outputTextView.backgroundColor = UIColor.redColor()
        }
        eyecount = 0
    }
    
    
    
   /* func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil))
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
        var alert = UIAlertView()
        alert.title = "Message"
        alert.message = notification.alertBody
        alert.addButtonWithTitle(notification.alertAction)
        alert.show()
    }*/
    
    

    /*// ロード時にインジケータをまわす
    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        print("indicator on")
    }
    
    // ロード完了でインジケータ非表示
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        print("indicator off")
    }
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
   /* func loadAddressURL() {
        let requestURL = NSURL(string: targetURL)
        let req = NSURLRequest(URL: requestURL!)
        webview!.loadRequest(req)
    }
    */


}

