//
//  AboutDetailViewController.swift
//  GourmetSearchSample
//
//  Created by Yusuke Aono on 8/11/15.
//  Copyright (c) 2015 Yusuke Aono. All rights reserved.
//

import UIKit

class LicenseDetailViewController: UIViewController {
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var textHeight: NSLayoutConstraint!
    
    var name = ""
    var license = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        text.text = license
        title = name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        let frame = CGSizeMake(text.frame.size.width, CGFloat.max)
        textHeight.constant = text.sizeThatFits(frame).height
        view.layoutIfNeeded()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
