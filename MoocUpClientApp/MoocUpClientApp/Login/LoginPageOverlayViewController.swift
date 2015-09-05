//
//  LoginPageOverlayViewController.swift
//  MoocUpClientApp
//
//  Created by horla on 14/08/2015.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

import UIKit

class LoginPageOverlayViewController: UIPageViewController {

    //Fix default layout of PageControl at the bottom
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var subViews: NSArray = view.subviews
        var scrollView: UIScrollView? = nil
        var pageControl: UIPageControl? = nil
        
        for view in subViews {
            // Constants
            let xmargin: CGFloat = self.view.frame.size.width/2
            let ymargin: CGFloat = self.view.frame.size.height/1.50
            
            if view.isKindOfClass(UIScrollView) {
                scrollView = view as? UIScrollView
            }
            else if view.isKindOfClass(UIPageControl) {
                pageControl = view as? UIPageControl
                
                pageControl?.frame = CGRectMake(xmargin,ymargin, 0, 0)
                // to do autolayout for pageControl
                
                
                
                
            }
        }
        
        if (scrollView != nil && pageControl != nil) {
            scrollView?.frame = view.bounds
            view.bringSubviewToFront(pageControl!)
        }
    }

}
