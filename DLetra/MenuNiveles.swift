// 9/1/2018
//  DLetra App
//  Created by SEBASTIAN PADUANO (DUWAFARM) on 2018
//  Copyright © 2018 DUWAFARM. All rights reserved.

import UIKit

@available(iOS 8.0, *)
class MenuNiveles: UIViewController {
    
    @IBOutlet weak var btn_triangulo: UIButton!
    @IBOutlet weak var btn_trapecio: UIButton!
    @IBOutlet weak var btn_cuadrado: UIButton!
    @IBOutlet weak var btn_rombo: UIButton!
    @IBOutlet weak var btn_rectangulo: UIButton!
    
    private var arrayBotones = [UIButton]()
    var modoDeJuego: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        comprobarNivelesDesbloqueados()
        btn_triangulo.addTarget(self,action:#selector(buttonClicked),
                          for:.touchUpInside)
        btn_trapecio.addTarget(self,action:#selector(buttonClicked),
                          for:.touchUpInside)
        btn_cuadrado.addTarget(self,action:#selector(buttonClicked),
                          for:.touchUpInside)
        btn_rombo.addTarget(self,action:#selector(buttonClicked),
                               for:.touchUpInside)
        btn_rectangulo.addTarget(self,action:#selector(buttonClicked),
                            for:.touchUpInside)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        animarBotones()
    }
    
    private func comprobarNivelesDesbloqueados(){ //Agregamos los botones
        arrayBotones.append(btn_triangulo)
        arrayBotones.append(btn_trapecio)
        arrayBotones.append(btn_cuadrado)
        arrayBotones.append(btn_rombo)
        arrayBotones.append(btn_rectangulo)
        
        if(modoDeJuego){ //Modo Voz niveles.
            for index in 0...Constantes.arrayFigurasNiveles.count - 1{
                if(UserDefaults.standard.bool(forKey: Constantes.arrayFigurasNiveles[index] + "VozBloqueado" ) == false){
                    let image = UIImage(named: Constantes.arrayFigurasNiveles[index].lowercased() + ".png") as UIImage!
                    arrayBotones[index].setImage(image, for: .normal)
                } else {
                    print(Constantes.arrayFigurasNiveles[index] + "ESTA BLOQUEADO")
                    let image = UIImage(named: Constantes.arrayFigurasNiveles[index].lowercased() + "2.png") as UIImage!
                    arrayBotones[index].setImage(image, for: .normal)
                }
            }
        } else { //Modo Texto
            for index in 0...Constantes.arrayFigurasNiveles.count - 1{
                if(UserDefaults.standard.bool(forKey: Constantes.arrayFigurasNiveles[index] + "TextoBloqueado" ) == false){
                    
                    let image = UIImage(named: Constantes.arrayFigurasNiveles[index].lowercased() + ".png") as UIImage!
                    arrayBotones[index].setImage(image, for: .normal)
                } else {
                    print(Constantes.arrayFigurasNiveles[index] + "ESTA BLOQUEADO")
                    let image = UIImage(named: Constantes.arrayFigurasNiveles[index].lowercased() + "2.png") as UIImage!
                    arrayBotones[index].setImage(image, for: .normal)
                }
            }
        }
    }
    
    private func animarBotones(){
        var timeInterval = 0.0
        for index in 0...Constantes.arrayFigurasNiveles.count - 1{
            timeInterval = timeInterval + 0.3
            fadeInImage(withDuration: timeInterval, value: index)
        }
    }
    
    private func fadeInImage(withDuration duration: TimeInterval = 0.3, value: Int) {
        UIView.animate(withDuration: duration, animations: {
            self.arrayBotones[value].alpha = 1.0
        })
    }
    
    func buttonClicked(sender: UIButton) { //Cada vez que se pulse un botón vamos a recorrer todos los botones.
        if(modoDeJuego){
            if(UserDefaults.standard.bool(forKey: Constantes.arrayKeysVoz[sender.tag]) == false){
                self.performSegue(withIdentifier: Constantes.arrayKeysVoz[sender.tag].replacingOccurrences(of: "Bloqueado", with: ""), sender: sender)
            } else {
                errorPasarNivel(figuraMostrar: Constantes.arrayFigurasNiveles[sender.tag - 1].lowercased())
            }
        } else {
            if(UserDefaults.standard.bool(forKey: Constantes.arrayKeysTexto[sender.tag]) == false){
                let identifier = Constantes.arrayKeysTexto[sender.tag].replacingOccurrences(of: "Bloqueado", with: "")
                self.performSegue(withIdentifier: identifier, sender: sender)
            } else {
                errorPasarNivel(figuraMostrar: Constantes.arrayFigurasNiveles[sender.tag - 1].lowercased())
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        for index in 0...Constantes.arrayFigurasNiveles.count - 1{
            if sender as! UIButton == arrayBotones[index]{
                
                if(segue.identifier ==  Constantes.arrayFigurasNiveles[index].uppercased() + "Voz"){
                    if #available(iOS 10.0, *) {
                        let viewPartida = segue.destination as! MecanicaVoz
                        
                        viewPartida.modoDeJuego = modoDeJuego
                        viewPartida.nivelElegido = Constantes.arrayFigurasNiveles[index]
                        viewPartida.oportunidades = Constantes.arrayOportunidades[index]
                        return
                    }
                } else if(segue.identifier ==  Constantes.arrayFigurasNiveles[index].uppercased() + "Texto"){
                    let viewPartida = segue.destination as! MecanicaTexto
                    viewPartida.modoDeJuego = modoDeJuego
                    viewPartida.nivelElegido = Constantes.arrayFigurasNiveles[index]
                    viewPartida.oportunidades = Constantes.arrayOportunidades[index]
                    return
                }
            }
        }
    }
    
    private func errorPasarNivel(figuraMostrar: String){
        var alerta: UIAlertController!
        alerta = UIAlertController(title: "", message: "Tienes que pasar el " + figuraMostrar + " para activarla ", preferredStyle:         UIAlertControllerStyle.alert)
        alerta.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alerta, animated: true, completion: nil)
    }
  
    @IBAction func fromRankingPropioNiveles(segue:UIStoryboardSegue){
        comprobarNivelesDesbloqueados() //Aqui los niveles ya deberian estar desbloqueados.
    }

    @IBAction func fromPartidaVoz(segue:UIStoryboardSegue){
        comprobarNivelesDesbloqueados()
    }
    
    @IBAction func fromPartidaTexto(segue:UIStoryboardSegue){
        comprobarNivelesDesbloqueados()
    }
}
