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
import AVFoundation //

class ViewController: UIViewController , AVAudioPlayerDelegate{

    var myMotionManager: CMMotionManager!
    var audioPlayer:AVAudioPlayer! //
    
    @IBOutlet var myXLabel: UILabel!
    @IBOutlet var myYLabel: UILabel!
    @IBOutlet var myZLabel: UILabel!
    
    
   /* @IBOutlet var webview : UIWebView!
    @IBOutlet var searchBar: UISearchBar!
    
    
    var targetURL = "https://www.google.co.jp"
    */
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
        
        
        
        /*
        webview.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        loadAddressURL()
        */
        // MotionManagerを生成.
        myMotionManager = CMMotionManager()
        
        // 更新周期を設定.
        myMotionManager.accelerometerUpdateInterval = 0.1
        
        // 加速度の取得を開始.
        myMotionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: {(accelerometerData:CMAccelerometerData?, error:NSError?) -> Void in
           // self.myXLabel.text = "x=\(accelerometerData!.acceleration.x)"
            //xは一応関係なし
            self.myYLabel.text = "y=\(accelerometerData!.acceleration.y)"
            if accelerometerData!.acceleration.y > -0.5 {
                self.myYLabel.backgroundColor = UIColor.blueColor()
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            } else {
                self.myYLabel.backgroundColor = UIColor.clearColor()
            }
            //y<0.5
            self.myZLabel.text = "z=\(accelerometerData!.acceleration.z)"
            //z>0.6
        })
        
        

    }

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
        // Dispose of any resources that can be recreated.
    }
    
    
   /* func loadAddressURL() {
        let requestURL = NSURL(string: targetURL)
        let req = NSURLRequest(URL: requestURL!)
        webview!.loadRequest(req)
    }
    */


}

