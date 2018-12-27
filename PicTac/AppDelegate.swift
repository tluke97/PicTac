//
//  AppDelegate.swift
//  corkboard
//
//  Created by Tanner Luke on 5/15/18.
//  Copyright © 2018 Tanner Luke. All rights reserved.
//

import UIKit
import Parse
import KILabel
import AVFoundation
import UserNotifications

var theUserId: String = ""
var theData: Data?
var runTheData: Bool = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        
        let parseConfig = ParseClientConfiguration { (ParseMutableClientConfiguration) in
            
            
//            ParseMutableClientConfiguration.applicationId = "F44aLYmY2TuGO9T7gvQkXCbDWaDSh9O3SYuJHplY"
//            ParseMutableClientConfiguration.clientKey = "tpPj0HPAwNB4xWXQRWYt35phof02b6I9cImLcMGH"
//            ParseMutableClientConfiguration.server = "https://parseapi.back4app.com/"
            
            ParseMutableClientConfiguration.applicationId = "ZxUlSDGaX9BHX54BEtJ9ArPAERoqnvFsIlj0pdWu"
            ParseMutableClientConfiguration.clientKey = "XMhdHVOq5BvY3CGf3w2mgphWPKpqjCMQYdR5PCRj"
            ParseMutableClientConfiguration.server = "https://parseapi.back4app.com/"
            
            
            
            
        }
        
        Parse.initialize(with: parseConfig)
        
        
        
        //SASHIDO
        
//        let configuration = ParseClientConfiguration {
//            $0.applicationId = "kfMp5obxmSgTdAoh4wi6nAKVO5mNPqYiga658Lhf"
//            $0.clientKey = "hoZy7pMzpyPmRkHFS66hbCPh5l85qLPYQmfa7iog"
//            $0.server = "https://pg-app-jwkx3bigf8me0yydphycyq6ghgxucc.scalabl.cloud/1/"
//
//
//           // $0.applicationId = "a7a45581-121d-46cd-92d6-578d67b7c4f4"
//           // $0.clientKey = "fdcx2qHOVR2Xp0ODudVyQF1RsM0C5tqe"
//           // $0.server = "https://api.parse.buddy.com/parse/"
//        }
//        Parse.initialize(with: configuration)
//
       
        login()
        
        // Override point for customization after application launch.
        /*
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: [AVAudioSessionCategoryOptions.duckOthers,AVAudioSessionCategoryOptions.defaultToSpeaker])
        } catch {
            print(error)
        }
        */
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .carPlay ]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self.getNotificationSettings()
        }
        
        
        
        return true
    }
    
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async(execute: {
                UIApplication.shared.registerForRemoteNotifications()
            })
            
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        runTheData = true
        theData = deviceToken
        //createInstallationOnParse(deviceTokenData: deviceToken)
    }
   
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        runTheData = false
        print("Failed to register: \(error)")
    }
    
    
    func allowBackgroundAudio()
    {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
        } catch {
            NSLog("AVAudioSession SetCategory - Playback:MixWithOthers failed")
        }
    }
    
    func preventBackgroundAudio()
    {
        do {
            //Ask for Solo Ambient to prevent any background audio playing, then change to normal Playback so we can play while locked
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            NSLog("AVAudioSession SetCategory - SoloAmbient failed")
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        if oldBrightness != nil {
        
            UIScreen.main.brightness = oldBrightness!
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func login() {
        let username: String? = UserDefaults.standard.string(forKey: "username")
        
        if username != nil {
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let theTabBar = storyboard.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
            window?.rootViewController = theTabBar
            
            
        }
        
    }
    
    
}
