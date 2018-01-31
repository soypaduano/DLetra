// 9/1/2018
//  DLetra App
//  Created by SEBASTIAN PADUANO (DUWAFARM) on 2018
//  Copyright © 2018 DUWAFARM. All rights reserved.

import UIKit
import CoreData

class RankingGeneral: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var lb_tiempo_constrain: NSLayoutConstraint!
    @IBOutlet weak var lb_aciertos_constrain: NSLayoutConstraint!
    @IBOutlet weak var lb_nombre_constrain: NSLayoutConstraint!
    @IBOutlet weak var lb_pos_constrain: NSLayoutConstraint!
    @IBOutlet weak var lb_forma: UILabel!
    @IBOutlet weak var miTabla: UITableView! //La tabla que vamos a mostrar
    @IBOutlet weak var lb_nombre: UILabel!
    @IBOutlet weak var btn_anterior: UIButton!
    @IBOutlet weak var btn_menu: UIButton!
    @IBOutlet weak var lb_nivelMostrado: UILabel!
    @IBOutlet weak var btn_siguiente: UIButton!
    @IBOutlet weak var lb_tiempo: UILabel!
    @IBOutlet weak var lb_aciertos: UILabel!
    @IBOutlet weak var lb_pos: UILabel!
    var managedObjectContext:NSManagedObjectContext! //Objetos para el Core Data
    var modoDeJuego: Bool = false
    var posicionActual = 0
    var fontSize = CGFloat()
    //Array de niveles
    private var PartidaTexto = [PartidaCuadradoTexto]()
    private var PartidaVoz = [PartidaCuadrado]()
    //Array de Partidas voz
    private var arrayDeArraysVoz = [[PartidaCuadrado]]()
    private var arrayBestVoz = [PartidaCuadrado]()
    private var arrayTrianguloVoz = [PartidaCuadrado]()
    private var arrayCuadradoVoz = [PartidaCuadrado]()
    private var arrayTrapecioVoz = [PartidaCuadrado]()
    private var arrayRomboVoz = [PartidaCuadrado]()
    private var arrayRectanguloVoz = [PartidaCuadrado]()
    //Array de partidas texto
    private var arrayDeArraysTexto = [[PartidaCuadradoTexto]]()
    private var arrayBestTexto = [PartidaCuadradoTexto]()
    private var arrayTrianguloTexto = [PartidaCuadradoTexto]()
    private var arrayCuadradoTexto = [PartidaCuadradoTexto]()
    private var arrayTrapecioTexto = [PartidaCuadradoTexto]()
    private var arrayRomboTexto = [PartidaCuadradoTexto]()
    private var arrayRectanguloTexto = [PartidaCuadradoTexto]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ajustarLetras()
        self.miTabla.allowsSelection = false
        self.miTabla.separatorStyle = UITableViewCellSeparatorStyle.none
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        lb_nivelMostrado.text =  Constantes.arrayFiguras[posicionActual] //Mostramos el nivel
        if(modoDeJuego){
            loadDataVoz()
        } else {
            loadDataTexto()
        }
    }
    
    private func loadDataTexto(){
        let partidaResquestTexto:NSFetchRequest<PartidaCuadradoTexto> = PartidaCuadradoTexto.fetchRequest() //Nos bajamos los datos de las entidades que tenemos en Core Data
         do{
            PartidaTexto = try managedObjectContext.fetch(partidaResquestTexto)
            orderData()
            if(PartidaTexto.isEmpty){
                return
            }

            for index in 0...PartidaTexto.count - 1{
                switch PartidaTexto[index].nivel!{
                case "TRIANGULO":
                    arrayTrianguloTexto.append(PartidaTexto[index])
                    let results = arrayBestTexto.filter { $0.nivel! == "TRIANGULO" }
                    if(results.isEmpty){
                        arrayBestTexto.append(arrayTrianguloTexto[0])
                    }
                    break
                case "TRAPECIO":
                    arrayTrapecioTexto.append(PartidaTexto[index])
                    let results = arrayBestTexto.filter { $0.nivel! == "TRAPECIO" }
                    if(results.isEmpty){
                        arrayBestTexto.append(arrayTrapecioTexto[0])
                    }
                    break
                case "CUADRADO":
                    arrayCuadradoTexto.append(PartidaTexto[index])
                    let results = arrayBestTexto.filter { $0.nivel! == "CUADRADO" }
                    if(results.isEmpty){
                        arrayBestTexto.append(arrayCuadradoTexto[0])
                    }
                    break
                case "ROMBO":
                    arrayRomboTexto.append(PartidaTexto[index])
                    let results = arrayBestTexto.filter { $0.nivel! == "ROMBO" }
                    if(results.isEmpty){
                        arrayBestTexto.append(arrayRomboTexto[0])
                    }
                    break
                case "RECTANGULO":
                    arrayRectanguloTexto.append(PartidaTexto[index])
                    let results = arrayBestTexto.filter { $0.nivel! == "RECTANGULO" }
                    if(results.isEmpty){
                        arrayBestTexto.append(arrayRectanguloTexto[0])
                    }
                    break
                default:
                    break
                }
            }
            orderBestTexto()
            arrayDeArraysTexto.append(arrayBestTexto)
            arrayDeArraysTexto.append(arrayTrianguloTexto)
            arrayDeArraysTexto.append(arrayTrapecioTexto)
            arrayDeArraysTexto.append(arrayCuadradoTexto)
            arrayDeArraysTexto.append(arrayRomboTexto)
            arrayDeArraysTexto.append(arrayRectanguloTexto)
        } catch {
        }
    }
    
    private func loadDataVoz(){
        let partidaResquestVoz:NSFetchRequest<PartidaCuadrado> = PartidaCuadrado.fetchRequest() //Nos bajamos los datos de las entidades que tenemos en Core Data
        do{
            PartidaVoz = try managedObjectContext.fetch(partidaResquestVoz)
            if(PartidaVoz.isEmpty){
                return
            }
            orderData()
            for index in 0...PartidaVoz.count - 1{
                switch PartidaVoz[index].nivel!{
                case "TRIANGULO":
                    arrayTrianguloVoz.append(PartidaVoz[index])
                    let results = arrayBestVoz.filter { $0.nivel! == "TRIANGULO" }
                    if(results.isEmpty){
                        arrayBestVoz.append(arrayTrianguloVoz[0])
                    }
                    break
                case "TRAPECIO":
                    arrayTrapecioVoz.append(PartidaVoz[index])
                    let results = arrayBestVoz.filter { $0.nivel! == "TRAPECIO" }
                    if(results.isEmpty){
                        arrayBestVoz.append(arrayTrapecioVoz[0])
                    }
                    break
                case "CUADRADO":
                    arrayCuadradoVoz.append(PartidaVoz[index])
                    let results = arrayBestVoz.filter { $0.nivel! == "CUADRADO" }
                    if(results.isEmpty){
                        arrayBestVoz.append(arrayCuadradoVoz[0])
                    }
                    break
                case "ROMBO":
                    arrayRomboVoz.append(PartidaVoz[index])
                     let results = arrayBestVoz.filter { $0.nivel! == "ROMBO" }
                    if(results.isEmpty){
                        arrayBestVoz.append(arrayRomboVoz[0])
                    }
                    break
                case "RECTANGULO":
                    arrayRectanguloVoz.append(PartidaVoz[index])
                     let results = arrayBestVoz.filter { $0.nivel! == "RECTANGULO" }
                    if(results.isEmpty){
                        arrayBestVoz.append(arrayRectanguloVoz[0])
                    }
                    break
                default:
                    break
                }
            }
            orderBestVoz()
            arrayDeArraysVoz.append(arrayBestVoz)
            arrayDeArraysVoz.append(arrayTrianguloVoz)
            arrayDeArraysVoz.append(arrayTrapecioVoz)
            arrayDeArraysVoz.append(arrayCuadradoVoz)
            arrayDeArraysVoz.append(arrayRomboVoz)
            arrayDeArraysVoz.append(arrayRectanguloVoz)
        } catch {
        }
    }

    private func orderData(){
        PartidaVoz = PartidaVoz.sorted{$0.puntos > $1.puntos}      //Ordenamos los ranking de tipo Voz
        PartidaTexto = PartidaTexto.sorted{$0.puntos > $1.puntos} //Ordenamos los rankings de tipo Texto
    }
    
    private func  orderBestTexto(){
        var auxiliarArray = [PartidaCuadradoTexto]()
        for index in 0...Constantes.arrayFigurasNiveles.count - 1{
            for j in 0...arrayBestTexto.count - 1{
                if(Constantes.arrayFigurasNiveles[index] == arrayBestTexto[j].nivel!){
                    auxiliarArray.append(arrayBestTexto[j])
                }
            }
        }
        arrayBestTexto = auxiliarArray
        reloadTableView(miTabla)
    }
    
    private func  orderBestVoz(){
        var auxiliarArray = [PartidaCuadrado]()
        for index in 0...Constantes.arrayFigurasNiveles.count - 1{
            for j in 0...arrayBestVoz.count - 1{
                if(Constantes.arrayFigurasNiveles[index] == arrayBestVoz[j].nivel!){
                    auxiliarArray.append(arrayBestVoz[j])
                }
            }
        }
        arrayBestVoz = auxiliarArray
        reloadTableView(miTabla)
    }
    
    private func ajustarLetras(){
       fontSize = Constantes.screenSize(screenSize: self.view.frame.size.width)
        lb_pos.font = UIFont(descriptor: lb_forma.font.fontDescriptor, size: fontSize - 2)
        lb_forma.font = UIFont(descriptor: lb_forma.font.fontDescriptor, size: fontSize - 2)
        lb_tiempo.font = UIFont(descriptor: lb_forma.font.fontDescriptor, size: fontSize - 2)
        lb_aciertos.font = UIFont(descriptor: lb_forma.font.fontDescriptor, size: fontSize - 2)
        lb_nombre.font = UIFont(descriptor: lb_forma.font.fontDescriptor, size: fontSize - 2)
        lb_nivelMostrado.font = UIFont(descriptor: lb_forma.font.fontDescriptor, size: fontSize)
        btn_anterior.titleLabel?.font = UIFont(descriptor:  (btn_anterior.titleLabel?.font.fontDescriptor)!, size: fontSize)
        btn_siguiente.titleLabel?.font = UIFont(descriptor:  (btn_anterior.titleLabel?.font.fontDescriptor)!, size: fontSize)
        btn_menu.titleLabel?.font = UIFont(descriptor:  (btn_anterior.titleLabel?.font.fontDescriptor)!, size: fontSize)
    }
    
    private func reloadTableView(_ tableView: UITableView) {
        let contentOffset = tableView.contentOffset
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableView.setContentOffset(contentOffset, animated: false)
    }
    
    private func setConstrainsToRankingTable(_celda: TableViewCell? = nil, _withImage: Bool){
        if(_withImage){
            lb_forma.isHidden = false
            _celda?.image_forma.isHidden = false
            lb_pos_constrain =  lb_pos_constrain.setMultiplier(multiplier: 0.2)
            lb_nombre_constrain = lb_nombre_constrain.setMultiplier(multiplier: 0.55)
            lb_tiempo_constrain = lb_tiempo_constrain.setMultiplier(multiplier: 0.9)
            lb_aciertos_constrain = lb_aciertos_constrain.setMultiplier(multiplier: 1.3)
            _celda?.lb_posCell_constain = _celda?.lb_posCell_constain.setMultiplier(multiplier: 0.2)
            _celda?.lb_nombreCell_constrain = _celda?.lb_nombreCell_constrain.setMultiplier(multiplier: 0.55)
            _celda?.lb_tiempoCell_constrain = _celda?.lb_tiempoCell_constrain.setMultiplier(multiplier: 1.0)
            _celda?.lb_aciertosCell_constrain = _celda?.lb_aciertosCell_constrain.setMultiplier(multiplier: 1.4)
        } else {
            lb_forma.isHidden = true
            _celda?.image_forma.isHidden = true
            lb_pos_constrain =  lb_pos_constrain.setMultiplier(multiplier: 0.3)
            lb_nombre_constrain = lb_nombre_constrain.setMultiplier(multiplier: 0.75)
            lb_tiempo_constrain = lb_tiempo_constrain.setMultiplier(multiplier: 1.2)
            lb_aciertos_constrain = lb_aciertos_constrain.setMultiplier(multiplier: 1.6)
            _celda?.lb_posCell_constain = _celda?.lb_posCell_constain.setMultiplier(multiplier: 0.3)
            _celda?.lb_nombreCell_constrain = _celda?.lb_nombreCell_constrain.setMultiplier(multiplier: 0.75)
            _celda?.lb_tiempoCell_constrain = _celda?.lb_tiempoCell_constrain.setMultiplier(multiplier: 1.2)
            _celda?.lb_aciertosCell_constrain = _celda?.lb_aciertosCell_constrain.setMultiplier(multiplier: 1.6)
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        cell.lb_posicion.text = String(indexPath.row + 1)
        cell.lb_nombre.font = UIFont(descriptor: lb_forma.font.fontDescriptor, size: fontSize)
        cell.lb_aciertos.font = UIFont(descriptor: lb_forma.font.fontDescriptor, size: fontSize)
        cell.lb_posicion.font = UIFont(descriptor: lb_forma.font.fontDescriptor, size: fontSize)
        cell.lb_tiempo.font = UIFont(descriptor: lb_forma.font.fontDescriptor, size: fontSize)
        
        if(modoDeJuego){      //SI EL JUGADOR JUEGA EN MODO VOZ....
            if(arrayDeArraysVoz.count != 0){
                cell.lb_nombre.text = arrayDeArraysVoz[posicionActual][indexPath.row].nombre
                cell.lb_tiempo.text = arrayDeArraysVoz[posicionActual][indexPath.row].tiempo
                cell.lb_aciertos.text = arrayDeArraysVoz[posicionActual][indexPath.row].aciertos
                cell.image_forma.image = UIImage(named: "forma" + String(indexPath.row + 1) + ".png")
            }
            
            if(posicionActual == 0){ //POSICION 0: GENERAL MODO TEXTO
                setConstrainsToRankingTable(_celda: cell, _withImage: true)
            }else if(posicionActual == 1){  //POSICION 0: TRIANGULO MODO TEXTO
                setConstrainsToRankingTable(_celda: cell, _withImage: false)
            } else if(posicionActual == 2){   //POSICION 1: TRAPECIO MODO TEXTO
                setConstrainsToRankingTable(_celda: cell, _withImage: false)
            } else if(posicionActual == 5){ //POSICION 4: RECTANGULO MODO TEXTO
                setConstrainsToRankingTable(_celda: cell, _withImage: false)
            }
        
        } else if(!modoDeJuego){ //SI EL JUGADOR JUEGA EN MODO TEXT
            
            if(arrayDeArraysTexto.count != 0){
                cell.lb_nombre.text = arrayDeArraysTexto[posicionActual][indexPath.row].nombre
                cell.lb_tiempo.text = arrayDeArraysTexto[posicionActual][indexPath.row].tiempo
                cell.lb_aciertos.text = arrayDeArraysTexto[posicionActual][indexPath.row].aciertos
                cell.image_forma.image = UIImage(named: "forma" + String(indexPath.row + 1) + ".png")
            }
            
            if(posicionActual == 0){ //POSICION 0: GENERAL MODO TEXTO
                setConstrainsToRankingTable(_celda: cell, _withImage: true)
            }else if(posicionActual == 1){  //POSICION 0: TRIANGULO MODO TEXTO
                setConstrainsToRankingTable(_celda: cell, _withImage: false)
            } else if(posicionActual == 2){   //POSICION 1: TRAPECIO MODO TEXTO
                setConstrainsToRankingTable(_celda: cell, _withImage: false)
            } else if(posicionActual == 5){ //POSICION 4: RECTANGULO MODO TEXTO
                setConstrainsToRankingTable(_celda: cell, _withImage: false)
            }
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { //Esta funcion se llama para ver cuantas rows va a haber en nuestra tabla.
        if(modoDeJuego){
            if(arrayDeArraysVoz.count == 0){
                return 0
            }
            if(arrayDeArraysVoz[posicionActual].count == 0){
                return 0
            } else if(arrayDeArraysVoz[posicionActual].count > 0 && arrayDeArraysVoz[posicionActual].count < 10){
                return arrayDeArraysVoz[posicionActual].count
            } else {
                return 10
            }
        } else {
            if(arrayDeArraysTexto.count == 0){
                return 0
            }
            if(arrayDeArraysTexto[posicionActual].count == 0){
                return 0
            } else if(arrayDeArraysTexto[posicionActual].count > 0 && arrayDeArraysTexto[posicionActual].count < 10){
                return arrayDeArraysTexto[posicionActual].count
            } else {
                return 10
            }
        }
    }

    @IBAction func btn_siguiente(_ sender: Any) {
        if(posicionActual <= Constantes.arrayFiguras.count){
            posicionActual += 1
            if(posicionActual == Constantes.arrayFiguras.count){
                posicionActual = 0
            }
            lb_nivelMostrado.text = Constantes.arrayFiguras[posicionActual]
            reloadTableView(miTabla)
        }
        
        if(posicionActual == 0){
            setConstrainsToRankingTable(_celda: nil, _withImage: true)
            self.view.layoutIfNeeded()
        } else {
            setConstrainsToRankingTable(_celda: nil, _withImage: false)
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func btn_anterior(_ sender: Any) {
        if(posicionActual >= 0){
            posicionActual -= 1
            if(posicionActual < 0){
                posicionActual = Constantes.arrayFiguras.count - 1
            }
            lb_nivelMostrado.text = Constantes.arrayFiguras[posicionActual]
            reloadTableView(miTabla)
        }
        
        if(posicionActual == 0){
            setConstrainsToRankingTable(_celda: nil, _withImage: true)
            self.view.layoutIfNeeded()
        } else {
            setConstrainsToRankingTable(_celda: nil, _withImage: false)
            self.view.layoutIfNeeded()
        }
    }
}
