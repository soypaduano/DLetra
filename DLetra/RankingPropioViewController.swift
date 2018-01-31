// 9/1/2018
//  DLetra App
//  Created by SEBASTIAN PADUANO (DUWAFARM) on 2018
//  Copyright © 2018 DUWAFARM. All rights reserved.

import UIKit
import CoreData
import GoogleMobileAds

class RankingPropioViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GADInterstitialDelegate{
    
    @IBOutlet weak var lb_aciertos: UILabel!
    @IBOutlet weak var lb_tiempo: UILabel!
    @IBOutlet weak var lb_nombre: UILabel!
    @IBOutlet weak var lb_pos: UILabel!
    @IBOutlet weak var lb_nivelMostrado: UILabel!
    @IBOutlet weak var btn_menu: UIButton!
    @IBOutlet weak var btn_eligenivel: UIButton!
    @IBOutlet weak var btn_niveles: UIButton!
    @IBOutlet weak var miTabla: UITableView!

     //Variables
    private var colorVerde = UIColor(hex: "000000")
    var  managedObjectContext: NSManagedObjectContext!
    var interstitial : GADInterstitial!     //Intersticial
    private var PartidasVoz = [PartidaCuadrado]() //TIPO VOZ
    private var PartidasTexto = [PartidaCuadradoTexto]() //TIPO TEXTO
    var aciertos = Int()
    var formaHecha = String()
    var tiempoEmpleado = Int()
    var modoDeJuego: Bool = false
    private var nombreIntroducidoCambiarColor = ""
    private var puntosIntroducidosCambiarColor = Double()  //Nombre introducido por el usuario
    private var btn_pressed = false //Booleano para el interstiticial
    var fontSize = CGFloat()
    var idUltimo = Int()
    
    private func resizeTextos(){
        fontSize = Constantes.screenSize(screenSize: self.view.frame.size.width)
        lb_nivelMostrado.font = UIFont(descriptor: lb_tiempo.font.fontDescriptor, size: fontSize + 4)
        lb_tiempo.font = UIFont(descriptor: lb_tiempo.font.fontDescriptor, size: fontSize)
        lb_nombre.font = UIFont(descriptor: lb_tiempo.font.fontDescriptor, size: fontSize - 2)
        lb_pos.font = UIFont(descriptor: lb_tiempo.font.fontDescriptor, size: fontSize)
        lb_aciertos.font = UIFont(descriptor: lb_tiempo.font.fontDescriptor, size: fontSize)
        btn_menu.titleLabel?.font = UIFont(descriptor:  (btn_menu.titleLabel?.font.fontDescriptor)!, size: fontSize)
        btn_niveles.titleLabel?.font = UIFont(descriptor:  (btn_niveles.titleLabel?.font.fontDescriptor)!, size: fontSize)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        miTabla.separatorStyle = .none
        resizeTextos()
        cargarAnuncio()
        lb_nivelMostrado.text = formaHecha
        if(modoDeJuego){
            loadDataVoz()
        } else{
            loadDataTexto()
        }
       NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil) //Notificacion para cargar la tabla desde otro lado.
        ponerPopUp()
    }
    
    func loadList(notification: NSNotification){
        colorVerde = UIColor(hex: "0EA80E")  //load data here
        if(modoDeJuego){
            loadDataVoz()
        } else{
        loadDataTexto()
        }
        miTabla.reloadData()
    }
    
    
    private func cargarAnuncio(){ //Cargamos el anuncio
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-1913552533139737/7518229003")
        let request: GADRequest = GADRequest()
        interstitial.load(request)
        interstitial.delegate = self
    }
    
     private func loadDataTexto(){
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext  //Declaramos un objeto de tipo Managed Object Context para trabajar en el core data
        let predicateNivel:NSPredicate = NSPredicate(format: "nivel ==  %@", formaHecha)
        let predicate:NSPredicate  = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateNivel] )
        let partidaRequestTexto:NSFetchRequest<PartidaCuadradoTexto> = PartidaCuadradoTexto.fetchRequest()
        partidaRequestTexto.predicate = predicate
        
        do{
            PartidasTexto = try managedObjectContext.fetch(partidaRequestTexto)
        } catch {
        }
    }
    
    private func loadDataVoz(){
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext  //Declaramos un objeto de tipo Managed Object Context para trabajar en el core data
        let predicateNivel:NSPredicate = NSPredicate(format: "nivel ==  %@", formaHecha)
        let predicate:NSPredicate  = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateNivel] )
        let partidaRequestVoz:NSFetchRequest<PartidaCuadrado> = PartidaCuadrado.fetchRequest()
        partidaRequestVoz.predicate = predicate
        
        do{    //Try and catch para ver si funciona el cargado de datos
            PartidasVoz = try managedObjectContext.fetch(partidaRequestVoz)
        } catch {
        }
    }
    
    private func orderData(){
        if(modoDeJuego){
            PartidasVoz = PartidasVoz.sorted{$0.puntos > $1.puntos}
        } else {
            PartidasTexto = PartidasTexto.sorted{$0.puntos > $1.puntos}
        }
        miTabla.reloadData()
    }
    
    
    private func ponerPopUp(){
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpID") as! PopUpViewController
         self.addChildViewController(popOverVC)
         popOverVC.view.frame = self.view.frame
         self.view.addSubview(popOverVC.view)
         popOverVC.didMove(toParentViewController: self)
         popOverVC.aciertos = aciertos
         popOverVC.tiempoEmpleado = tiempoEmpleado
         popOverVC.formaHecha = formaHecha
         popOverVC.modoDeJuego = modoDeJuego
    }

    private func reloadTableView(_ tableView: UITableView) {
        let contentOffset = tableView.contentOffset
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableView.setContentOffset(contentOffset, animated: false)
    }
    
    private func comprobarNuevoJugador(puntos: Double, nombreJugador: String, nuevo: Bool) -> Bool {
        if(nombreJugador == nombreIntroducidoCambiarColor && puntos == puntosIntroducidosCambiarColor ){
            return true
        } else {
            return false
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        //Los fondos se eliminan
        cell.backgroundColor = .clear
        miTabla.separatorStyle = .none
        cell.selectionStyle = .none
        cell.lb_posicion.font = UIFont(descriptor: lb_tiempo.font.fontDescriptor, size: fontSize)
        cell.lb_tiempo.font = UIFont(descriptor: lb_tiempo.font.fontDescriptor, size: fontSize)
        cell.lb_nombre.font = UIFont(descriptor: lb_tiempo.font.fontDescriptor, size: fontSize)
        cell.lb_aciertos.font = UIFont(descriptor: lb_tiempo.font.fontDescriptor, size: fontSize)
        cell.lb_posicion.text = String(indexPath.row + 1)
        
        if(modoDeJuego){ //SI EL JUGADOR JUEGA EN MODO VOZ....
            
            var arrayClasePartida = [ClasePartida]()
                for index in 0...PartidasVoz.count - 1 {
                    
                    let nombre = PartidasVoz[index].nombre
                    let aciertos = Int(PartidasVoz[index].aciertos!)
                    let tiempo = Int(PartidasVoz[index].tiempo!)
                    let puntos = PartidasVoz[index].puntos
                    let clasePartida = ClasePartida(_nombre: nombre!, _aciertos: aciertos!, _tiempo: tiempo!, _puntos: puntos, _id: index)
                    arrayClasePartida.append(clasePartida)
                }
                
                idUltimo = (arrayClasePartida.last?.id)!
                arrayClasePartida = arrayClasePartida.sorted{$0.puntos > $1.puntos}
                
                
                if(arrayClasePartida[indexPath.row].id == idUltimo ){
                    changeColorGreen(cell: cell)
                } else {
                    changeColorBlack(cell: cell)
                }
                
                cell.lb_nombre.text = PartidasVoz[indexPath.row].nombre
                cell.lb_tiempo.text = PartidasVoz[indexPath.row].tiempo
                cell.lb_aciertos.text = PartidasVoz[indexPath.row].aciertos
        
        } else{
            
            var arrayClasePartida = [ClasePartida]()
                for index in 0...PartidasTexto.count - 1 {
                    let nombre = PartidasTexto[index].nombre
                    let aciertos = Int(PartidasTexto[index].aciertos!)
                    let tiempo = Int(PartidasTexto[index].tiempo!)
                    let puntos = PartidasTexto[index].puntos
                    let clasePartida = ClasePartida(_nombre: nombre!, _aciertos: aciertos!, _tiempo: tiempo!, _puntos: puntos, _id: index)
                    arrayClasePartida.append(clasePartida)
                }
                
                idUltimo = (arrayClasePartida.last?.id)!
                arrayClasePartida = arrayClasePartida.sorted{$0.puntos > $1.puntos}
                if(arrayClasePartida[indexPath.row].id == idUltimo ){
                    changeColorGreen(cell: cell)
                } else {
                    changeColorBlack(cell: cell)
                }
 
                cell.lb_nombre.text = arrayClasePartida[indexPath.row].nombre
                cell.lb_tiempo.text = String(arrayClasePartida[indexPath.row].tiempo)
                cell.lb_aciertos.text = String(arrayClasePartida[indexPath.row].aciertos)
        }
        cell.lb_nombre.sizeToFit()
        return cell
    }
    
    func changeColorBlack(cell: TableViewCell){
        cell.lb_nombre.textColor = UIColor.black
        cell.lb_tiempo.textColor = UIColor.black
        cell.lb_aciertos.textColor = UIColor.black
        cell.lb_posicion.textColor = UIColor.black
    }
    
    func changeColorGreen(cell: TableViewCell){
        cell.lb_nombre.textColor = colorVerde
        cell.lb_tiempo.textColor = colorVerde
        cell.lb_aciertos.textColor = colorVerde
        cell.lb_posicion.textColor = colorVerde
    }
    
    //Esta funcion se llama para ver cuantas rows va a haber en nuestra tabla.
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(modoDeJuego){
            if(PartidasVoz.count > 0 && PartidasVoz.count <= 10) {
                return PartidasVoz.count
            } else if(PartidasTexto.count <= 0) {
                return 0
            } else {
                return 10
            }
        } else {
            if(PartidasTexto.count > 0 && PartidasTexto.count <= 10) {
                return PartidasTexto.count
            } else if(PartidasTexto.count <= 0) {
                return 0
            } else {
                return 10
            }
        }
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        if(btn_pressed){
            self.performSegue(withIdentifier: "unwindNiveles", sender: self)
        } else {
            self.performSegue(withIdentifier: "unwindMenu", sender: self)
        }
    }
    
    
    private func reproducirAnuncio(){
        if(interstitial.isReady){
            interstitial.present(fromRootViewController: self)
        } else {
            if(btn_pressed){
                self.performSegue(withIdentifier: "unwindNiveles", sender: self)
            } else {
                self.performSegue(withIdentifier: "unwindMenu", sender: self)
            }
        }
    }
    
    
    @IBAction func btn_menuPrincipal(_ sender: Any) {
        btn_pressed = false
        reproducirAnuncio()
    }
    
    @IBAction func btn_menuNiveles(_ sender: Any) {
        btn_pressed = true
        reproducirAnuncio()
    }
}
