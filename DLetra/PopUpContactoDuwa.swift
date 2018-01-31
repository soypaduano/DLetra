// 9/1/2018
//  DLetra App
//  Created by SEBASTIAN PADUANO (DUWAFARM) on 2018
//  Copyright © 2018 DUWAFARM. All rights reserved.

import UIKit
import MessageUI

class PopUpContactoDuwa: UIViewController, MFMailComposeViewControllerDelegate  {
    
    @IBOutlet weak var tv_info: UITextView!
    @IBOutlet weak var btn_aceptar: UIButton!
    @IBOutlet weak var view_info: UIView!
    @IBOutlet weak var btn_contactar: UIButton!
    @IBOutlet weak var img_fondo: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        AjustarLetras()
        self.view_info = Constantes.FondosBordesView(_view: view_info)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    private func AjustarLetras(){
        tv_info.text = "Esta aplicación ha sido desarrollada por el equipo de DUWAFARM. Si detectas alguna anomalia reportada en la siguiente dirección de correo electornico: \n\n support@duwafarm.com\n Gracias por tu ayuda."
        let fontSize = Constantes.screenSize(screenSize: self.view.frame.size.width)
        btn_contactar.titleLabel?.font = UIFont(descriptor:  (btn_contactar.titleLabel?.font.fontDescriptor)!, size: fontSize)
        btn_aceptar.titleLabel?.font = UIFont(descriptor:  (btn_contactar.titleLabel?.font.fontDescriptor)!, size: fontSize)
        tv_info.font = UIFont(descriptor: (tv_info.font?.fontDescriptor)!, size: fontSize)
    }

    @IBAction func btn_aceptar(_ sender: Any) {
       self.view.removeFromSuperview()
    }
    
    @IBAction func btn_contactar(_ sender: Any) {
       var mail = true
        if !MFMailComposeViewController.canSendMail() {
            mail = false //Mail services are not avaible.
            return
        } else {
            if mail{
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                let email = "support@duwafarm.com"
                composeVC.setToRecipients([email])
                composeVC.setSubject("Titulo")
                composeVC.setMessageBody("Escribe aqui tu mensaje!", isHTML: false)
                self.present(composeVC, animated: true, completion: nil)
            }
        }
    }
}
