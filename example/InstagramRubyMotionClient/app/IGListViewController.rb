#
# IGListViewController.rb
# InstagramClient
#
# Created by Devon Blandin on 03/25/13
# http://hello.devonblandin.com
#

class IGListViewController < UITableViewController
  attr_accessor :data

  def viewDidLoad
    super

    self.data = []

    self.view.backgroundColor = UIColor.whiteColor
    self.title = 'Followers'

    logout_button = UIBarButtonItem.alloc.initWithTitle('Logout',
                                                           style: UIBarButtonItemStyleBordered,
                                                          target: self,
                                                          action: 'logout')

    self.navigationItem.leftBarButtonItem = logout_button

    params = { 'method' => 'users/self/followed-by' }
    App.delegate.instagram.requestWithParams(params, delegate: self)
  end

  def viewDidUnload
    super
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection: section)
    self.data.count
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell_identifier = 'Cell'

    cell = tableView.dequeueReusableCellWithIdentifier(cell_identifier)
    unless cell
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier: cell_identifier)
    end

    cell.textLabel.text = self.data[indexPath.row]['username']
    cell.detailTextLabel.text = self.data[indexPath.row]['full_name']
    cell
  end

  def logout
    App.delegate.instagram.logout

    self.navigationController.popViewControllerAnimated(true)
  end

  def request(request, didFailWithError: error)
    NSLog("Instagram did fail: #{error}")

    alert_view = UIAlertView.alloc.initWithTitle('Error',
                                                 message: error.localizedDescription,
                                                 delegate: nil,
                                                 cancelButtonTitle: 'Ok',
                                                 otherButtonTitles: nil)

    alert_view.show
  end

  def request(request, didLoad: result)
    NSLog("'Instagram did load: #{result}")

    self.data = result['data']

    self.tableView.reloadData
  end
end
