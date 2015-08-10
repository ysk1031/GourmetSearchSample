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
        
        if !(self.navigationController is FavoriteNavigationController) {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadDataObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            yls.YLSLoadCompleteNotification,
            object: nil,
            queue: nil,
            usingBlock: { (notification) in
                if self.yls.condition.gid != nil {
                    self.yls.sortByGid()
                }
                
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
            if self.navigationController is FavoriteNavigationController {
                loadFavorites()
                self.navigationItem.title = "お気に入り"
            } else {
                yls.loadData(reset: true)
                self.navigationItem.title = "店舗一覧"
            }
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
    func loadFavorites() {
        Favorite.load()
        if Favorite.favorites.count > 0 {
            var condition = QueryCondition()
            condition.gid = join(",", Favorite.favorites)
            yls.condition = condition
            yls.loadData(reset: true)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(yls.YLSLoadCompleteNotification, object: nil)
        }
    }
    
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
        if self.navigationController is FavoriteNavigationController {
            loadFavorites()
        } else {
            yls.loadData(reset: true)
        }
    }

    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("PushShopDetail", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.navigationController is FavoriteNavigationController
    }
    
    func tableView(tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            Favorite.remove(yls.shops[indexPath.row].gid)
            yls.shops.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.navigationController is FavoriteNavigationController
    }
    
    func tableView(tableView: UITableView,
        moveRowAtIndexPath sourceIndexPath: NSIndexPath,
        toIndexPath destinationIndexPath: NSIndexPath) {
    
        if sourceIndexPath == destinationIndexPath { return }
            
        let source = yls.shops[sourceIndexPath.row]
        yls.shops.removeAtIndex(sourceIndexPath.row)
        yls.shops.insert(source, atIndex: destinationIndexPath.row)
        Favorite.move(sourceIndexPath.row, destinationIndexPath.row)
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
    
    // MARK: - IBAction
    @IBAction func editButtonTapped(sender: UIBarButtonItem) {
        if tableView.editing {
            tableView.setEditing(false, animated: true)
            sender.title = "編集"
        } else {
            tableView.setEditing(true, animated: true)
            sender.title = "完了"
        }
    }

}

