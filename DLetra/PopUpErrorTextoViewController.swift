// 9/1/2018
//  DLetra App
//  Created by SEBASTIAN PADUANO (DUWAFARM) on 2018
//  Copyright © 2018 DUWAFARM. All rights reserved.

import UIKit

class PopUpErrorTextoController: UIViewController {
    
    @IBOutlet weak var uiView: UIImageView!
    @IBOutlet weak var lb_titulo: UILabel!
    @IBOutlet weak var btn_volverAtra: UILabel!
    @IBOutlet weak var btn_volverJugar: UILabel!
    var modoPerder = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        resizeTextos()
        ponerImagenFondo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        lb_titulo.text = modoPerder
    }
    
    private func resizeTextos(){
        let fontSize = Constantes.screenSize(screenSize: self.view.frame.size.width)
        lb_titulo.font = UIFont(descriptor: lb_titulo.font.fontDescriptor, size: fontSize)
        btn_volverAtra.font = UIFont(descriptor:  (btn_volverAtra.font.fontDescriptor), size: fontSize)
        btn_volverJugar.font = UIFont(descriptor:  (btn_volverAtra.font.fontDescriptor), size: fontSize)
    }

    private func ponerImagenFondo(){
        uiView.layer.cornerRadius = 8.0
        uiView.clipsToBounds = true
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }

    @IBAction func btn_menuVolver(_ sender: Any) {
        self.view.removeFromSuperview()
    }
   
    @IBAction func volverAJugar(_ sender: Any) {
        self.view.removeFromSuperview()
    }
}
