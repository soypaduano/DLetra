// 9/1/2018
//  DLetra App
//  Created by SEBASTIAN PADUANO (DUWAFARM) on 2018
//  Copyright © 2018 DUWAFARM. All rights reserved.

import UIKit
import CoreData
import AVFoundation
import AVKit

class PopUpViewController: UIViewController {
    
    @IBOutlet weak var heightView: NSLayoutConstraint! //Manejar el pop up cuando aparece el teclado.
    @IBOutlet weak var uiView: UIView!
    @IBOutlet weak var lb_aciertos: UILabel!
    @IBOutlet weak var lb_tiempo: UILabel!
    @IBOutlet weak var tv_mensaje: UITextView!
    @IBOutlet weak var tf_nombreIntroducido: UITextField!
    @IBOutlet weak var btn_guardar: UIButton!
    
    var managedObjectContext:NSManagedObjectContext! //Upload to CoreData.
    var efectoSonido: AVAudioPlayer? //Variable para la voz y los sonidos
    var formaHecha = String() //Nivel en el que estamos jugando
    var modoDeJuego = Bool() //Modo de juego en el que estamos jugando
    var tiempoEmpleado = 0
    var aciertos = 0
    var puntosIntroducidos = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(PopUpViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PopUpViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        resizeTextos()
        if(UserDefaults.standard.bool(forKey: "sound")){
            reproducirSonido(url: "resultado.wav") //Reproducimos el sonido
        }
        uiView = Constantes.FondosBordesView(_view: uiView)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext  //Creamos objeto
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PopUpViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    private func resizeTextos(){
        let fontSize = Constantes.screenSize(screenSize: self.view.frame.size.width)
        lb_tiempo.font = UIFont(descriptor: lb_tiempo.font.fontDescriptor, size: fontSize + 3)
        lb_aciertos.font = UIFont(descriptor: lb_tiempo.font.fontDescriptor, size: fontSize + 3)
        tv_mensaje.font = UIFont(descriptor: (tv_mensaje.font?.fontDescriptor)!, size: fontSize - 2)
        tf_nombreIntroducido.font = UIFont(name: (tf_nombreIntroducido.font?.fontName)!, size: fontSize)
        btn_guardar.titleLabel?.font = UIFont(descriptor:  (btn_guardar.titleLabel?.font.fontDescriptor)!, size: fontSize)
    }
    
    func keyboardWillShow(notification: NSNotification){
       heightView =  heightView.setMultiplier(multiplier: 0.5)
    }
    
    func keyboardWillHide(notification: NSNotification){
        heightView =  heightView.setMultiplier(multiplier: 1.0)
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func reproducirSonido(url: String){
        let path = Bundle.main.path(forResource: url, ofType:nil)!
        let url = URL(fileURLWithPath: path)
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            efectoSonido = sound
            sound.volume = 0.2
            sound.play()
        } catch {
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        lb_aciertos.text = String(aciertos)
        lb_tiempo.text = String(tiempoEmpleado)
    }
    
    private func subirADataBase(){
        if(modoDeJuego){
                let partidaItemDescription = NSEntityDescription.entity(forEntityName: "PartidaCuadrado", in: managedObjectContext)
                let partidaVozItem = PartidaCuadrado.init(entity: partidaItemDescription!, insertInto: managedObjectContext)
                partidaVozItem.nombre = tf_nombreIntroducido.text?.trimmingCharacters(in: .whitespaces)
                partidaVozItem.aciertos = String(aciertos)
                partidaVozItem.tiempo = String(tiempoEmpleado)
                partidaVozItem.nivel = formaHecha
                let aciertosTra = Int(partidaVozItem.aciertos!)
                let tiempoTra = Int(partidaVozItem.tiempo!)
                partidaVozItem.puntos = Double(aciertosTra! * 20 + ( 180 - tiempoTra!))
                puntosIntroducidos = Double(aciertosTra! * 20 + tiempoTra!)
            
            for index in 0...Constantes.arrayFigurasNiveles.count - 1{
                if(Constantes.arrayFigurasNiveles[index] == formaHecha && formaHecha != "RECTANGULO"){ //Comprobamos que está en el nivel que acaba de juga
                    if(UserDefaults.standard.bool(forKey: Constantes.arrayFigurasNiveles[index + 1] + "VozBloqueado") == true){ //Comprobamos que el nivel siguiente esta bloqueado
                         UserDefaults.standard.set(false, forKey: Constantes.arrayFigurasNiveles[index + 1] + "VozBloqueado")  //Le desbloqueamos el siguiente nivel.
                    }
                }
            }
            
            do{
                try self.managedObjectContext.save()
            } catch{
            }
            
        } else {    //SI ES MODO TEXTO...
            let partidaItemDescription = NSEntityDescription.entity(forEntityName: "PartidaCuadradoTexto", in: managedObjectContext)
            let partidaTextoItem = PartidaCuadradoTexto.init(entity: partidaItemDescription!, insertInto: managedObjectContext)
            partidaTextoItem.nombre = tf_nombreIntroducido.text?.trimmingCharacters(in: .whitespaces)
            partidaTextoItem.aciertos = String(aciertos)
            partidaTextoItem.tiempo = String(tiempoEmpleado)
            let aciertosTra = Int(partidaTextoItem.aciertos!)
            let tiempoTra = Int(partidaTextoItem.tiempo!)
            partidaTextoItem.puntos = Double((aciertosTra! * 20) + (120 - tiempoTra!))
            puntosIntroducidos = Double(aciertosTra! * 20 + tiempoTra!)
            partidaTextoItem.nivel = formaHecha
            for index in 0...Constantes.arrayFigurasNiveles.count - 1{
                if(Constantes.arrayFigurasNiveles[index] == formaHecha && formaHecha != "RECTANGULO"){ //Comprobamos que está en el nivel que acaba de jugar
                    if(UserDefaults.standard.bool(forKey: Constantes.arrayFigurasNiveles[index + 1] + "TextoBloqueado") == true){ //Comprobamos que el nivel siguiente esta bloqueado
                        UserDefaults.standard.set(false, forKey: Constantes.arrayFigurasNiveles[index + 1] + "TextoBloqueado")  //Le desbloqueamos el siguiente nivel.
                    }
                }
            }
            
            do{
                try self.managedObjectContext.save()
            } catch{
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func ponerAlert(titulo: String, descripcion: String){
        var alerta: UIAlertController!
        alerta = UIAlertController(title: titulo, message: descripcion, preferredStyle:         UIAlertControllerStyle.alert)
        alerta.addAction(UIAlertAction(title: "Si", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alerta, animated: true, completion: nil)
    }
    
    @IBAction func closePopUp(_ sender: Any) {
        var nombreIntroducido = tf_nombreIntroducido.text?.trimmingCharacters(in: .whitespaces)
        if(nombreIntroducido == ""){
            ponerAlert(titulo: "Error!", descripcion: "Introduce un nombre válido")
        } else if((nombreIntroducido?.count)! > 4){
            ponerAlert(titulo: "Error!", descripcion: "Nombre maximo 4 caracteres.")
            
        } else {
            subirADataBase()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
            self.view.removeFromSuperview()
        }
    }
}
