//
//  AppDelegate.swift
//  ProjectX
//
//  Created by amir lahav on 14.9.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import UIKit
import KeychainSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appFlow: AppFlowController?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        
        if let window = window
        {
            appFlow = AppFlowController(window: window)
        }
        
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: "firstTime") != nil else {
            
            AlbumMenagerHelper.createSystemAlbum()
            let password = String.random(length: 64)
            let keychain = KeychainSwift()
            keychain.set(password, forKey: "password")
            defaults.set(true, forKey: "firstTime")
            print("first time")
            
            return true
        }
        
        print("not first time")
        
        // Override point for customization after application launch.
        return true
    }



    
    final class AppFlowController: LoginProtocol
    {

        
        let tabBar: UITabBarController
        let gridNavigationBar: UINavigationController
        let albumNavigationBar: UINavigationController
        let newPhotoNavigationBar: UINavigationController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let photoGridVc: PhotoController
        let albumGridVc: AlbumVC
        let importPhotos: FetchAssetController
        let settingVC: SettingController
        var loginVC:LoginViewController?

        init(window: UIWindow) {
            
            tabBar = window.rootViewController as! UITabBarController
            photoGridVc = PhotoController(albumName: "Moments")
            importPhotos = FetchAssetController()
            settingVC = SettingController()

            albumGridVc = AlbumVC()
            gridNavigationBar = UINavigationController(rootViewController: photoGridVc)
            gridNavigationBar.view.backgroundColor = .white
            albumNavigationBar = UINavigationController(rootViewController: albumGridVc)
            newPhotoNavigationBar = UINavigationController()

            let galleryNavigationBar = UINavigationController(rootViewController: importPhotos)
            let settingNavigationBar = UINavigationController(rootViewController: settingVC)

            tabBar.setViewControllers([gridNavigationBar, settingNavigationBar,galleryNavigationBar,albumNavigationBar], animated: true)
            configeTabBar()
            configePhotoGridVC(vc: photoGridVc)
            configeAlbumGridVC(vc: albumGridVc)
            let theme = ThemeManager.currentTheme()
            ThemeManager.applayTheme(theme: theme)
       }
        
        
        func didDismiss() {
            print("dismiss blur")
            loginVC = nil
        }
        
        func hideContent()
        {
            if loginVC == nil{
                loginVC = LoginViewController()
                loginVC?.delegate = self
                loginVC?.modalPresentationStyle = .overCurrentContext
                tabBar.present(loginVC!, animated: false, completion: nil)
            }
        }
        
        
        func configeTabBar()
        {
            tabBar.tabBar.items?.first?.image = #imageLiteral(resourceName: "photo_63")
            tabBar.tabBar.items?.first?.title = "Photos"
            tabBar.tabBar.items?[1].image = #imageLiteral(resourceName: "icons8-more-63.png")
            tabBar.tabBar.items?[1].title = "More"
            tabBar.tabBar.items?[2].image = #imageLiteral(resourceName: "icons8-cloud-63.png")
            tabBar.tabBar.items?[2].title = "Import"
            tabBar.tabBar.items?[3].image = #imageLiteral(resourceName: "folder_54")
            tabBar.tabBar.items?[3].title = "Albums"
        }
        
        func configePhotoGridVC(vc: PhotoController)
        {
            vc.hideButtomTabBar = hideTabBar
            vc.didSelectPhoto = showPhoto
        }
        
        func configeAlbumGridVC(vc: AlbumVC)
        {
            vc.didSelectAlbum = showAlbum
        }
        
        func showPhoto(_ segueData:SegueData) {
            guard let albumName = segueData.albumName else { return }
            let detailVC = PhotoDetail(albumName: albumName)
            detailVC.dismissPhotoDetail = dismissPhoto
            detailVC.segueData = segueData
            hideTabBar(true)
            detailVC.hideNavigationBar = hideNavBar
            gridNavigationBar.pushViewController(detailVC, animated: true)
        }
        
        func showPhotoFromAlbum(_ segueData:SegueData) {
            
            guard let albumName = segueData.albumName else { return }
            let detailVC = PhotoDetail(albumName: albumName)
            detailVC.dismissPhotoDetail = dismissPhotoFromAlbum
            detailVC.segueData = segueData
            hideTabBar(true)
            detailVC.hideNavigationBar = hideNavBar
            albumNavigationBar.pushViewController(detailVC, animated: true)
            
        }
        
        func showAlbum(_ pushAlbumData:PushAlbumData)
        {
            let photoVC = PhotoController(albumName: pushAlbumData.albumName!)
            photoVC.pushAlbumData = pushAlbumData
            photoVC.hideButtomTabBar = hideTabBar
            photoVC.didSelectPhoto = showPhotoFromAlbum
            albumNavigationBar.pushViewController(photoVC, animated: true)
        }
        
        func dismissPhoto(_ segueData:DismissData){
            photoGridVc.selectedIndex = segueData.currentIndex
            hideTabBar(false)
            gridNavigationBar.popViewController(animated: true)
        }
        
        func dismissPhotoFromAlbum(_ segueData:DismissData){
            hideTabBar(false)
            albumNavigationBar.popViewController(animated: true)
        }
        
        func hideTabBar(_ hide:Bool)
        {
            tabBar.tabBar.isHidden = hide
        }
        
        func hideNavBar(_ hide:Bool, tabType:TabType)
        {
            var alpha:CGFloat = 1.0
            switch hide {
            case true: alpha = 0.0
            case false: alpha = 1.0
            }
            print("should hide: \(hide), alpha:\(alpha)")

            switch tabType {
                case .photoGrid: gridNavigationBar.navigationBar.isHidden = hide
                case .albumGrid: albumNavigationBar.navigationBar.isHidden = hide
            }
        }
    
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")

        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        appFlow?.hideContent()

        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
        appFlow?.loginVC?.authenticateUser()
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")

        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

final class Coordinator
{
    let gridNavigationBar: UINavigationController
    let grid:PhotoController
    
    
    
    init(NC:UINavigationController, pushData:PushAlbumData) {
        gridNavigationBar = NC
        grid = PhotoController(albumName: "Search")
        grid.didSelectPhoto = showPhotoFromAlbum
        grid.pushAlbumData = pushData
    }
    
    func show(){
        gridNavigationBar.pushViewController(grid, animated: true)
    }
    
    func showPhotoFromAlbum(_ segueData:SegueData) {
        guard let albumName = segueData.albumName else { return }
        let detailVC = PhotoDetail(albumName: albumName)
        detailVC.dismissPhotoDetail = dismissPhotoFromAlbum
        detailVC.segueData = segueData
        gridNavigationBar.pushViewController(detailVC, animated: true)
    }
    
    func dismissPhotoFromAlbum(_ segueData:DismissData){
        gridNavigationBar.popViewController(animated: true)
    }
}

