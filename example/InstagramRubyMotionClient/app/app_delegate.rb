#
# AppDelegate.rb
# InstagramClient
#
# Created by Devon Blandin on 03/25/13
# http://hello.devonblandin.com
#

class AppDelegate
  attr_reader :instagram

  def self.client_id
    'ba45b28552e640ab91e5f5e5514883be'
  end

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    @instagram = Instagram.alloc.initWithClientId(AppDelegate.client_id, delegate: nil)

    viewController = IGViewController.alloc.init
    navController = UINavigationController.alloc.initWithRootViewController(viewController)

    @window.rootViewController = navController
    @window.makeKeyAndVisible
    true
  end

  def application(application, handleOpenURL: url)
    instagram.handleOpenURL(url)
  end

  def application(application, handleOpenURL: url, sourceApplication: sourceApplication, annotation: annotation)
    instagram.handleOpenURL(url)
  end

  def applicationWillResignActive(application)
  end

  def applicationDidEnterBackground(application)
  end

  def applicationWillEnterForeground(application)
  end

  def applicationDidBecomeActive(application)
  end

  def applicationWillTerminate(application)
  end
end
