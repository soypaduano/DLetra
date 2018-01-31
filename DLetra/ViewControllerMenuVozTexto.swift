// 9/1/2018
//  DLetra App
//  Created by SEBASTIAN PADUANO (DUWAFARM) on 2018
//  Copyright © 2018 DUWAFARM. All rights reserved.

import UIKit
@available(iOS 8.0, *)

class ViewControllerMenuVozTexto: UIViewController {

    @IBOutlet weak var btn_voz: UIButton!
    @IBOutlet weak var btn_texto: UIButton!
    @IBOutlet weak var lb_tactil: UILabel!
    @IBOutlet weak var lb_voz: UILabel!
    @IBOutlet weak var lb_modoJuego: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1.5, animations: {
            self.lb_tactil.alpha = 1.0
            self.lb_voz.alpha = 1.0
            self.btn_voz.alpha = 1.0
            self.btn_texto.alpha = 1.0
            self.lb_modoJuego.alpha = 1.0
        })
    }
    
    func llamarPopUp(modoJuego: Bool){
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpVozTexto") as! PopUpVozTexto
        self.addChildViewController(popOverVC)
        popOverVC.didMove(toParentViewController: self)
        popOverVC.modoJuego = modoJuego //Le mandamos el modo de juego elegido
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
    }
    
    @IBAction func btn_actionVoz(_ sender: Any) {
        if #available(iOS 10.0, *) {
            llamarPopUp(modoJuego: true) //Si es voz mandamos true.
        } else {
            var alerta: UIAlertController!
            alerta = UIAlertController(title: "", message: "Para jugar a este modo necesitas tener iOS 10.0 en adelante", preferredStyle:         UIAlertControllerStyle.alert)
            alerta.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alerta, animated: true, completion: nil)
        }
    }

    @IBAction func btn_actionTexto(_ sender: Any) {
            llamarPopUp(modoJuego: false)
    }

    @IBAction func unwindBackPopUpVoz(_ sender: UIStoryboardSegue){
    }
    
    @IBAction func unwindBackSpeechDenied(_ sender: UIStoryboardSegue){
        self.removeFromParentViewController()
    }
}
