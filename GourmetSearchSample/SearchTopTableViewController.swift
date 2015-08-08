//
//  SearchTopTableViewController.swift
//  GourmetSearchSample
//
//  Created by Yusuke Aono on 8/8/15.
//  Copyright (c) 2015 Yusuke Aono. All rights reserved.
//

import UIKit

class SearchTopTableViewController: UITableViewController, UITextFieldDelegate {
    var freeword: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view delegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("Freeword", forIndexPath: indexPath) as! FreewordTableViewCell
            freeword = cell.freeword
            cell.freeword.delegate = self
            cell.selectionStyle = .None
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - Text field delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        performSegueWithIdentifier("PushShopList", sender: self)
        return true
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushShopList" {
            let vc = segue.destinationViewController as! ShopListViewController
            vc.yls.condition.query = freeword?.text
        }
    }
    
    @IBAction func onTap(sender: UITapGestureRecognizer) {
        freeword?.resignFirstResponder()
    }

}
