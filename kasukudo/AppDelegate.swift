//
//  AppDelegate.swift
//  kasukudo
//
//  Created by Miho Takamura on 2016/04/27.
//  Copyright © 2016年 Miho Takamura. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


 /*   func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }*/
    //ApDelegate.swifの起動時に呼ばれる関数
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //Notification登録前のおまじない。テストの為、現在のノーティフケーションを削除します
        UIApplication.sharedApplication().cancelAllLocalNotifications();
        
        //Notification登録前のおまじない。これがないとpermissionエラーが発生するので必要です。
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound, .Alert, .Badge], categories: nil))
        
        //以下で登録処理
        let notification = UILocalNotification()
        //notification.fireDate = NSDate(timeIntervalSinceNow: 5);//５秒後
        //notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertBody = "姿勢が悪いよ"
        notification.alertAction = "OK"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification);
        
        return true
    }
    //上記のNotificatioを５秒後に受け取る関数
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
        let alert = UIAlertView();
        alert.title = "姿勢直したかな？";
        alert.message = notification.alertBody;
        alert.addButtonWithTitle(notification.alertAction!);
        alert.show();
        
    }
    
    
 /*   func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        var alert = UIAlertView();
        alert.title = "非アクティブなのに受け取りました";
        alert.message = notification.alertBody;
        alert.addButtonWithTitle(notification.alertAction!);
        alert.show();
    }*/

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

