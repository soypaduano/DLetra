//
//  PopUpTiempoVidas.swift
//  GeometricalApp
//
//  Created by Desarrollo MAC on 25/4/17.
//  Copyright © 2017 Desarrollo MAC. All rights reserved.
//

import UIKit

class PopUpTiempoVidas: UIViewController {
    
    var vidas = String()
    var tiempo = String()
    
    @IBOutlet weak var view_tiempoVidas: UIView!
    @IBOutlet weak var lb_vidas: UILabel!
    @IBOutlet weak var lb_tiempo: UILabel!
    @IBOutlet weak var lb_tiempoDisponible: UILabel!
    @IBOutlet weak var lb_fallosPermitidos: UILabel!
    @IBOutlet weak var btn_aceptar: UIButton!
    
    var fontSize = CGFloat()
    
    func resizeTextos(){
        lb_tiempoDisponible.font = UIFont(descriptor: lb_tiempoDisponible.font.fontDescriptor, size: fontSize)
        
        lb_tiempo.font = UIFont(descriptor: lb_tiempoDisponible.font.fontDescriptor, size: fontSize)
        
        lb_fallosPermitidos.font = UIFont(descriptor: lb_tiempoDisponible.font.fontDescriptor, size: fontSize)
        
        lb_vidas.font = UIFont(descriptor: lb_tiempoDisponible.font.fontDescriptor, size: fontSize)
        
          btn_aceptar.titleLabel?.font = UIFont(descriptor:  (btn_aceptar.titleLabel?.font.fontDescriptor)!, size: fontSize)

    }
    
    
    func screenSize(){
        let screenWidth = self.view.frame.size.width
        
        switch screenWidth {
        case 320: // iPhone 4 and iPhone 5
            fontSize = 17.0
        case 375: // iPhone 6 //Iphone7
            fontSize = 20.0
        case 414: // iPhone 6 Plus // Iphone7Plus
            fontSize = 24.0
        case 768: // iPad
            fontSize = 33.0
        case 1024:
            fontSize = 40.0
        default: // iPad Pro
            fontSize = 10.0
        }
    }
    

    override func viewDidLoad() {
        screenSize()
        resizeTextos()
        super.viewDidLoad()
        fondoYbordesView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func fondoYbordesView(){
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view_tiempoVidas.layer.cornerRadius = 8
        self.view_tiempoVidas.layer.shadowOpacity = 0.8
    }

    @IBAction func btn_aceptar(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        lb_vidas.text = vidas
        lb_tiempo.text = tiempo
    }
  

}
