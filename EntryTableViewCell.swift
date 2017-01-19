//
//  EntryTableViewCell.swift
//  TimeTrackerSwift
//
//  Created by Stefan Auvergne on 12/27/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import UIKit

class EntryTableViewCell: UITableViewCell {

    @IBOutlet weak var entryDurationOutlet: UILabel!
    @IBOutlet weak var numberOutlet: UILabel!
    @IBOutlet weak var projectNameOutlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
