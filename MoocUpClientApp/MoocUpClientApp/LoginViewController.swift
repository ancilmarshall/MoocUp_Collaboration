//
//  ViewController.swift
//  MoocUpClientApp
//
//  Created by Ancil on 7/24/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIPageViewControllerDataSource {
    
    //declare of PageViewController and array of images
    private var pageViewController:UIPageViewController?
    private let contentImages = ["image_launch_1242x2208_1","image_launch_1242x2208_2","image_launch_1242x2208_3"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createPageViewController()
        self.setupPageControl()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIPageViewController - init and custom pageViewController
    func createPageViewController() {
        let pageViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LoginPageViewController") as UIPageViewController
        pageViewController.dataSource = self
        
        var startVC = self.pageLoginContentAtIndex(0) as LoginContentViewController
        var vc = NSArray(object: startVC)
        
        pageViewController.setViewControllers(vc, direction: .Forward, animated: true, completion: nil)
        
        //        pageViewController.view.frame = CGRectMake(0,0, self.view.frame.width, self.view.frame.size.height-60)
        pageViewController.view.frame = CGRectMake(0,0, self.view.frame.width, self.view.frame.size.height)
        
        
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        //self.view.sendSubviewToBack(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
        
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

