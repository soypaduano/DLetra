//
//  TableViewCell.swift
//  PruebaRankingSebastian
//
//  Created by Desarrollo MAC on 28/3/17.
//  Copyright © 2017 Desarrollo MAC. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var lb_nombre: UILabel!
    @IBOutlet weak var lb_tiempo: UILabel!
    @IBOutlet weak var lb_aciertos: UILabel!
    @IBOutlet weak var image_forma: UIImageView!
    @IBOutlet weak var lb_posicion: UILabel!
    
    
    //Constrains
    @IBOutlet weak var lb_posCell_constain: NSLayoutConstraint!
    @IBOutlet weak var lb_nombreCell_constrain: NSLayoutConstraint!
    @IBOutlet weak var lb_tiempoCell_constrain: NSLayoutConstraint!
    @IBOutlet weak var lb_aciertosCell_constrain: NSLayoutConstraint!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
