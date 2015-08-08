//
//  FreewordTableViewCell.swift
//  GourmetSearchSample
//
//  Created by Yusuke Aono on 8/8/15.
//  Copyright (c) 2015 Yusuke Aono. All rights reserved.
//

import UIKit

class FreewordTableViewCell: UITableViewCell {
    
    @IBOutlet weak var freeword: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
