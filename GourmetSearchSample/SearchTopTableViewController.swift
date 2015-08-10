import UIKit
import MapKit

class SearchTopTableViewController: UITableViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    var freeword: UITextField?
    
    let ls = LocationService()
    let nc = NSNotificationCenter.defaultCenter()
    var observers = [NSObjectProtocol]()
    var here: (lat: Double, lon: Double)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        observers.append(
            nc.addObserverForName(ls.LSAuthDeniedNotification,
                object: nil,
                queue: nil,
                usingBlock: {
                    notification in
                    // 位置情報がONになっていないダイアログ表示
                    self.presentViewController(self.ls.locationServiceDisabledAlert,
                        animated: true,
                        completion: nil)
            })
        )
        observers.append(
            nc.addObserverForName(ls.LSAuthRestrictedNotification,
                object: nil,
                queue: nil,
                usingBlock: {
                    notification in
                    // 位置情報が制限されているダイアログ表示
                    self.presentViewController(self.ls.locationServiceRestrictedAlert,
                        animated: true,
                        completion: nil)
            })
        )
        observers.append(
            nc.addObserverForName(ls.LSDidFailLocationNotification,
                object: nil,
                queue: nil,
                usingBlock: {
                    notification in
                    // 位置情報取得に失敗したダイアログ
                    self.presentViewController(self.ls.locationServiceDidFailAlert,
                        animated: true,
                        completion: nil)
            })
        )
        observers.append(
            nc.addObserverForName(ls.LSDidUpdateLocationNotification,
                object: nil,
                queue: nil,
                usingBlock: {
                    notification in
                    if let userInfo = notification.userInfo as? [String: CLLocation] {
                        if let clloc = userInfo["location"] {
                            self.here = (lat: clloc.coordinate.latitude, 
                                lon: clloc.coordinate.longitude)
                            self.performSegueWithIdentifier("PushShopListFromHere", 
                                sender: self)
                        }
                    }
            })
        )
    }
    
    override func viewWillDisappear(animated: Bool) {
        for observer in observers {
            nc.removeObserver(observer)
        }
        observers = []
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view delegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 1 {
            ls.startUpdatingLocation()
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("Freeword", forIndexPath: indexPath) as! FreewordTableViewCell
                freeword = cell.freeword
                cell.freeword.delegate = self
                cell.selectionStyle = .None
                return cell
            case 1:
                let cell = UITableViewCell()
                cell.textLabel?.text = "現在地から検索"
                cell.accessoryType = .DisclosureIndicator
                return cell
            default:
                return UITableViewCell()
            }
        }
        return UITableViewCell()
    }
    
    // MARK: - Text field delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        performSegueWithIdentifier("PushShopList", sender: self)
        return true
    }
    
    // MARK: - UIGestureRecognizer delegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let ifr = freeword?.isFirstResponder() {
            return ifr
        }
        return false
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushShopList" {
            let vc = segue.destinationViewController as! ShopListViewController
            vc.yls.condition.query = freeword?.text
        }
        if segue.identifier == "PushShopListFromHere" {
            let vc = segue.destinationViewController as! ShopListViewController
            vc.yls.condition.lat = self.here?.lat
            vc.yls.condition.lon = self.here?.lon
        }
    }
    
    @IBAction func onTap(sender: UITapGestureRecognizer) {
        freeword?.resignFirstResponder()
    }

}
