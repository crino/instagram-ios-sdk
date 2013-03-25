#
# IGViewController.rb
# InstagramClient
#
# Created by Devon Blandin on 03/25/13
# http://hello.devonblandin.com
#

class IGViewController < UIViewController

  def viewDidLoad
    super

    self.view.backgroundColor = UIColor.whiteColor

    login_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    login_button.setTitle('Login', forState: UIControlStateNormal)
    login_button.sizeToFit
    login_button.center = CGPointMake(160, 200)
    login_button.addTarget(self, action: 'login', forControlEvents: UIControlEventTouchUpInside)

    self.view.addSubview(login_button)

    App.delegate.instagram.accessToken = NSUserDefaults.standardUserDefaults['accessToken']
    App.delegate.instagram.sessionDelegate = self

    if App.delegate.instagram.isSessionValid
      view_controller = IGListViewController.alloc.init
      self.navigationController.pushViewController(view_controller, animated: true)
    else
      App.delegate.instagram.authorize(['comments', 'likes'])
    end
  end

  def viewDidUnload
    super
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown
  end

  def login
    App.delegate.instagram.authorize(['comments', 'likes'])
  end

  def igDidLogin
    NSUserDefaults.standardUserDefaults['accessToken'] = App.delegate.instagram.accessToken
    NSUserDefaults.standardUserDefaults.synchronize

    view_controller = IGListViewController.alloc.init
    self.navigationController.pushViewController(view_controller, animated: true)
  end

  def igDidNotLogin(cancelled)
    NSLog('Instagram did not login')

    message = cancelled ? 'Access cancelled!' : 'Access denied!'
    alert_view = UIAlertView.alloc.initWithTitle('Error',
                                                 message: message,
                                                delegate: nil,
                                       cancelButtonTitle: 'Ok',
                                       otherButtonTitles: nil)
    alert_view.show
  end

  def igDidLogout
    NSLog('Instagram did logout')

    NSUserDefaults.standardUserDefaults['accessToken'] = nil
    NSUserDefaults.standardUserDefaults.synchronize
  end

  def igSessionInvalidated
    NSLog('Instagram session was invalidated')
  end
end
