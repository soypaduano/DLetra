// 9/1/2018
//  DLetra App
//  Created by SEBASTIAN PADUANO (DUWAFARM) on 2018
//  Copyright © 2018 DUWAFARM. All rights reserved.

import UIKit
@available(iOS 8.0, *)

class PopUpVozTexto: UIViewController {

    @IBOutlet weak var tv_popUp: UITextView!
    @IBOutlet weak var btn_cancelar: UIButton!
    @IBOutlet weak var btn_continuar: UIButton!
    @IBOutlet weak var lb_modo: UILabel!
    @IBOutlet weak var img_fondo: UITextView!
    @IBOutlet weak var viewPopUp: UIView!
    
    var modoJuego = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ajustarLetras()
        self.viewPopUp = Constantes.FondosBordesView(_view: viewPopUp)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(modoJuego){
            tv_popUp.text = " - Asegurese de subir el volumen del dispositivo todo lo posible. \n\n- A la hora de jugar pulse el microfono para activar el reconocimiento de voz y decir la respuesta. \n\n- Si desea pasar a la siguiente pregunta sin contestar, pulse el botón de respuesta y diga siguiente."
             lb_modo.text = "MODO VOZ"
        } else {
            tv_popUp.text = "- Para este modo no se requiere tener el sonido activado.  \n\n- Perfecto para cuando no quieres hacer ruido. \n\n- A la hora de jugar simplemente pulse el botón de la respuesta que considere correcta. \n\n- Si quiere pasar a la siguiente pregunta pulse el botón que indica siguiente."
             lb_modo.text = "MODO TÁCTIL"
        }
    }
    
    private func ajustarLetras(){
        let fontSize = Constantes.screenSize(screenSize: self.view.frame.size.width)
        lb_modo.font = UIFont(descriptor: lb_modo.font.fontDescriptor, size: fontSize)
        btn_cancelar.titleLabel?.font = UIFont(descriptor:  (btn_cancelar.titleLabel?.font.fontDescriptor)!, size: fontSize)
        btn_continuar.titleLabel?.font = UIFont(descriptor:  (btn_cancelar.titleLabel?.font.fontDescriptor)!, size: fontSize)
        tv_popUp.font = UIFont(descriptor: (tv_popUp.font?.fontDescriptor)!, size: fontSize)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let menuPrincipal = segue.destination as! MenuViewController
            menuPrincipal.modoDeJuego = modoJuego
    }
    
     @IBAction func unwindBackMenuPrincipal(_ sender: UIStoryboardSegue){
        self.view.removeFromSuperview()
    }
   
    @IBAction func btn_cancelar(_ sender: Any) {
        self.view.removeFromSuperview()
    }
}
