// 9/1/2018
//  DLetra App
//  Created by SEBASTIAN PADUANO (DUWAFARM) on 2018
//  Copyright © 2018 DUWAFARM. All rights reserved.

import UIKit

class PopUpErrorVozController: UIViewController {
    
    @IBOutlet weak var uiView: UIView!
    @IBOutlet weak var lb_titulo: UILabel!
    @IBOutlet weak var btn_volverJugar: UILabel!
    @IBOutlet weak var btn_volverAtra: UILabel!
    var modoPerder = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resizeTextos()
        uiView = Constantes.FondosBordesView(_view: uiView)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    private func resizeTextos(){
        let fontSize = Constantes.screenSize(screenSize: self.view.frame.size.width)
        lb_titulo.font = UIFont(descriptor: lb_titulo.font.fontDescriptor, size: fontSize - 5)
        btn_volverAtra.font = UIFont(descriptor:  (btn_volverAtra.font.fontDescriptor), size: fontSize)
        btn_volverJugar.font = UIFont(descriptor:  (btn_volverAtra.font.fontDescriptor), size: fontSize)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        lb_titulo.text = modoPerder 
    }

    @IBAction func btn_menuVolver(_ sender: Any) {
        self.view.removeFromSuperview()
    }

    @IBAction func volverAJugar(_ sender: Any) {
        self.view.removeFromSuperview()
    }
}
