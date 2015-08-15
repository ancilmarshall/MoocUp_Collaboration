//
//  ViewController.swift
//  MoocUpClientApp
//
//  Created by Ancil on 7/24/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIPageViewControllerDataSource{
    
    //View
    @IBOutlet weak var loginView: UIView!
    
    //Widegets
    @IBOutlet weak var loginLogo: UIImageView!
    @IBAction func loginButton(sender: UIButton) {
        let textButton = sender.currentTitle
        println("TextButton : \(textButton)")
        
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
        


        self.view.addSubview (loginLogo)
        self.view.addSubview (loginView)
        
        
        //blur test
        //        var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        //        var blurEffectView = UIVisualEffectView(effect: blurEffect)
        //        let container = CGRectMake(0,600, self.view.frame.width, self.view.frame.size.height/4)
        //        blurEffectView.frame = container
        //        //blurEffectView.frame = blurLogin.bounds
        //        self.view.addSubview(blurEffectView)
    }
    
    
    // MARK: - UIPageViewController - init and custom pageViewController
    func createPageViewController() {
        self.pageViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LoginPageViewController") as? UIPageViewController
        
        
        var startVC = self.pageLoginContentAtIndex(0) as LoginContentViewController
        var vc = NSArray(object: startVC)
        
        self.pageViewController!.setViewControllers(vc, direction: .Forward, animated: true, completion: nil)
        self.pageViewController!.dataSource = self
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        
        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        var pageViewRect = self.view.bounds
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            pageViewRect = CGRectInset(pageViewRect, self.view.frame.width, self.view.frame.size.height)
        }
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
            var vc: LoginContentViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LoginContentViewController") as LoginContentViewController
            vc.imageFileName = self.contentImages[index]
            // TODO text tutoriel
            // vc.textLabel
            vc.pageIndex = index
            
            return vc
        }
        
        
    }
    
    // MARK: - UIPageViewController - method for protocol pageViewController Data Source
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var vc = viewController as LoginContentViewController
        var index = vc.pageIndex as Int
        
        if(index == 0 || index == NSNotFound){
            return nil
        }
        
        index--
        return self.pageLoginContentAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var vc = viewController as LoginContentViewController
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

