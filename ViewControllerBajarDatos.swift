//
//  ViewControllerBajarDatos.swift
//  PruebaRankingSebastian
//
//  Created by Desarrollo MAC on 16/3/17.
//  Copyright © 2017 Desarrollo MAC. All rights reserved.
//

//IMPORTAMOS LOS ELEMENTOS QUE VAMOS A NECESITAR
import UIKit
import CoreData
import AVFoundation
import AVKit


class ViewControllerBajarDatos: UIViewController {
    
    //View donde se va a reproducir el video
    @IBOutlet weak var viewMecanicaVoz: UIView!
    //Y un controller
    var avpController = AVPlayerViewController()
    //Declaramos una varialble de tipo AVPlayer
    var player: AVPlayer!
    
    //Variables generales del juego
    var modoDeJuego = "ModoVoz"
    var nivelElegido = "Triangulo"
    var oportunidades = 3
    
    //Variable para el timer
    var timerGame = Timer()
    var timer = Timer()
    
    //Variables para la voz
    let speakTalk = AVSpeechSynthesizer()
    var speakText = AVSpeechUtterance()
    
    //Variables para la voz pasadas
    let speakTalkPasado = AVSpeechSynthesizer()
    var speakTextPasado = AVSpeechUtterance()
    
    //Preguntas Voz
    var preguntasVoz = [PreguntasVoz]()
    var preguntasVozNivel = [PreguntasVoz]()
    var preguntasVozLetra = [PreguntasVoz]()
    var preguntasVozLetraSinUsar = [PreguntasVoz]()
    var preguntasVozPasadas = [PreguntasVoz]()
    
    var alert = true
    
    var managedObjectContext:NSManagedObjectContext!    //Objeto para manejar
   
    //Outlets de nuestra view
    //Labels
    @IBOutlet weak var lb_letra: UILabel!
    @IBOutlet weak var lb_tiempo: UILabel!
    @IBOutlet weak var lb_aciertos: UILabel!
    //Botones
    @IBOutlet weak var btn_jugar: UIButton!
    @IBOutlet weak var btn_responder: UIButton!
   
    
    //TextField Respuesta
    @IBOutlet weak var tf_respuesta: UITextField!
    
    //Imagen
    @IBOutlet weak var img_letra: UIImageView!
    

    
    //Triangulo
    let letrasNivelTriangulo = ["A", "B", "C", "D", "E", "F", "G", "H", "J", "L", "M", "O", "P", "R", "S", "T", "U", "Z"]
    
    //Trapecio
     let letrasNivelTrapecio = ["A", "B", "C", "D", "E", "F", "G", "H", "J", "L", "M", "O", "P", "R", "S", "T", "U", "Z"]
    
    //Cuadrado
     let letrasNivelCuadrado = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "L", "M", "O", "P", "R", "S", "T", "U", "V", "Z"]
    
    //Rombo
    let letrasNivelRombo = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "L", "M", "O", "P", "R", "S", "T", "U", "V", "Z"]
    
    //Rectangulo
    let letrasNivelRectangulo = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "L", "M", "N", "Ñ", "O", "P", "Q", "R", "S", "T", "U", "V", "X", "Z"]
    
    
    //letras que vamos a utilizar en nuestros niveles.
    var letrasNivel = ["A", "B", "C", "D", "E", "F", "G", "H", "J", "L", "M", "O", "P", "R", "S", "T", "U", "Z"]
    
   
    
    //Contadores y booleanos para tener el control del flujo de juego.
    var preguntasContestadas = 0
    var contadorPregunta = 0
    var contadorPreguntasPasadas = -1
    var hayOtraRonda = false
    var segundaRonda = false
    var primeraRonda = true
    var partidaEmpezada = false
    
    //variables del juego
    var numeroRandom = 0 //numero random utilizado cuando nos traemos preguntas
    var tiempoRestante = 180
    var aciertos = 0
    var fallos = 0
    let primeraLetra:String = ""
    var fallosPermitidos = 0
 
    
    func ponerImagenDeFondo(){
        
      /*  self.view.backgroundColor = UIColor(patternImage: UIImage(named: "fondo_" + nivelElegido + ".png")!)
        print("fondo_" + nivelElegido + ".png") */
        
    }
    
    
    //View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ponerImagenDeFondo()
        
        
        
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        
        speakText = AVSpeechUtterance(string: "")

        alert = true
        
      
        print("Entra por aqui ***************")
        btn_jugar.isHidden = false
        
        //Escondemos o mostramos los botones que hagan falta para el modo voz
        img_letra.isHidden = false
        
        
        //Escondemos y mostramos algunos botones.
        btn_jugar.isHidden = false
        tf_respuesta.isHidden = true
        btn_responder.isHidden = true
        
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(ViewControllerBajarDatos.animarBoton), userInfo: nil, repeats: true)
        
        //Cargamos los datos.
        loadData()
        
        }
    
    
    func reproducirVideo(){
        
        //Path para nuestro video
        let moviePath = Bundle.main.path(forResource: "v_inicio2", ofType: "mp4")
        if let path = moviePath {
            
            
            let url = NSURL.fileURL(withPath: path)
            let item = AVPlayerItem(url: url)
            
            
            player = AVPlayer(playerItem: item)
            avpController = AVPlayerViewController()
            
            avpController.player = self.player
            avpController.view.frame = viewMecanicaVoz.frame
            avpController.showsPlaybackControls = false
            avpController.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            print(avpController.videoBounds)
            
            addChildViewController(avpController)
            view.addSubview(avpController.view)
            
            
            avpController.view.isUserInteractionEnabled = false
            player.play()
            
            
            //NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            
        } else{
            print("no entra...")
        }
    }
    

    //Recieve memory warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        for _ in 0...50{
            print("estas consumiendo mucha memoria")
        }
    }
    
    //Cargamos los datos
    func loadData(){
        
        
        //Vemos que nivel estamos jugando
        if(nivelElegido == "Triangulo"){
            letrasNivel = letrasNivelTriangulo
        } else if (nivelElegido == "Trapecio"){
            letrasNivel = letrasNivelTrapecio
        } else if(nivelElegido == "Cuadrado"){
            letrasNivel = letrasNivelCuadrado
        } else if(nivelElegido == "Rombo"){
            letrasNivel = letrasNivelRombo
        } else if(nivelElegido == "Cuadrado"){
            letrasNivel = letrasNivelRectangulo
        }
                
        let partidaRequest:NSFetchRequest<PreguntasVoz> = PreguntasVoz.fetchRequest()
        //Try and catch para ver si funciona el cargado de datos
        do{
            
            preguntasVoz = try managedObjectContext.fetch(partidaRequest)
            print(preguntasVoz.count)
            print(nivelElegido)
            
            print("data succesfully loaded")
        } catch {
            print("Error loading data")
        }
    }
    
    
    //Boton de iniciar el juego...
    @IBAction func inicioJuego(_ sender: Any) {
       
        fallos = 0
        aciertos = 0
        fallosPermitidos = Int(oportunidades)
        
        preguntasContestadas = 0
        contadorPregunta = 0
        contadorPreguntasPasadas = -1
      
        //Declaramos tiempo y fallos
        tiempoRestante = 180
            
        //Ejecutamos el timer, lo que va a controlar el tiempo.
        timerGame = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewControllerBajarDatos.restarUno), userInfo: nil, repeats: true)
            
            
        //Ocultamos y mostramos algunos outlets.
        btn_jugar.isHidden = true
            
        btn_responder.isHidden = false
        tf_respuesta.isHidden = false
        lb_tiempo.isHidden = false
        lb_tiempo.text = String(tiempoRestante)
        lb_aciertos.text = String(aciertos)
            
        //Inicializamos algunas variables.
        primeraRonda = true
        preguntasContestadas = 0
            
        //Llamo al metodo que va a poner las preguntas.
        traermePreguntas()
            
        
        
    }
    
    

    //Metodo que va a controlar todo el juego.
    @IBAction func responderPregunta(_ sender: Any) {
        
        speakTalkPasado.stopSpeaking(at: AVSpeechBoundary(rawValue: 0)!)
        
        //Variables que seran la pregunta preguntada y la respuesta del usuario.
        var respuestaUsuario = ""
        var palabraJuego = ""
        
      
        //Si contador pregunta ha llegado justo al final.. pasara lo siguiente
        if(contadorPregunta == letrasNivel.count){
           
            //leemos ambas respuestas
            respuestaUsuario = transformarPalabra(palabraRecibida: tf_respuesta.text!)
            palabraJuego = transformarPalabra(palabraRecibida: preguntasVozLetraSinUsar[numeroRandom].palabra!)
            
            //comprobamos la respuesta
            comprobarRespuesta(respuestaUsuario: respuestaUsuario, palabraJuego: palabraJuego)
            primeraRonda = false //la primera ronda se ha acabado, la ponemos en false
            contadorPregunta = 1000 //y cambiamos el contador para que no vuelva a entrar.
            
        //Si ya se ha acabado la primera ronda...
        } else if(primeraRonda == false) {
            
            //Llamamos a la funcion ponPalabraPasada, que nos devolvera un true siempre y cuando haya mas preguntas para utilizar
            let MasPalabrasUsadas = ponPalabraPasada(sumarUno: 0)
            
            //Si hay mas... comprobamos
            if(MasPalabrasUsadas){
                
                respuestaUsuario = transformarPalabra(palabraRecibida: tf_respuesta.text!)
                palabraJuego = transformarPalabra(palabraRecibida: preguntasVozPasadas[contadorPreguntasPasadas].palabra!)
                //Y llamamos
                comprobarRespuesta(respuestaUsuario: respuestaUsuario, palabraJuego: palabraJuego)
            } else {
                //Si no hay mas, el juego se ha acabado
                juegoAcabado()
            }
            
        } else {
            
            //En este caso, se sigue comprobando preguntas ya que sigue en la primera ronda
            respuestaUsuario = transformarPalabra(palabraRecibida: tf_respuesta.text!)
            palabraJuego = transformarPalabra(palabraRecibida: preguntasVozLetraSinUsar[numeroRandom].palabra!)
            comprobarRespuesta(respuestaUsuario: respuestaUsuario, palabraJuego: palabraJuego)
            
        }
    }
    
    
    
    //Funcion que sirve para comprobar las respuestas.
    func comprobarRespuesta(respuestaUsuario: String, palabraJuego: String){
        
        //Si la palabra que el usuario introduce coincide con palabra buscada...
        if(respuestaUsuario == "A"){
            speakTalk.stopSpeaking(at: AVSpeechBoundary(rawValue: 0)!)
            
            sumarUnoAciertos() //sumamos uno a aciertos
            preguntasContestadas = preguntasContestadas + 1 //sumamos uno a preguntas contestadas.
            continuarJugando() //Y continuamos jugando.
            
        }
    
        if(respuestaUsuario == "B"){
        speakTalk.stopSpeaking(at: AVSpeechBoundary(rawValue: 0)!)
        
        sumarUnoFallos() //suma uno a fallos
            
        preguntasContestadas = preguntasContestadas + 1 //suma uno a preguntas contestadas.
    
        //Si el usuario pasa los fallos permitidos
        if(fallos > fallosPermitidos){
        jugadorPierde(modoPerder: 1)
            }else{
            //Si no, continua jugando.
            
            continuarJugando()
            }
        }
        
        //Si el usuario introduce la palabra siguiente....
        if(respuestaUsuario == "SIGUIENTE"){
            
            speakTalk.stopSpeaking(at: AVSpeechBoundary(rawValue: 0)!)
            //Si es primera ronda, introducimos la palabra que el usuario haya pasado
            
            if(primeraRonda == true){
                preguntasVozPasadas.append(preguntasVozLetraSinUsar[numeroRandom])
            } else {
                //Si el usuario pasa en la segunda ronda, añadimos la palabra que ha pasado.
                preguntasVozPasadas.append(preguntasVozPasadas[contadorPreguntasPasadas - 1])
            }
            //Da igual lo que pase, que tiene que seguir jugando.
            
            continuarJugando()
        }
    }
    
    
    
    //Metodo que sirve para la comprobacion del juego acabado.
    func juegoAcabado(){
        
    
        
        if(fallos > fallosPermitidos){
            jugadorPierde(modoPerder: 1)
        } else {
            jugadorGana()
        }
    }
    
    
    //Metodo que nos permite seguir jugando.
    func continuarJugando(){
        
        //Borramos el array
        borraArrays()
    
        //El usuario ha contestado todo? -> Se acaba tu juego.
        if(preguntasContestadas == letrasNivel.count){
            juegoAcabado()
            
            
        } else { //Si no ha contestado todo y ya estamos en la ultima palabra de la ultima ronda, ponemos palabra pasada.
            if(contadorPregunta == letrasNivel.count){
                _ = ponPalabraPasada(sumarUno: 0)
            } else {
                traermePreguntas() //Si no, traeme preguntas.
            }
        }
        
        tf_respuesta.text = ""
    }
    
    func jugadorGana(){
        
        //Aqui deberia activarse el segue que nos lleva a la pantalla siguiente.
        btn_jugar.isHidden = true
        btn_responder.isHidden = true
        tf_respuesta.isHidden = true
        lb_tiempo.isHidden = true
        lb_aciertos.isHidden = false
        
        //Llamar la funcion de POP UP!
        ponerPopUp(jugadorGana: 1)
    }
    
    func ponerPopUp(jugadorGana: Int){
        
        
        if(jugadorGana == 1){
            
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpID") as! PopUpViewController
            
            self.addChildViewController(popOverVC)
            popOverVC.view.frame = self.view.frame
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParentViewController: self)
            
            //Si gana le mandamos los siguientes datos
            //Aciertos
            popOverVC.aciertos = aciertos
            //Tiempo Utilizado
            popOverVC.tiempoEmpleado = tiempoRestante
            //Forma jugada
            popOverVC.formaHecha = nivelElegido
            //Modo de juego
            popOverVC.modoDeJuego = modoDeJuego
            
        } else {
    
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpErrorID") as! PopUpErrorVozController
            
            self.addChildViewController(popOverVC)
            popOverVC.view.frame = self.view.frame
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParentViewController: self)
        }
    }
    
    
    func jugadorPierde(modoPerder: Int){
        
        
        
        //Escondemos cosas.
        lb_aciertos.isHidden = false
        lb_tiempo.isHidden = true
        tf_respuesta.isHidden = true
        btn_responder.isHidden = true
        btn_jugar.isHidden = true
        
        
        timerGame.invalidate()
        borraArrays()
        ponerPopUp(jugadorGana: 0)
    
    }
    
        
    
    func traermePreguntas(){
        
            //Si el contador de preguntas es menor o igual que la cantidad de preguntas que hay en un nivel...
        
            if(contadorPregunta <= letrasNivel.count){
                
                //Recorremos todos las entidades de nuestro array de preguntas
                for i in 0...preguntasVoz.count - 1 {
                    
                    if(nivelElegido == preguntasVoz[i].nivel){
                        preguntasVozNivel.append(preguntasVoz[i])
                    }
                }
                
                
                for i in 0...preguntasVozNivel.count - 1{
                    
                    if(letrasNivel[contadorPregunta] == preguntasVozNivel[i].letra){
                        preguntasVozLetra.append(preguntasVozNivel[i])
                    }
                }
                
                for i in 0...preguntasVozLetra.count - 1{
                    
                    
                    if(preguntasVozLetra[i].usado == false){
                        preguntasVozLetraSinUsar.append(preguntasVozLetra[i])
                    }
                }
        
                print(preguntasVozLetraSinUsar[0])
                print(preguntasVozLetraSinUsar.count)
                
            
                //Si hay letras para poner....
                if(preguntasVozLetraSinUsar.count > 1){
                    //Ponemos una palabra!
                    ponPalabra() //Ponemos palabra
                    contadorPregunta = contadorPregunta + 1 //Y le sumamos 1
                    
                } else {
                    //Si ya no hay mas letras para poner...
                    //borramos los arrays
                    borraArrays()
                    //Ponemos todas las palabras en false
                    ponerPalabrasEnFalse(letraBuscada: letrasNivel[contadorPregunta])
                    //Y volvemos a llamar a la funcion de dame Palabra
                    traermePreguntas()
            }
        }
    }

    
    //Funcion que hara lo de poner una palabra que hayamos pasado.
    func ponPalabraPasada(sumarUno: Int) -> Bool{
        
        //Si no hay mas palabras.... el juego se acaba.
        if(preguntasVozPasadas.isEmpty == true){
            juegoAcabado()
            return false
            
        } else { //En caso de que si haya mas palabras.
            
        
            
            //Sumamos 1 al contador para que se ponga en 0 (empieza en -1).
            contadorPreguntasPasadas = contadorPreguntasPasadas + 1
            

            //Si llega al final de la palabra, entramos y el contador lo ponemos en el anterior para que no nos de error.
            if(contadorPreguntasPasadas == preguntasVozPasadas.count){
                juegoAcabado()
                contadorPreguntasPasadas = contadorPreguntasPasadas - 1
                return true
            }
            
            //En este caso, el contador es menor, por tanto, si entra. (En este caso seguimos viendo las palabras pasadas).
            if(contadorPreguntasPasadas < preguntasVozPasadas.count){
                
             
                var letra = preguntasVozPasadas[contadorPreguntasPasadas].letra!
                letra = letra.lowercased()
                
                print(letra + "azul.png")
                
                //Los imprimimos por pantalla
              

                speakTextPasado = AVSpeechUtterance(string: preguntasVozPasadas[contadorPreguntasPasadas].respuesta!)
                speakTextPasado.voice = AVSpeechSynthesisVoice(language: "es-ES")
                speakTextPasado.volume = 0.5
                speakTextPasado.rate = 0.52
                speakTextPasado.pitchMultiplier = 1
                
                print("********////********")
                speakTalkPasado.speak(speakTextPasado)
                
                
                return true
            } else {
                juegoAcabado()
                return false
            }
        }
    }
    
    //Funcion que nos dara un random
    func dameRandom(){
        numeroRandom = Int(arc4random_uniform(UInt32(preguntasVozLetraSinUsar.count)))
        if(numeroRandom == 0){
            numeroRandom = numeroRandom + 1
        }
    }
    
    
    
    //Funcion que nos pone una palabra de la primera ronda.
    func ponPalabra(){
        
       //Llamamos a la funcion Random
        dameRandom()
        //activamos la narracion de la pregunta
        speakText = AVSpeechUtterance(string: preguntasVozLetraSinUsar[numeroRandom].respuesta!)
        speakText.voice = AVSpeechSynthesisVoice(language: "es-ES")
        speakText.volume = 0.5
        speakText.rate = 0.52
        speakText.pitchMultiplier = 1
        speakTalk.speak(speakText)
        
        var letra = preguntasVozLetraSinUsar[numeroRandom].letra!
        letra = letra.lowercased()
        
        print(letra + "azul.png")
        
        //Los imprimimos por pantalla
        lb_letra.text =  preguntasVozLetraSinUsar[numeroRandom].letra!
         img_letra.image = UIImage(named: letra + "azul.png")
        print(preguntasVozLetraSinUsar[numeroRandom].palabra!)

        
        }
    
    
    //Funcion super importante: es la que nos pondrá en Usado las palabras de nuestro juego
    func marcarUsada(palabraRecibida: String){
        
        //Recorremos todas las preguntas
        for i in 0...preguntasVozNivel.count - 1{
            
            //Aquellas palabras que acaban de ser utilizadas...
            if(palabraRecibida == preguntasVozNivel[i].palabra){
                
                //La ponemos en USADA en el Array completo
                preguntasVozNivel[i].usado = true
            } else {
            }
        }
    }
    

    //Borra los arrays
    func borraArrays(){
        preguntasVozLetra.removeAll()
        preguntasVozLetraSinUsar.removeAll()
    }
    
    
    
    
    //Pone las palabras que empiezan por la letra "x" en false.
    func ponerPalabrasEnFalse(letraBuscada: String){

        for i in 0...preguntasVozNivel.count - 1{
            if(letraBuscada == preguntasVozNivel[i].letra){
                preguntasVozNivel[i].usado = false
            }
        }
    }
    
    
    
    func sumarUnoAciertos(){
        aciertos = aciertos + 1
        lb_aciertos.text = String(aciertos)
    }
    
    func sumarUnoFallos(){
        fallos = fallos + 1
    }
    //Metodo que resta 1s. Si llega a 0 llamamos a la funcion donde el jugador pierde.
    func restarUno(){
        if(tiempoRestante > 0){
            tiempoRestante = tiempoRestante - 1
            lb_tiempo.text = String(tiempoRestante)
        } else {
            //Le mandamos un 0, el 0 ƒsignifica que se ha quedado sin tiempo.
            jugadorPierde(modoPerder: 0)
        }
    }
    
    //Metodo que transforma la palabra recibida
    func transformarPalabra(palabraRecibida: String) -> String {
        var palabraEnviar =  palabraRecibida.uppercased()
        palabraEnviar = palabraEnviar.folding(options: .diacriticInsensitive, locale: .current)
        return palabraEnviar
    }
    
    
    /*El metodo mas importante de todos... el que realmente actualiza la base de datos con preguntas que han sido utilizadas
     */
    
    
    override func viewDidDisappear(_ animated: Bool) {
        
       /* for i in 0...PreguntasTriangulo.count - 1{
            
            var preguntaItem = PreguntasTrianguloVoz(context: managedObjectContext)
            
        
                preguntaItem.usado = PreguntasTriangulo[i].usado
                
                do{
                    //con el metodo Save (lo podemos encontrar en el app delegate).
                    try self.managedObjectContext.save()
                    print("Pregunta saved")
                }catch{
                    //Cacheamos
                    print("Data wasnt saved")
                    print(error)
                }
            }*/
        }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    
    func animarBoton(){
        

        btn_jugar.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 6.0,
                       options: .allowUserInteraction,
                       animations: { [weak self] in
                        self?.btn_jugar.transform = .identity
            },
                       completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "RankingPropio"{
            
            //Creamos una referencia para el "destination"
            let viewRankingPropio = segue.destination as! RankingPropioViewController
            //Asignamos un valor a la variable
            //Y a la variable string del menu controller le ponemos en Modo Texto
            viewRankingPropio.modoDeJuego = modoDeJuego
            viewRankingPropio.formaHecha = nivelElegido
            
            print("En PARTIDA ENVIAMOS-------------")
            print("Modo de juego " + modoDeJuego)
            print("Nivel actual " + nivelElegido)
            
        }
    }
    
 
   
    
    
    
    
    @IBAction func volver(_ sender: Any) {
    }
    
    

    @IBAction func btn_volver(_ sender: Any) {
        
        player = nil
        self.dismiss(animated: true, completion: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("entra por aqui")
        
        
        //self.dismiss(animated: true, completion: nil)
        //self.removeFromParentViewController()
    }
    
   
    
    

   
    
    
   
 

    
}


    
    

    
    
    
    

  
    






