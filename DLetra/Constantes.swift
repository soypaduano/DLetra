//
//  Constantes.swift
//  DLetra
//
//  Created by Desarrollo MAC on 28/11/17.
//  Copyright © 2017 Desarrollo MAC. All rights reserved.
//

import Foundation
import UIKit


//Extension para hacernos el Shuffle del array
extension MutableCollection  {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

//Extension para hacer la animacion
extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.2
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}


extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}

extension NSLayoutConstraint {
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}


extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}



class Constantes {
    //LETRAS DE CADA JUEGO
    //Triangulo
   static let letrasNivelTriangulo = ["A", "B", "C", "D", "E", "F", "G", "H", "J", "L", "M", "O", "P", "R", "S", "T", "U", "Z"]
    //Trapecio
    static let letrasNivelTrapecio = ["A", "B", "C", "D", "E", "F", "G", "H", "J", "L", "M", "O", "P", "R", "S", "T", "U", "Z"]
    //Cuadrado
    static let letrasNivelCuadrado = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "L", "M", "O", "P", "R", "S", "T", "U", "V", "Z"]
    //Rombo
    static let letrasNivelRombo = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "L", "M", "O", "P", "R", "S", "T", "U", "V", "Z"]
    //Rectangulo
    static let letrasNivelRectangulo = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "L", "M", "N", "Ñ", "O", "P", "Q", "R", "S", "T", "U", "V", "X", "Z"]
    //letras que vamos a utilizar en nuestros niveles.
    
    
    static let arrayFiguras: [String] = ["GENERAL", "TRIANGULO", "TRAPECIO", "CUADRADO", "ROMBO", "RECTANGULO"]
    static let arrayFigurasNiveles: [String] = ["TRIANGULO", "TRAPECIO", "CUADRADO", "ROMBO", "RECTANGULO"]
    static let arrayOportunidades: [String] = ["3", "3", "2", "2", "0"]
    //KEYS
    static let arrayKeysVoz = ["TRIANGULOVozBloqueado", "TRAPECIOVozBloqueado", "CUADRADOVozBloqueado", "ROMBOVozBloqueado", "RECTANGULOVozBloqueado"]
    static let arrayKeysTexto = ["TRIANGULOTextoBloqueado", "TRAPECIOTextoBloqueado", "CUADRADOTextoBloqueado", "ROMBOTextoBloqueado", "RECTANGULOTextoBloqueado"]
    
    static let tiempoInicialTexto = 120
    static let tiempoInicialVoz = 180
    
    static func setLetras(nivelElegido: String) -> [String]{
        var letrasNivel = [String]()
        if(nivelElegido == "TRIANGULO"){
            letrasNivel = Constantes.letrasNivelTriangulo
        } else if (nivelElegido == "TRAPECIO"){
            letrasNivel = Constantes.letrasNivelTrapecio
        } else if(nivelElegido == "CUADRADO"){
            letrasNivel = Constantes.letrasNivelCuadrado
        } else if(nivelElegido == "ROMBO"){
            letrasNivel = Constantes.letrasNivelRombo
        } else if(nivelElegido == "RECTANGULO"){
            letrasNivel = Constantes.letrasNivelRectangulo
        }
        return letrasNivel
    }
    
    static func screenSize(screenSize: CGFloat) -> CGFloat {
            var fontSize = CGFloat()
            switch screenSize {
            case 320: // iPhone 4 and iPhone 5
                fontSize = 14.0
            case 375: // iPhone 6 //Iphone7
                fontSize = 17.0
            case 414: // iPhone 6 Plus // Iphone7Plus
                fontSize = 18.0
            case 768: // iPad
                fontSize = 32.0
            case 1024:
                fontSize = 45.0
            default: // iPad Pro
                fontSize = 10.0
            }
            
            return fontSize;
        }
    
    
    static func FondosBordesView(_view: UIView) -> UIView {
            let newView = _view
            newView.clipsToBounds = true
            newView.layer.cornerRadius = 10
            newView.layer.shadowOpacity = 0.8
            newView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            newView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            return newView
    }
}

class Partida {
    var nombre : String?
    var tiempo : String?
    var puntos : Double?
    var aciertos : String?
    var nivel : String?
    var modo : Bool?
    
    func Partida(_nombre: String, _tiempo: String, _aciertos: String, _nivel: String, _modo: Bool){
        self.nombre = _nombre
        self.tiempo = _tiempo
        self.puntos = calcularPuntos(_tiempo: _tiempo, _aciertos: _aciertos)
        self.aciertos = _aciertos
        self.nivel = _nivel
        self.modo = _modo
    }
    
    func calcularPuntos(_tiempo: String, _aciertos: String) -> Double{
        //do operation that is needed
        return Double(_tiempo)! * Double(_aciertos)!
        
    }
    
    
}
