//
//  ViewController.swift
//  MoocUpClientApp
//
//  Created by Ancil on 7/24/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UIPageViewControllerDataSource{
    
    //View
    @IBOutlet weak var loginView: UIView!
    
    //Widgets
    @IBOutlet weak var loginLogo: UIImageView!
    
    @IBAction func loginButton(sender: UIButton) {
        //unwrap optional textButton
        let textButton = sender.currentTitle!
        println("TextButton : \(textButton)")
        
        switch textButton {
            case "Skip": toTheMooc()
            
            //TODO modal form with sign out, already ahve accound, etc
            case "Sign Up" : println("TextButton : \(textButton)")
            
            case "with Facebook" : facebooking()
            //TODO with Twitter sdk
            case "with Twitter" : println("TextButton : \(textButton)")
            
            default : break
        }
    }
    
    //declare of PageViewController and array of images
    private var pageViewController:UIPageViewController?
    private let contentImages = ["image_launch_1242x2208_1","image_launch_1242x2208_2","image_launch_1242x2208_3"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createPageViewController()
        self.setupPageControl()
        self.displayLoginElement()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//MARK: - LoginCustomView
    
    func displayLoginElement() {
        
        // Add subViews
        let arrayOfSubViews = [loginLogo, loginView] as [UIView]
        for subView in arrayOfSubViews {
            self.view.addSubview(subView)
        }
        
    }
    
// MARK: - Button React
    // Skip
    private func toTheMooc() {
        //Declare the MoocupViewcontroller as rootViewController of app if skip login screen
//        let moocupView: MoocupViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MoocupViewController") as! MoocupViewController
        let moocupView: MoocupViewController = self.storyboard?.instantiateViewControllerWithIdentifier("toTheMooc") as! MoocupViewController
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appdelegate.window!.rootViewController = moocupView
    }
    
    // FaceBook Login
    private func facebooking() {
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "email"],
            block: { (user:PFUser?,error:NSError?) -> Void in
                if (error != nil) {
                    // message
                    var myAlert = UIAlertController (title:"Facebook Alert", message:error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    let alertFacebook = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                    
                    myAlert.addAction(alertFacebook)
                    self.presentViewController(myAlert, animated: true, completion: nil)
                    println("Not logged")
                    
                    return
                    
                } else if (FBSDKAccessToken.currentAccessToken() != nil) {
                    println(user)
                    println("User Token:\(FBSDKAccessToken.currentAccessToken().userID)")
                    // to the mooc App
                    self.toTheMooc()
                    
                }
        })
    }
    
    
// MARK: - UIPageViewController - init and custom pageViewController
    func createPageViewController() {
        self.pageViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LoginPageViewController") as? UIPageViewController
        
        
        var startVC = self.pageLoginContentAtIndex(0) as LoginContentViewController
        var vc = NSArray(object: startVC)
        
        self.pageViewController!.setViewControllers(vc as [AnyObject], direction: .Forward, animated: true, completion: nil)
        self.pageViewController!.dataSource = self
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        
        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        var pageViewRect = self.view.bounds
        
// FIXME: Remvoved by Ancil since this was causing an issue on the iPad in the Simulator
//        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
//            pageViewRect = CGRectInset(pageViewRect, self.view.frame.width, self.view.frame.size.height)
//        }
        self.pageViewController!.view.frame = pageViewRect
        self.pageViewController!.didMoveToParentViewController(self)
        
        
        // Add the page view controller's gesture recognizers
        self.view.gestureRecognizers = self.pageViewController!.gestureRecognizers
        
        
    }
    
    func setupPageControl() {
        //Custom appearance of pageControl
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.blackColor()
        pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
    }
    
    // MARK: - UIPageViewController - method for pageViewController
    func pageLoginContentAtIndex(index: Int) -> LoginContentViewController {
        if (( self.contentImages.count == 0) || (index >= self.contentImages.count )) {
            return LoginContentViewController()
        }else {
            var vc: LoginContentViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LoginContentViewController") as! LoginContentViewController
            vc.imageFileName = self.contentImages[index]
            // TODO text tutoriel
            // vc.textLabel
            vc.pageIndex = index
            
            return vc
        }
        
        
    }
    
    // MARK: - UIPageViewController - method for protocol pageViewController Data Source
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var vc = viewController as! LoginContentViewController
        var index = vc.pageIndex as Int
        
        if(index == 0 || index == NSNotFound){
            return nil
        }
        
        index--
        return self.pageLoginContentAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var vc = viewController as! LoginContentViewController
        var index = vc.pageIndex as Int
        
        if(index == NSNotFound){
            return nil
        }
        
        index++
        
        if (index == self.contentImages.count){
            return nil
        }
        
        return self.pageLoginContentAtIndex(index)
        
    }
    
    // - A page indicator
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return contentImages.count
    }
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int  {
        return 0
    }



}

