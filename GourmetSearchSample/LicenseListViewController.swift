//
//  LicenseListViewController.swift
//  GourmetSearchSample
//
//  Created by Yusuke Aono on 8/10/15.
//  Copyright (c) 2015 Yusuke Aono. All rights reserved.
//

import UIKit

class LicenseListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    private struct Software {
        var name: String
        var license: String
    }
    
    private var softwares = [Software]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let mainBundle = NSBundle.mainBundle()
        if let path = mainBundle.pathForResource("Licenses", ofType: "plist") {
            if let items = NSArray(contentsOfFile: path) {
                for item in items {
                    let name = item["Name"] as? String
                    let license = item["License"] as? String
                    if name == nil || license == nil { return }
                    softwares.append(Software(name: name!, license: license!))
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableView delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("PushLicenseDetail", sender: indexPath)
    }
    
    // MARK: UITableView data source
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Software") as! UITableViewCell
        cell.textLabel?.text = softwares[indexPath.row].name
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return softwares.count
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushLicenseDetail" {
            let vc = segue.destinationViewController as! LicenseDetailViewController
            if let indexPath = sender as? NSIndexPath {
                vc.name = softwares[indexPath.row].name
                vc.license = softwares[indexPath.row].license
            }
        }
    }

}
