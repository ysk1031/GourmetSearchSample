import UIKit

class ShopListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var yls: YahooLocalSearch = YahooLocalSearch()
    var loadDataObserver: NSObjectProtocol?
    var refreshObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh:", forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadDataObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            yls.YLSLoadCompleteNotification,
            object: nil,
            queue: nil,
            usingBlock: { (notification) in
                self.tableView.reloadData()
                
                if notification.userInfo != nil {
                    if let userInfo = notification.userInfo as? [String: String!] {
                        if userInfo["error"] != nil {
                            let alertView = UIAlertController(title: "通信エラー",
                                message: "通信エラーが発生しました",
                                preferredStyle: .Alert
                            )
                            alertView.addAction(
                                UIAlertAction(title: "OK", style: .Default) {
                                    action in return
                                }
                            )
                            self.presentViewController(alertView, animated: true, completion: nil)
                        }
                    }
                }
            }
        )
        
        if yls.shops.count == 0 {
            yls.loadData(reset: true)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self.loadDataObserver!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Application logic
    func onRefresh(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        refreshObserver = NSNotificationCenter.defaultCenter().addObserverForName(yls.YLSLoadCompleteNotification,
            object: nil,
            queue: nil,
            usingBlock: { notification in
                NSNotificationCenter.defaultCenter().removeObserver(self.refreshObserver!)
                refreshControl.endRefreshing()
            }
        )
        yls.loadData(reset: true)
    }

    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("PushShopDetail", sender: indexPath)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return yls.shops.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row < yls.shops.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("ShopListItem") as! ShopListItemTableViewCell
                cell.shop = yls.shops[indexPath.row]
                
                if yls.shops.count < yls.total {
                    if yls.shops.count - indexPath.row <= 4 {
                        yls.loadData()
                    }
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushShopDetail" {
            let vc = segue.destinationViewController as! ShopDetailViewController
            if let indexPath = sender as? NSIndexPath {
                vc.shop = yls.shops[indexPath.row]
            }
        }
    }

}

