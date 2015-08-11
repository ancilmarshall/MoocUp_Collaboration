
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        let tabBarController = self.window!.rootViewController as! UITabBarController
        
        // Set split view controller properties for Courses
        let coursesSplitViewController = tabBarController.viewControllers?.first as! UISplitViewController
        let coursesNavigationController = coursesSplitViewController.viewControllers.last as! UINavigationController
        coursesNavigationController.topViewController.navigationItem.leftBarButtonItem = coursesSplitViewController.displayModeButtonItem()
        coursesSplitViewController.delegate = self
        coursesSplitViewController.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible

        // Set split view controller properties for Contacts & Messages
        let messagesSplitViewController = tabBarController.viewControllers?.last as! UISplitViewController
        let messagesNavigationController = messagesSplitViewController.viewControllers.last as! UINavigationController
        messagesNavigationController.topViewController.navigationItem.leftBarButtonItem = messagesSplitViewController.displayModeButtonItem()
        messagesSplitViewController.delegate = self
        messagesSplitViewController.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible

        // Set tab bar controller's name and image for Courses
        coursesSplitViewController.tabBarItem.title = "Courses"
        coursesSplitViewController.tabBarItem.image = UIImage(named: "first")

        // Set tab bar controller's name and image for Courses
        messagesSplitViewController.tabBarItem.title = "Contacts"
        messagesSplitViewController.tabBarItem.image = UIImage(named: "second")

        // Set tab bar controller's name and image for Map
        let mapNavigationController = tabBarController.viewControllers?[1] as! UINavigationController
        mapNavigationController.tabBarItem.title = "Map"
        mapNavigationController.tabBarItem.image = UIImage(named: "second")

        return true
    }

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
    
    // MARK: - Split view
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController!, ontoPrimaryViewController primaryViewController:UIViewController!) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let topAsDetailController = secondaryAsNavController.topViewController as? CourseTableViewController {
                if topAsDetailController.course == nil {
                    return true
                }
            }
            if let topAsDetailController = secondaryAsNavController.topViewController as? MessagesTableViewController {
                if topAsDetailController.contact == nil {
                    return true
                }
            }
        }
        return false
    }

}
