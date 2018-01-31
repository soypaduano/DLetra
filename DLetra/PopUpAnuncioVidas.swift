// 9/1/2018
//  DLetra App
//  Created by SEBASTIAN PADUANO (DUWAFARM) on 2018
//  Copyright © 2018 DUWAFARM. All rights reserved.

import UIKit

class PopUpAnuncioVidas: UIViewController {
    
    var vidas = String()
    var tiempo = String()
    var modoDeJuego = Bool()

    @IBOutlet weak var viewAnuncioVidas: UIView!
    @IBOutlet weak var lb_tiempoDisponible: UILabel!
    @IBOutlet weak var lb_tiempo: UILabel!
    @IBOutlet weak var lb_fallosPermitidos: UILabel!
    @IBOutlet weak var lb_fallos: UILabel!
    @IBOutlet weak var btn_aceptar: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewAnuncioVidas = Constantes.FondosBordesView(_view: viewAnuncioVidas)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        resizeTextos()
    }
    
    private func resizeTextos(){
        let fontSize = Constantes.screenSize(screenSize: self.view.frame.size.width)
        lb_tiempoDisponible.font = UIFont(descriptor: lb_tiempoDisponible.font.fontDescriptor, size: fontSize)
        lb_tiempo.font = UIFont(descriptor: lb_tiempoDisponible.font.fontDescriptor, size: fontSize)
        lb_fallosPermitidos.font = UIFont(descriptor: lb_tiempoDisponible.font.fontDescriptor, size: fontSize)
        lb_fallos.font = UIFont(descriptor: lb_tiempoDisponible.font.fontDescriptor, size: fontSize)
        btn_aceptar.titleLabel?.font = UIFont(descriptor:  (btn_aceptar.titleLabel?.font.fontDescriptor)!, size: fontSize)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        lb_fallos.text = vidas
        lb_tiempo.text = tiempo
    }
    
    @IBAction func btn_aceptar(_ sender: Any) {
    self.view.removeFromSuperview()
        if(modoDeJuego){
            self.performSegue(withIdentifier: "segueToVoz", sender: self)
        } else {
            self.performSegue(withIdentifier: "segueToTexto", sender: self)
        }
    }
}
