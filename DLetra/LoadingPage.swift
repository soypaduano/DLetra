//
//  LoadingPage.swift
//  PruebaRankingSebastian
//
//  Created by Desarrollo MAC on 13/3/17.
//  Copyright © 2017 Desarrollo MAC. All rights reserved.
//

import UIKit
import CoreData

class LoadingPage: UIViewController {
    
    //Objeto que nos va a dejar manejar la base de datos
    var managedObjectContext:NSManagedObjectContext!

        //Outlets
    
        //label
        @IBOutlet weak var progressBar: UIProgressView!
        @IBOutlet weak var lb_bienvenido: UILabel!
        @IBOutlet weak var lb_baseDeDatos: UILabel!
        @IBOutlet weak var lb_modoDeJuego: UILabel!
        @IBOutlet weak var lb_errorDatabase: UILabel!
    

        //botones
        @IBOutlet weak var btn_voz: UIButton!
        @IBOutlet weak var btn_texto: UIButton!
    
        //Variables para la barra.
        var progresoBarra = 0.0
        var niveles = 5.0

        //donde guardaremos todos los datos
        var allMyData = [String]()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Si la app se ha lanzado por primera vez
        if(UserDefaults.standard.bool(forKey: "HasLaunchedOnce"))
        {
            //Ocultamos los botones de voz, texto y el label
            ocultarBotonesAlphaZero()
           
            //Si el usuario ya ha entrado en la app
            vuelveAEntrar()
            
           //Declarmaos el objeto con el que vamos a manejar la base de datos.
            managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            print("App already launched")
    
            
        }
        else //SI LA APP ES INSTALADA POR PRIMERA VEZ.....
        {
            
            //Barra de progreso en 0
            self.progressBar.progress = 0;
            
            //Como la app ya ha entrado, ya ocultamos los elementos de la primera vez.
           ocultarBotonesAlphaZero()
            
        
            //Este es mi primer lanzamiento
            UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
            UserDefaults.standard.synchronize()
            print ("No ha entrado nunca")
            
            //ESTO DE AQUI LO PODEMOS OPTIMIZAR HACIENDO UN FOR!
            
            //Al no haber entrado nunca, tenemos que poner todos los niveles en TRUE: ESTAN BLOQUEADOSS!!!!!
            UserDefaults.standard.set(true, forKey: "TrapecioVozBloqueado")
            UserDefaults.standard.set(true, forKey: "TrapecioTextoBloqueado")
            UserDefaults.standard.set(true, forKey: "CuadradoVozBloqueado")
            UserDefaults.standard.set(true, forKey: "CuadradoTextoBloqueado")
            UserDefaults.standard.set(true, forKey: "RomboVozBloqueado")
            UserDefaults.standard.set(true, forKey: "RomboTextoBloqueado")
            UserDefaults.standard.set(true, forKey: "RectanguloVozBloqueado")
            UserDefaults.standard.set(true, forKey: "RectanguloTextoBloqueado")
            
            //Creamos un objeto para manejar la database
            managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            

            //Llamamos a nuestras funciones para subir a la db
            // con sumarAProgressbar() podemos sumar a la base de datos.
            let trianguloListo = uploadToDatabase(ruta: "baseDatosPyRtriangulo", claseRecibida: "Triangulo")
            sumarAProgressbar()
            let trapecioListo = uploadToDatabase(ruta: "baseDatosPyRtrapecio", claseRecibida: "Trapecio")
            sumarAProgressbar()
            let cuadradoListo = uploadToDatabase(ruta: "baseDatosPyRcuadrado", claseRecibida: "Cuadrado")
            sumarAProgressbar()
            let romboListo = uploadToDatabase(ruta: "baseDatosPyRrombo", claseRecibida: "Rombo")
            sumarAProgressbar()
            let rectanguloListo = uploadToDatabase(ruta: "baseDatosPyRrectangulo", claseRecibida: "Rectangulo")
            sumarAProgressbar()
           let trianguloListoTexto = uploadToDatabase(ruta: "baseDatosPyRtrianguloTexto", claseRecibida: "TrianguloTexto")
            

            //Si todo nos da true, comprobamos y lo mostramos.
            if(trianguloListo && trapecioListo && cuadradoListo && romboListo && rectanguloListo && trianguloListoTexto){
                print("")
                print("")
                print("VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV")
                print("Datos correctamente traspasados")
                print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
                lb_baseDeDatos.isHidden = false
                lb_errorDatabase.isHidden = true
                
                
                
                
            } else {
                print("")
                print("")
                print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
                print("Datos erroneamente traspasados =(")
                print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
                lb_errorDatabase.isHidden = false
                
                progressBar.progressTintColor = UIColor.red
                progressBar.tintColor = UIColor.red
                lb_baseDeDatos.isHidden = true
               
            }
        }
    }
    
    //Cuando la pantalla aparece, ejecutamos la animacion
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Animamos los botones
        animarBotones()
    }
    
    
   //Si vuelve a entrar, ocultamos los elementos que teniamos que haber
    func vuelveAEntrar(){
        lb_bienvenido.isHidden = true
        lb_errorDatabase.isHidden = true
        lb_baseDeDatos.isHidden = true
        progressBar.isHidden = true
    }
    
    //Cuando entra por primera vez....
    func entraPrimeraVez(){
        lb_bienvenido.isHidden = false
        lb_errorDatabase.isHidden = false
        lb_baseDeDatos.isHidden = false
        progressBar.isHidden = false
    }
    
    
    //Ocultamos los 3 elementos principales.
    func ocultarBotonesAlphaZero(){
        //Los botones y el label se deben ocultar
        btn_texto.isHidden = true
        btn_voz.isHidden = true
        lb_modoDeJuego.isHidden = true
        
        //Y el alpha se lo ponemos en 0
        //Ponemos los botones transparentes
        btn_texto.alpha = 0.0
        btn_voz.alpha = 0.0
        lb_modoDeJuego.alpha = 0.0
    }
    
    
    //Funcion para animar botones.
    func animarBotones(){
        
        btn_voz.isHidden = false
        btn_texto.isHidden = false
        lb_modoDeJuego.isHidden = false
        
        UIView.animate(withDuration: 1.5, animations: {
            self.lb_modoDeJuego.alpha = 1.0
        })
        
        
        UIView.animate(withDuration: 2.0, animations: {
            self.btn_voz.alpha = 1.0
            self.btn_texto.alpha = 1.0
        })
    }
    
    //Metodo que suma a la progress bar.
    func sumarAProgressbar(){
        progresoBarra = progresoBarra + (1/niveles)
        self.progressBar.progress = Float(progresoBarra)
        
        if progresoBarra >= 1.0{
            self.progressBar.progress = 1.0
        }
    }
    
    
    
    //METODO QUE VA A SUBIR LOS DATOS A NUESTRA DB:
    func uploadToDatabase(ruta: String, claseRecibida: String) -> Bool {
        
        //Buscamos el path
        if let path = Bundle.main.path(forResource: ruta, ofType: "txt") {
            
            do {
                //Si lo encontramos, lo guardamos en data
                let data = try String(contentsOfFile: path, encoding: .utf8)
                
                //Lo separamos linea a linea
                allMyData = data.components(separatedBy: "\r\n") as [String]
                
                //Si el path es correcto, procedemos a recorrerlo y guardarlo en la base de datos.
                
                //Creamos una variable externa
                var variableExterna = 0 //por cada vuelta del bucle externa
                //la variable externa es i * 2
                
                print("$$$$····$$$$$$·····$$$$····$$$")
                print(ruta)
                print("$$$$····$$$$$$·····$$$$····$$$")
                
                
                //TRIANGULO------------------------------
                
                //Recibimos el parametro String
                if(claseRecibida == "Triangulo"){
                    
                    //Recorremos el txt que hemos recibido
                    for i in 0...((allMyData.count/3) - 1){
                        
                        //Creamos un objeto (que será una entidad) para ir subiendo los elementos.
                        var preguntaItem = PreguntasTrianguloVoz(context: managedObjectContext)
                        
                        //Con esto podemos ir de 0,1,2 / 3,4,5 / .... ( que es la estructura del txt).
                        variableExterna = i * 3
                        
                        //Metodo para pintar nada mas.
                        print("Mi index es: " + String(i))
                        print(allMyData[variableExterna])
                        print(allMyData[variableExterna + 1])
                        print(allMyData[variableExterna + 2])
                        print("---------------------------------------")
                        
                       //Esto es lo importante
                        //La subida a la base de datos.
                        preguntaItem.letra = allMyData[variableExterna]
                        preguntaItem.palabra = allMyData[variableExterna + 1]
                        preguntaItem.respuesta = allMyData[variableExterna + 2]
                        //subimos todo a la base de datos en false: ninguno ha sido utilizado.
                        preguntaItem.usado = false
                        
                        //Cacheamos esta subida a la base de datos.
                        do{
                            //con el metodo Save (lo podemos encontrar en el app delegate).
                            try self.managedObjectContext.save()
                            print("Pregunta saved")
                        }catch{
                            //Cacheamos
                            print("Data wasnt saved")
                            print(error)
                        }
                    }
                    
                    //Si ha ido todo bien, lo printeamos y devolvemos un true arriba del todo.
                    print("Data de " + ruta + " correctamente salvada")
                    return true
                    
                }
                
                //TRAPECIO------------------------------
                if(claseRecibida == "Trapecio"){
                    
                    for i in 0...((allMyData.count/3) - 1){
                        
                        var preguntaItem = PreguntasTrapecioVoz(context: managedObjectContext)
                        
                        variableExterna = i * 3
                        
                        print("Mi index es: " + String(i))
                        print(allMyData[variableExterna])
                        print(allMyData[variableExterna + 1])
                        print(allMyData[variableExterna + 2])
                        print("---------------------------------------")
                        
                        //Subimos a la base de datos.
                        preguntaItem.letra = allMyData[variableExterna]
                        preguntaItem.palabra = allMyData[variableExterna + 1]
                        preguntaItem.respuesta = allMyData[variableExterna + 2]
                        
                        do{
                            try self.managedObjectContext.save()
                            print("Pregunta saved")
                        }catch{
                            print("Data wasnt saved")
                        }
                    }
                    print("Data de " + ruta + " correctamente salvada")
                    return true
                }

                //CUADRADO------------------------------
                if(claseRecibida == "Cuadrado"){
                    
                    for i in 0...((allMyData.count/3) - 1){
                        
                        var preguntaItem = PreguntasCuadradoVoz(context: managedObjectContext)
                        
                        variableExterna = i * 3
                        
                        print("Mi index es: " + String(i))
                        print(allMyData[variableExterna])
                        print(allMyData[variableExterna + 1])
                        print(allMyData[variableExterna + 2])
                        print("---------------------------------------")
                        
                        //Subimos a la base de datos.
                        preguntaItem.letra = allMyData[variableExterna]
                        preguntaItem.palabra = allMyData[variableExterna + 1]
                        preguntaItem.respuesta = allMyData[variableExterna + 2]
                        
                        do{
                            try self.managedObjectContext.save()
                           print("Pregunta saved")
                        }catch{
                            print("Data wasnt saved")
                        }
                    }
                     print("Data de " + ruta + " correctamente salvada")
                    return true
                }
                
                //ROMBO------------------------------
                if(claseRecibida == "Rombo"){
                    
                    for i in 0...((allMyData.count/3) - 1){
                        
                        var preguntaItem = PreguntasRomboVoz(context: managedObjectContext)
                        
                        variableExterna = i * 3
                        
                        print("Mi index es: " + String(i))
                        print(allMyData[variableExterna])
                        print(allMyData[variableExterna + 1])
                        print(allMyData[variableExterna + 2])
                        print("---------------------------------------")
                        
                        //Subimos a la base de datos.
                        preguntaItem.letra = allMyData[variableExterna]
                        preguntaItem.palabra = allMyData[variableExterna + 1]
                        preguntaItem.respuesta = allMyData[variableExterna + 2]
                        
                        
                        do{
                            try self.managedObjectContext.save()
                             print("Pregunta saved")
                        }catch{
                            print("Data wasnt saved")
                            return false
                        }
                    }
                    print("Data de " + ruta + " correctamente salvada")
                    return true
                }
                
                //RECTANGULO------------------------------
                if(claseRecibida == "Rectangulo"){
                    
                    for i in 0...((allMyData.count/3) - 1){
                        
                        var preguntaItem = PreguntasRomboVoz(context: managedObjectContext)
                        
                        variableExterna = i * 3
                        
                        print("Mi index es: " + String(i))
                        print(allMyData[variableExterna])
                        print(allMyData[variableExterna + 1])
                        print(allMyData[variableExterna + 2])
                        print("---------------------------------------")
                        
                        //Subimos a la base de datos.
                        
                        preguntaItem.letra = allMyData[variableExterna]
                        preguntaItem.palabra = allMyData[variableExterna + 1]
                        preguntaItem.respuesta = allMyData[variableExterna + 2]
                        
                        do{
                            try self.managedObjectContext.save()
                            print("Pregunta saved")
                        }catch{
                            print("Data wasnt saved")
                            return false
                        }
                    }
                    print("Data de " + ruta + " correctamente salvada")
                    return true
                }
                
                //TRIANGULO TEXTO-----------------------------
                if(claseRecibida == "TrianguloTexto"){
                    
                    for i in 0...((allMyData.count/5) - 1){
                        
                        var preguntaItem = PreguntasTrianguloTexto(context: managedObjectContext)
                        
                        variableExterna = i * 5
                        
                        print("Mi index es: " + String(i))
                        
                        print(allMyData[variableExterna])
                        print(allMyData[variableExterna + 1])
                        print(allMyData[variableExterna + 2])
                        print(allMyData[variableExterna + 3])
                        print(allMyData[variableExterna + 4])
                        print("---------------------------------------")
                        
                        //Subimos a la base de datos.
                        
                        preguntaItem.letra = allMyData[variableExterna]
                        preguntaItem.correcta = allMyData[variableExterna + 1]
                        preguntaItem.erronea1 = allMyData[variableExterna + 2]
                        preguntaItem.erronea2 = allMyData[variableExterna + 3]
                        preguntaItem.definicion = allMyData[variableExterna + 4]
                        
                        do{
                            try self.managedObjectContext.save()
                            print("Pregunta saved")
                        }catch{
                            print("Data wasnt saved")
                            return false
                        }
                    }
                    print("Data de " + ruta + " correctamente salvada")
                    return true
                }
            } catch {
                print(error)
                return false
            }
        } else {
            print("ruta no encontrada")
            return false
        }
        
        return false
    }

    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
    
    
    
    /*
     M O S T R A R     D A T O S
     */
    
    
    @IBAction func mostrarDatosTriangulo(_ sender: Any) {
        
        //Declaro el tipo de variable FetchRequest
        let preguntaResquest:NSFetchRequest<PreguntasTrianguloVoz> = PreguntasTrianguloVoz.fetchRequest()
        
        //Try and catch para ver si funciona el cargado de datos
        
        do{
           
            //Mostrar preguntas triangulo
            var arr_preguntasTriangulo = [PreguntasTrianguloVoz]()
            arr_preguntasTriangulo = try managedObjectContext.fetch(preguntaResquest)
            print("data succesfully loaded")
            print(arr_preguntasTriangulo.count)
            
        } catch {
            print("Error loading data")
        }

    }
    
    
    
    @IBAction func mostrarDatosTrapecio(_ sender: Any) {
        
        //Declaro el tipo de variable FetchRequest
        let preguntaResquest:NSFetchRequest<PreguntasTrapecioVoz> = PreguntasTrapecioVoz.fetchRequest()
        
        //Try and catch para ver si funciona el cargado de datos
        
        do{
            
           
            var arr_preguntasTrapecio = [PreguntasTrapecioVoz]()
            arr_preguntasTrapecio = try managedObjectContext.fetch(preguntaResquest)
            print("data succesfully loaded")
            
            
            print(arr_preguntasTrapecio.count)
            
        } catch {
            
            print("Error loading data")
        }
    
    }
    
    
    
    
    @IBAction func mostrarDatosCuadrado(_ sender: Any) {
        
        
        
        //Declaro el tipo de variable FetchRequest
        let preguntaResquest:NSFetchRequest<PreguntasCuadradoVoz> = PreguntasCuadradoVoz.fetchRequest()
        
        //Try and catch para ver si funciona el cargado de datos
        
        do{
             var arr_preguntasCuadrado = [PreguntasCuadradoVoz]()
           
            arr_preguntasCuadrado = try managedObjectContext.fetch(preguntaResquest)
            print("data succesfully loaded")
            
            
            print(arr_preguntasCuadrado.count)
            
        } catch {
            
            print("Error loading data")
        }
    }
    
    
    
    
  
    @IBAction func mostrarRombo(_ sender: Any) {
        
        
        //Declaro el tipo de variable FetchRequest
        let preguntaResquest:NSFetchRequest<PreguntasRomboVoz> = PreguntasRomboVoz.fetchRequest()
        //Try and catch para ver si funciona el cargado de datos
        do{
            var arr_preguntasRombo = [PreguntasRomboVoz]()
            arr_preguntasRombo = try managedObjectContext.fetch(preguntaResquest)
            print("data succesfully loaded")
            print(arr_preguntasRombo.count)
            
        } catch {
            print("Error loading data")
        }
    }
    
    
    
    
    @IBAction func mostrarRectanguo(_ sender: Any) {
        
        //Declaro el tipo de variable FetchRequest
        let preguntaResquest:NSFetchRequest<PreguntasRectanguloVoz> = PreguntasRectanguloVoz.fetchRequest()
        //Try and catch para ver si funciona el cargado de datos
        do{
            var arr_preguntasRectangulo = [PreguntasRectanguloVoz]()
            arr_preguntasRectangulo = try managedObjectContext.fetch(preguntaResquest)
            print("data succesfully loaded")
            print(arr_preguntasRectangulo.count)
            
        } catch {
            print("Error loading data")
        }
    }
    
    
    
    
    
    
    
    
    
    @IBAction func borrarDatos(_ sender: Any) {
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PreguntasTrianguloVoz")
        let fetchRequest2 = NSFetchRequest<NSFetchRequestResult>(entityName: "PreguntasTrapecioVoz")
        let fetchRequest3 = NSFetchRequest<NSFetchRequestResult>(entityName: "PreguntasCuadradoVoz")
        let fetchRequest4 = NSFetchRequest<NSFetchRequestResult>(entityName: "PreguntasRomboVoz")
        let fetchRequest5 = NSFetchRequest<NSFetchRequestResult>(entityName: "PreguntasRectanguloVoz")
        
        //borrar triangulo
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedObjectContext.execute(deleteRequest)
            print("Datos borrados correctamente")
        } catch  {
            print("Error en el borrado de datos")
        }
        
        //borrar trapecio
        let deleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        
        do {
            try managedObjectContext.execute(deleteRequest2)
            print("Datos borrados correctamente")
        } catch  {
            print("Error en el borrado de datos")
        }
        
        //borrar cuadrado
        let deleteRequest3 = NSBatchDeleteRequest(fetchRequest: fetchRequest3)
        
        do {
            try managedObjectContext.execute(deleteRequest3)
            print("Datos borrados correctamente")
        } catch  {
            print("Error en el borrado de datos")
        }
        
        //borrar rombo
        let deleteRequest4 = NSBatchDeleteRequest(fetchRequest: fetchRequest4)
        
        do {
            try managedObjectContext.execute(deleteRequest4)
            print("Datos borrados correctamente")
        } catch  {
            print("Error en el borrado de datos")
        }
        
        //borrar rectangulo
        let deleteRequest5 = NSBatchDeleteRequest(fetchRequest: fetchRequest5)
        
        do {
            try managedObjectContext.execute(deleteRequest5)
            print("Datos borrados correctamente")
        } catch  {
            print("Error en el borrado de datos")
        }
    }

    }
    
    
    

            
            
        



