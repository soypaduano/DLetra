// 9/1/2018
//  DLetra App
//  Created by SEBASTIAN PADUANO (DUWAFARM) on 2018
//  Copyright © 2017 DUWAFARM. All rights reserved.

import UIKit
import AVFoundation
import AVKit
import CoreData

class VideoLoadingPage: UIViewController {
    
    @IBOutlet weak var videoIntroLayer: UIView! //view donde se va a reproducir el video
    @IBOutlet weak var viewContainer: UIView! //Contenedor que está por fuera del video.
    private var player: AVPlayer! //varialble de tipo AVPlayer
    private var avpController = AVPlayerViewController() //Y un controller
    private var managedObjectContext:NSManagedObjectContext! //Objeto que nos va a dejar manejar la base de datos
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if(!UserDefaults.standard.bool(forKey: "HasLaunchedOnce")){
            UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
            UserDefaults.standard.set(true, forKey: "sound")
            UserDefaults.standard.synchronize()
            bloquearNiveles()
            managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext //Objeto que nos va a dejar manejar la base de datos
            for index in 0...Constantes.arrayFigurasNiveles.count  - 1 {
                print(Constantes.arrayFigurasNiveles[index] + " EN MODO Voz")
                let _ = uploadToDatabase(ruta: "baseDatosPyR" + Constantes.arrayFigurasNiveles[index].lowercased() + "Voz", claseRecibida: Constantes.arrayFigurasNiveles[index].uppercased(), modoJuego: true)
            }
            
            for index in 0...Constantes.arrayFigurasNiveles.count - 1{
                print(Constantes.arrayFigurasNiveles[index] +  " EN MODO TEXTO")
                let _ = uploadToDatabase(ruta: "baseDatosPyR" + Constantes.arrayFigurasNiveles[index].lowercased() + "Texto", claseRecibida: Constantes.arrayFigurasNiveles[index].uppercased(), modoJuego: false)
            }
        }
        
        let moviePath = Bundle.main.path(forResource: "logo", ofType: "mp4")
        if let path = moviePath {
            let url = NSURL.fileURL(withPath: path)
            let item = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem: item)
            self.avpController = AVPlayerViewController()
            self.avpController.player = self.player
            avpController.view.frame = videoIntroLayer.frame
            avpController.view.isUserInteractionEnabled = false
            avpController.showsPlaybackControls = false
            self.addChildViewController(avpController)
            self.view.addSubview(avpController.view)
            viewContainer.addSubview(avpController.view)
            avpController.view.clipsToBounds = true
            avpController.videoGravity = AVLayerVideoGravityResizeAspectFill
            player.play()
            NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        player = nil
    }
    
    //Metodo que pone las preguntas en la base de datos
     private func uploadToDatabase(ruta: String, claseRecibida: String, modoJuego: Bool){
        if let path = Bundle.main.path(forResource: ruta, ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8) //guardamos los datos
                var allMyData = data.components(separatedBy: "\r\n") as [String] //separamos linea a linea
                var variableExterna = 0
                
                if(modoJuego){ //ModoVoz
                for i in 0...((allMyData.count/3) - 1){
                        let preguntaItemDescription = NSEntityDescription.entity(forEntityName: "PreguntasVoz", in: managedObjectContext) //Creamos un objeto (que será una entidad) para ir subiendo los elementos.
                        let preguntaItem = PreguntasVoz.init(entity: preguntaItemDescription!, insertInto: managedObjectContext)
                    
                        variableExterna = i * 3
                        //La subida a la base de datos.
                        preguntaItem.letra = allMyData[variableExterna]
                        preguntaItem.palabra = allMyData[variableExterna + 1]
                        preguntaItem.respuesta = allMyData[variableExterna + 2]
                        //subimos todo a la base de datos en false: ninguno ha sido utilizado.
                        preguntaItem.usado = false
                        preguntaItem.nivel = claseRecibida.uppercased()
                    
                        do{
                            try self.managedObjectContext.save()
                        }catch{
                            print("Ha habido un error subiendo las preguntas de modo Voz")
                        }
                    }
                } else { //Modo Texto
                    
                        for i in 0...((allMyData.count/5) - 1){
                            let preguntaItemDescription = NSEntityDescription.entity(forEntityName: "PreguntasTexto", in: managedObjectContext)
                            //Creamos un objeto (que será una entidad) para ir subiendo los elementos.
                            let preguntaItem = PreguntasTexto.init(entity: preguntaItemDescription!, insertInto: managedObjectContext)
                            
                            variableExterna = i * 5
                            //Subimos a la base de datos.
                            preguntaItem.letra = allMyData[variableExterna]
                            preguntaItem.correcta = allMyData[variableExterna + 1]
                            preguntaItem.erronea1 = allMyData[variableExterna + 2]
                            preguntaItem.erronea2 = allMyData[variableExterna + 3]
                            preguntaItem.definicion = allMyData[variableExterna + 4]
                            preguntaItem.niveles = claseRecibida.uppercased()
                            preguntaItem.usado = false
                            
                            do{
                                try self.managedObjectContext.save()
                            }catch{
                                print("Ha habido un error subiendo las preguntas de modo Texto")
                            }
                        }
                        allMyData.removeAll()
                    }
            } catch {
            }
        } else {
        }
    }
    
    private func bloquearNiveles(){
        UserDefaults.standard.set(false, forKey: Constantes.arrayKeysTexto[0])
        UserDefaults.standard.set(false, forKey: Constantes.arrayKeysVoz[0])
        for index in 1...Constantes.arrayKeysTexto.count - 1{
            UserDefaults.standard.set(true, forKey: Constantes.arrayKeysTexto[index])
            UserDefaults.standard.set(true, forKey: Constantes.arrayKeysVoz[index])
        }
    }
    
    func playerDidFinishPlaying(note: NSNotification) {
        player.pause()
        self.performSegue(withIdentifier: "segueToMenu", sender: self)
        self.removeFromParentViewController()
    }
}
