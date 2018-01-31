//
//  RankingTableViewCell.swift
//  PruebaRankingSebastian
//
//  Created by Desarrollo MAC on 28/3/17.
//  Copyright © 2017 Desarrollo MAC. All rights reserved.
//

import UIKit

class RankingTableViewCell: UITableViewCell {

    @IBOutlet weak var lb_nombre: UILabel!
    
    @IBOutlet weak var lb_tiempo: UILabel!
    
    
    @IBOutlet weak var lb_aciertos: UILabel!
    
    
    @IBOutlet weak var image_forma: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
