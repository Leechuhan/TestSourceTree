//
//  TicketInfoTableViewCell.swift
//  ScanTicket
//
//  Created by Louis on 2019/4/2.
//  Copyright © 2019 louis. All rights reserved.
//

import UIKit

class TicketInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var num: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var checkImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
