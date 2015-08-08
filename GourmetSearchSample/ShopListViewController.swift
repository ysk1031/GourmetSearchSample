import UIKit

class ShopListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var yls: YahooLocalSearch = YahooLocalSearch()
    var loadDataObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var qc = QueryCondition()
        qc.query = "ハンバーガー"
        yls = YahooLocalSearch(condition: qc)
        
        loadDataObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            yls.YLSLoadCompleteNotification,
            object: nil,
            queue: nil,
            usingBlock: { (notification) in
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
        
        yls.loadData(reset: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self.loadDataObserver!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ShopListItem") as! ShopListItemTableViewCell
            cell.name.text = "\(indexPath.row)"
            return cell
        }
        return UITableViewCell()
    }

}

