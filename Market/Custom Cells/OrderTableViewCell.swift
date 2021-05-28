//
//  OrderTableViewCell.swift
//  Market
//
//  Created by Conor Andrews on 26/04/2021.
//

import UIKit

class OrderTableViewCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func generateCell(_ order: Order) {
        
        orderNumberLabel.text = order.orderNumber
        dateLabel.text = order.date
        totalPriceLabel.text = convertToCurrency(order.totalPrice)
        totalPriceLabel.adjustsFontSizeToFitWidth = true
    }
}
