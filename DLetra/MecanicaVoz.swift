// 9/1/2018
//  DLetra App
//  Created by SEBASTIAN PADUANO (DUWAFARM) on 2018
//  Copyright © 2018 DUWAFARM. All rights reserved.

import UIKit
import AVFoundation
import AVKit
import CoreData
import GoogleMobileAds
import Speech
import AudioToolbox

@available(iOS 10.0, *)
class MecanicaVoz: UIViewController, GADBannerViewDelegate, SFSpeechRecognizerDelegate, GADInterstitialDelegate {

    @IBOutlet weak var viewContainer: UIView!  //Declaramos una varialble de tipo AVPlayer
    @IBOutlet weak var fondo_img: UIImageView!
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var img_letrasFondo: UIImageView!
    @IBOutlet weak var viewFundido: UIView!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var tf_palabraDebug: UITextField!
    @IBOutlet weak var lb_tiempo: UILabel!
    @IBOutlet weak var lb_aciertos: UILabel!
    @IBOutlet weak var btn_jugar: UIButton!
    @IBOutlet weak var btn_responder: UIButton!
    @IBOutlet weak var img_letra: UIImageView!
    @IBOutlet weak var view_banner: GADBannerView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tf_respuesta: UITextField!
    @IBOutlet weak var img_aciertos: UIImageView!
    
    
    var newImage = UIImage()  //Imagen donde vamos a poner las imagenes.
    
    //Variables generales del juego
    var modoDeJuego: Bool = false
    var nivelElegido = ""
    var oportunidades = "0"
    private var preguntasContestadas = 0
    private var contadorPregunta = 0
    private var contadorPreguntasPasadas = -1
    private var primeraRonda = true
    //variables del juego
    private var tiempoRestante = 180
    private var aciertos = 0
    private var fallos = 0
    private var fallosPermitidos = Int()
    var timerGame = Timer()
    var timerAnimacion = Timer()
    
    //Variables para la voz pasadas
    var speakTalkPasado = AVSpeechSynthesizer()
    var speakTextPasado = AVSpeechUtterance()
    
    //Preguntas Voz
    private var preguntasVoz = [PreguntasVoz]()
    private var preguntasVozFinal = [PreguntasVoz]()
    private var preguntasVozPasadas = [PreguntasVoz]()
    private var managedObjectContext:NSManagedObjectContext!    //Objeto para manejar la base de datos
    private var modoPerderJugador = Bool()
    private var preguntaRespondida = Bool()
    private var tiempoFundidoNegro = 5
    private var letrasNivel = [String]() //letras que vamos a utilizar en nuestros niveles.
    
    var interstitial : GADInterstitial!     //Intersticial
    var showingInterstitial = Bool() //Variable para ver si se está mostrando el interstitial, así, no se vuelve a mostrar el anuncio del principio
    private var isButtonEnabled = false //Por defecto, desactivamos el boton hasta que la autorizacion haya sido realizada.
    private var audioSession = AVAudioSession()
    private var player: AVPlayer!
    private var avpController: AVPlayerViewController? //Y un controller
    private var efectoSonido: AVAudioPlayer? //Variable para la voz y los sonidos
    private var speakTalk = AVSpeechSynthesizer() //Variables para la voz
    private var speakText = AVSpeechUtterance()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "es-MX"))  //Objetos para controlar el reconocimiento de voz del usuario
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest? //This object handles the speech recognition requests. It provides an audio input to the speech recognizer.
    private var recognitionTask: SFSpeechRecognitionTask? // The recognition task where it gives you the result of the recognition request. Having this object is handy as you can cancel or stop the task.
    private let audioEngine = AVAudioEngine() // This is your audio engine. It is responsible for providing your audio input.
    
    /*private func appMovedToBackground() {
        if(UserDefaults.standard.bool(forKey: "PrimeraVoz")) {
            UserDefaults.standard.set(true, forKey: "PrimeraVoz")
            UserDefaults.standard.synchronize()
            self.dismiss(animated: true, completion: nil)
        }
    }*/
    
    private func cargarInterstitial(){ //Cargamos el anuncio
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-1913552533139737/8261651805")
        let request: GADRequest = GADRequest()
        interstitial.load(request)
        interstitial.delegate = self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let notificationCenter = NotificationCenter.default
        //notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil) TODO: MEJORAR ESTO
        print(nivelElegido + "---------------ESTE ES EL NIVEL ELEGIDO")
        playVideo() //Le damos play al video.
        player.pause()
        resizeTextos()
        ponerImagenDeFondo() //Ponemos imagen de fondo
        cargarInterstitial()
        cargarBanner()
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext  //Declaramos objeto para Managed Object
        comprobarAudioPort()
        listenForNotifications()
        //Comprobamos su conexion a internet.
        /*if(Reachability.isConnectedToNetwork()){
            btn_jugar.isHidden = false
            timerAnimacion = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MecanicaVoz.animarBoton), userInfo: nil, repeats: true)
        } else {
            print("Debes tener internet para jugar") //TODO: Informar al jugador que no puede jugar.
            btn_jugar.isHidden = true
        }*/

        speechRecognizer?.delegate = self  //Este es el objeto que maneja el reconocimiento de voz. //Tenemos que pedir permiso al usuario.
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            switch authStatus {
            case .authorized:
                self.isButtonEnabled = true
               
            case .denied:
                self.isButtonEnabled = false
                self.btn_jugar.isHidden = true
                self.performSegue(withIdentifier: "unwindBackSpeechDenied", sender: self)
            case .restricted:
                self.isButtonEnabled = false
            case .notDetermined:
                self.isButtonEnabled = false
            }
            
            self.iniciarComprobacion()
            OperationQueue.main.addOperation() {
                self.btn_responder.isEnabled = self.isButtonEnabled
            }
        }

        loadData()  //Cargamos los datos de nuestra base de datos
        
    }
    
    
    private func resizeTextos(){
        let fontSize = Constantes.screenSize(screenSize: self.view.frame.size.width)
        lb_aciertos.font = UIFont(descriptor: lb_aciertos.font.fontDescriptor, size: fontSize)
        lb_tiempo.font = UIFont(descriptor: lb_aciertos.font.fontDescriptor, size: fontSize)
    }
    
    private func ponerImagenDeFondo(){ //Metodo para poner la imagen de fondo
        print(nivelElegido)
        fondo_img.image = UIImage(named: "fondo_" + nivelElegido.lowercased() + ".png")!
        guard let image = fondo_img.image, let _ = image.cgImage else {
            return
        }
    }
    
    private func cargarBanner(){
        let request = GADRequest()
        //request.testDevices = [kGADSimulatorID]
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-1913552533139737/4564762602"
        bannerView.rootViewController = self
        bannerView.load(request)
    }
    
    func handleRouteChange(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let reasonRaw = userInfo[AVAudioSessionRouteChangeReasonKey] as? NSNumber,
            let reason = AVAudioSessionRouteChangeReason(rawValue: reasonRaw.uintValue)
            
            else { fatalError("Strange... could not get routeChange") }
        switch reason {
        case .oldDeviceUnavailable:
            print("oldDeviceUnavailable")
        case .newDeviceAvailable:
            print("new device avaiable")
        case .routeConfigurationChange:
            print("routeConfigurationChange")
        case .categoryChange:
            print("categoryChange")
        default:
            print("not handling reason")
        }
    }
    
    func listenForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(_:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
    }
    
    func comprobarAudioPort(){
        let routePort: AVAudioSessionPortDescription? = audioSession.currentRoute.outputs.first
        let portType: String? = routePort?.portType
        
        if (portType == "Receiver") {
            
            do{
                try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            } catch {
                
            }
            
        } else if (portType == "Speaker"){
            
            do{
                try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            } catch {
                
            }
        }
    }
    
    func iniciarComprobacion(){
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        /*Creamos un Audio Session
         Here we set the category of the session as recording, the mode as measurement,
         and activate it. Note that setting these properties may throw an exception,
         so you must put it in a try catch clause.
         */
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, mode: AVAudioSessionModeDefault, options: AVAudioSessionCategoryOptions.interruptSpokenAudioAndMixWithOthers)
        } catch {
          
        }
        comprobarAudioPort()
        // Instantiate the recognitionRequest. Here we create the SFSpeechAudioBufferRecognitionRequest object. Later, we use it to pass our audio data to Apple’s servers.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    
        //Check if the audioEngine (your device) has an audio input for recording. If not, we report a fatal error.
        guard audioEngine.inputNode != nil else {
            fatalError("Audio engine has no input node")
        }
        //Check if the recognitionRequest object is instantiated and is not nil.
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        //Tell recognitionRequest to report partial results of speech recognition as the user speaks.
        recognitionRequest.shouldReportPartialResults = true
        
        /*
         Start the ecognition by calling the recognitionTask method of our speechRecognizer.
         This function has a completion handler. This completion handler will be called every
         time the recognition engine has received input, has refined its current recognition,
         or has been canceled or stopped, and will return a final transcript.
         */
    }
    
    
    func startRecording(){
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        /*Creamos un Audio Session
         Here we set the category of the session as recording, the mode as measurement,
         and activate it. Note that setting these properties may throw an exception,
         so you must put it in a try catch clause.
         */
        
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, mode: AVAudioSessionModeDefault, options: AVAudioSessionCategoryOptions.interruptSpokenAudioAndMixWithOthers)
        } catch {

        }
        comprobarAudioPort()
        // Instantiate the recognitionRequest. Here we create the SFSpeechAudioBufferRecognitionRequest object. Later, we use it to pass our audio data to Apple’s servers.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        
        //Check if the audioEngine (your device) has an audio input for recording. If not, we report a fatal error.
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        //Check if the recognitionRequest object is instantiated and is not nil.ƒ
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        //Tell recognitionRequest to report partial results of speech recognition as the user speaks.
        recognitionRequest.shouldReportPartialResults = true
        
        /*
         Start the ecognition by calling the recognitionTask method of our speechRecognizer.
         This function has a completion handler. This completion handler will be called every
         time the recognition engine has received input, has refined its current recognition,
         or has been canceled or stopped, and will return a final transcript.
         */
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
        
            //Define a boolean to determine if the recognition is final.
            var isFinal = false
            
            // If the result isn’t nil, set the textField property as our result‘s best transcription. Then if the result is the final result, set isFinal to true.
            if result != nil && isFinal == false {
                
             
                let resultado = result?.bestTranscription.formattedString.uppercased().removingWhitespaces()
                self.tf_respuesta.text = resultado
                //TODO: Pon esto en un for.
                    //Articulos que el Speech no reconoce. Si reconoce uno de estos, le dejamoss seguir hablando y juntamos la respeustas.
                    if(self.tf_respuesta.text == "MI" || self.tf_respuesta.text == "EN" || self.tf_respuesta.text == "LE" || self.tf_respuesta.text == "SI" || self.tf_respuesta.text == "OLE" || self.tf_respuesta.text == "SO" || self.tf_respuesta.text == "UN" || self.tf_respuesta.text == "DEL" || self.tf_respuesta.text == "POR" || self.tf_respuesta.text == "MIS" || self.tf_respuesta.text == "MI" || self.tf_respuesta.text == "ENTRE" || self.tf_respuesta.text == "VA" || self.tf_respuesta.text == "HEY" || self.tf_respuesta.text == "VAN" || self.tf_respuesta.text == "Y" || self.tf_respuesta.text == "TE" ||  self.tf_respuesta.text == "YA" || self.tf_respuesta.text == "EN EL" || self.tf_respuesta.text == "MUY" || self.tf_respuesta.text == "PON" || self.tf_respuesta.text == "YDE" || self.tf_respuesta.text == "HOL" || self.tf_respuesta.text == "SE" || self.tf_respuesta.text == "SINO" || self.tf_respuesta.text == "OPA" || self.tf_respuesta.text == "HOLA" || self.tf_respuesta.text == "DE" || self.tf_respuesta.text == "PERO" || self.tf_respuesta.text == "SIN" || self.tf_respuesta.text == "LICO" || self.tf_respuesta.text == "QUE" || self.tf_respuesta.text == "JA" || self.tf_respuesta.text == "TU" || self.tf_respuesta.text == "ME" || self.tf_respuesta.text == "SILO" || self.tf_respuesta.text == "NO" || self.tf_respuesta.text == "UNO"  || self.tf_respuesta.text == "UNA" || self.tf_respuesta.text == "SER" || self.tf_respuesta.text == "SI LE"  || self.tf_respuesta.text == "RE" || self.tf_respuesta.text == "JANI" || self.tf_respuesta.text == "EL" || self.tf_respuesta.text == "VOY" || self.tf_respuesta.text == "LEE" || self.tf_respuesta.text == "JAMA" || self.tf_respuesta.text == "EPA" || self.tf_respuesta.text == "ENEL" || self.tf_respuesta.text == "DUBLÍN"  || self.tf_respuesta.text == "SIDE" || self.tf_respuesta.text == "AMANTE" || self.tf_respuesta.text == "USA" || self.tf_respuesta.text == "EN LA" || self.tf_respuesta.text == "MOCA" || self.tf_respuesta.text == "HAZME" || self.tf_respuesta.text == "FIDEL"){
                
                    } else if(!self.preguntaRespondida) {
                        self.audioEngine.stop()
                        self.btn_responder.setImage(UIImage(named: "micro_verde.png"), for: UIControlState.normal)
                        self.btn_responder.isEnabled = true
                        self.recognitionTask?.cancel()
                        isFinal = true
                        self.responderPreguntaVoz()
                        self.tf_respuesta.text = ""
                        
                    }
                }

            if error != nil || isFinal {
                inputNode.removeTap(onBus: 0)
                self.view.layer.shadowOpacity  = 0.0
                self.btn_responder.isEnabled = true
                return
            }
        })
        
        _ = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.inputFormat(forBus: 0)) { (buffer, when) in
            
            self.recognitionRequest?.append(buffer)
            self.btn_responder.isEnabled = false
            self.view.layer.shadowOpacity  = 0.8
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {

        }
        
        tf_respuesta.placeholder = "Di algo, te escucho."
        
    }
    
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            btn_responder.isEnabled = true
        } else {
            btn_responder.isEnabled = false
        }
    }
    
    private func reproducirSonido(url: String){ //Reproducir sonido de acierto / fallo

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
    
    private func playVideo(){ //Metodo para reproducir video
        var videoname = String()
        if(nivelElegido.lowercased() == "triangulo"){
            videoname = "videotri"
        } else {
            videoname = nivelElegido.lowercased()
        }
        let filepath: String = Bundle.main.path(forResource: videoname, ofType: "mp4")!
        let asset = AVAsset(url: URL(fileURLWithPath: filepath))
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        //Y un controller
        let avpController = AVPlayerViewController()
        avpController.player = self.player
        avpController.view.frame = viewVideo.frame
        let avPlayerLayer = AVPlayerLayer(player: avpController.player)
        avPlayerLayer.frame = viewVideo.bounds
        avpController.videoGravity = AVLayerVideoGravityResizeAspectFill
        avpController.showsPlaybackControls = false
        avpController.player?.isMuted = !UserDefaults.standard.bool(forKey: "sound")
        viewVideo.addSubview(avpController.view)
        player.play()
    }
    
    private func loadData () { //Vemos que nivel estamos jugando
        letrasNivel = Constantes.setLetras(nivelElegido: nivelElegido)
        for index in 0...letrasNivel.count - 1{
            let predicateNivel:NSPredicate = NSPredicate(format: "nivel ==  %@", nivelElegido.uppercased())
            let predicateLetra:NSPredicate = NSPredicate(format: "letra == %@", letrasNivel[index])
            let predicateSinUsar = NSPredicate(format: "usado == %@", NSNumber(value: false))
            let predicate:NSPredicate  = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateNivel, predicateSinUsar, predicateLetra])
            let partidaRequest:NSFetchRequest<PreguntasVoz> = PreguntasVoz.fetchRequest()
            partidaRequest.predicate = predicate
            
            do{    //Try and catch para ver si funciona el cargado de datos
                let preguntasVoz = try managedObjectContext.fetch(partidaRequest)
                if(preguntasVoz.count == 0){
                    print("Ya no quedan palabras de la letra.. " + letrasNivel[index])
                    ponerPalabrasEnFalse(_letra: letrasNivel[index])
                    print("Las hemos puesto en false")
                    preguntasVozFinal.append(loadQuestionAgain(_letra: letrasNivel[index]))
                    print("Las cargamos de nuevo")
                } else {
                    print("Las preguntas de la " + letrasNivel[index] + " son " + String(preguntasVoz.count) )
                    preguntasVozFinal.append(preguntasVoz[Int(arc4random_uniform(UInt32(preguntasVoz.count)))])
                }
            } catch {
            }
        }
    }
    
    private func loadQuestionAgain(_letra: String) -> PreguntasVoz {
        //managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        var pregunta = PreguntasVoz.init(entity: NSEntityDescription.entity(forEntityName: "PreguntasVoz", in: managedObjectContext)!, insertInto: managedObjectContext)
        let predicateNivel:NSPredicate = NSPredicate(format: "nivel ==  %@", nivelElegido.uppercased())
        let predicateLetra:NSPredicate = NSPredicate(format: "letra == %@", _letra)
        let predicateSinUsar = NSPredicate(format: "usado == %@", NSNumber(value: false))
        let predicate:NSPredicate  = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateNivel, predicateSinUsar, predicateLetra])
        let partidaRequest:NSFetchRequest<PreguntasVoz> = PreguntasVoz.fetchRequest()
        partidaRequest.predicate = predicate
        do{    //Try and catch para ver si funciona el cargado de datos
            let preguntasVozLoad = try managedObjectContext.fetch(partidaRequest)
            pregunta = preguntasVozLoad[Int(arc4random_uniform(UInt32(preguntasVozLoad.count)))]
            return pregunta
        } catch {
        }
        return pregunta
    }
    
    @IBAction func btn_inicioJuego(_ sender: Any) {
        viewFundido.isHidden = true
        cargarInterstitial()
        fallos = 0
        aciertos = 0
        fallosPermitidos = Int(oportunidades)!
        contadorPregunta = 0
        contadorPreguntasPasadas = -1
        tiempoRestante = 180  //Declaramos tiempo y fallos
        timerGame = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MecanicaVoz.restarUno), userInfo: nil, repeats: true) //Ejecutamos el timer, lo que va a controlar el tiempo
        btn_jugar.isHidden = true
        btn_responder.isHidden = false
        lb_tiempo.text = String(tiempoRestante)
        lb_aciertos.text = String(aciertos)
        primeraRonda = true
        btn_responder.setImage(UIImage(named: "micro_verde.png"), for: UIControlState.normal)
        btn_responder.isEnabled = true
        traermePreguntas()
    }
    
    
    private func ponerAlert(){
        let alertController = UIAlertController(title: "No disponible", message: "Conectese a una red para acceder.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
        }
        let cancelAction = UIAlertAction(title: "Ajustes", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            let url = URL(string: "App-Prefs:root=WIFI")
            if UIApplication.shared.canOpenURL(url!){
                UIApplication.shared.openURL(url!)
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }


    private func traermePreguntas(){
        if(contadorPregunta <= letrasNivel.count){  //Si el contador de preguntas es menor o igual que la cantidad de preguntas que hay en un nivel...
            if(preguntasVozFinal.count > 1){ //Si hay letras para poner....
                contadorPregunta = contadorPregunta + 1 //Y le sumamos 1
                ponPalabra() //Ponemos palabra
            } else {
                traermePreguntas()
            }
        }
    }
    
    private func ponerPalabrasEnFalse(_letra: String){
        let predicate1:NSPredicate = NSPredicate(format: "letra ==  %@", _letra)
        let predicate2:NSPredicate = NSPredicate(format: "nivel ==  %@", nivelElegido)
        let predicate:NSPredicate  = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1,predicate2] )
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PreguntasVoz")
        fetchRequest.predicate = predicate
        do{
            if let fetchResults = try managedObjectContext.fetch(fetchRequest) as? [NSManagedObject] {
                if fetchResults.count != 0{
                    for index in 0...fetchResults.count - 1{
                        let managedObject = fetchResults[index]
                        managedObject.setValue(false, forKey: "usado")
                    }
                    do{
                        try managedObjectContext.save()
                    } catch {
                    }
                }
            }
        } catch {
        }
    }

    private func ponPalabra(){
        let palabraActual = preguntasVozFinal[contadorPregunta - 1].palabra
        tf_palabraDebug.text = palabraActual
        //Activamos la pregunta
        speakText = AVSpeechUtterance(string: preguntasVozFinal[contadorPregunta - 1].respuesta!)
        speakText.voice = AVSpeechSynthesisVoice(language: "es-ES")
        speakText.volume = 0.5
        speakText.rate = 0.52
        speakText.pitchMultiplier = 1
        //Buscamos la palabra y la marcamos como usada.
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PreguntasVoz")
        fetchRequest.predicate = NSPredicate(format: "palabra = %@", palabraActual!)
        do{
            if let fetchResults = try managedObjectContext.fetch(fetchRequest) as? [NSManagedObject] {
                if fetchResults.count != 0{
                    
                    let managedObject = fetchResults[0]
                    managedObject.setValue(true, forKey: "usado")
                    do{
                        try managedObjectContext.save()
                    } catch {
                    }
                }
            }
        } catch {
        }
        
        if(preguntasVozFinal[contadorPregunta - 1].letra! == "Ñ"){
            preguntasVozFinal[contadorPregunta - 1].letra! = "nn"
        }
        
        img_letra.image = UIImage(named: preguntasVozFinal[contadorPregunta - 1].letra!.lowercased()  + "azul.png")
        speakTalk.speak(speakText)
    }

    private func responderPreguntaVoz(){
        
        //Variables que seran la pregunta preguntada y la respuesta del usuario.
        var respuestaUsuario = ""
        var palabraJuego = ""
        if(contadorPregunta == letrasNivel.count){  //Si contador pregunta ha llegado justo al final.. pasara lo siguiente
            respuestaUsuario = transformarPalabra(palabraRecibida: tf_respuesta.text!).trimmingCharacters(in: .whitespaces)
            palabraJuego = transformarPalabra(palabraRecibida: preguntasVozFinal[contadorPregunta - 1].palabra!).trimmingCharacters(in: .whitespaces)
            
            //comprobamos la respuesta
            comprobarRespuesta(respuestaUsuario: respuestaUsuario, palabraJuego: palabraJuego)
            primeraRonda = false //la primera ronda se ha acabado, la ponemos en false
            tf_respuesta.text = ""
            contadorPregunta = 40 //y cambiamos el contador para que no vuelva a entrar.
        } else if(primeraRonda == false) {
            
            let MasPalabrasUsadas = ponPalabraPasada(sumarUno: 0) //Llamamos a la funcion Pasada, que nos devolvera un true siempre y cuando haya mas preguntas para utilizar
            
            if(MasPalabrasUsadas){ //Si hay mas... comprobamos
                respuestaUsuario = transformarPalabra(palabraRecibida: tf_respuesta.text!)
                palabraJuego = transformarPalabra(palabraRecibida: preguntasVozPasadas[contadorPreguntasPasadas - 1].palabra!)
                //Y llamamos
                comprobarRespuesta(respuestaUsuario: respuestaUsuario, palabraJuego: palabraJuego)
            } else {
                respuestaUsuario = transformarPalabra(palabraRecibida: tf_respuesta.text!)
                palabraJuego = transformarPalabra(palabraRecibida: preguntasVozPasadas[contadorPreguntasPasadas - 1].palabra!)
                //Y llamamos
                comprobarRespuesta(respuestaUsuario: respuestaUsuario, palabraJuego: palabraJuego)
                juegoAcabado()
            }
            
        } else { //En este caso, se sigue comprobando preguntas ya que sigue en la primera ronda
            respuestaUsuario = transformarPalabra(palabraRecibida: tf_respuesta.text!)
            palabraJuego = transformarPalabra(palabraRecibida: preguntasVozFinal[contadorPregunta - 1].palabra!)
            comprobarRespuesta(respuestaUsuario: respuestaUsuario, palabraJuego: palabraJuego)
            tf_respuesta.text = ""
        }
    }

  
    @IBAction func responderPregunta(_ sender: Any) {
        
        stopTalking()
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            btn_responder.isEnabled = false
        } else {
            if(Reachability.isConnectedToNetwork()){
                startRecording()
            } else {
                ponerAlert()
            }
            
            btn_responder.setImage(UIImage(named: "micro_rojo.png"), for: UIControlState.normal)
            btn_responder.isEnabled = false
        }
    }
    
    //Funcion que sirve para comprobar las respuestas.
    private func comprobarRespuesta(respuestaUsuario: String, palabraJuego: String){
        //Aqui creamos posibles palabras que el Speech no reconoce.. por ejemplo, sin la letra final, con H, sustituyendo V/B
        let palabraRespuestaRecortada = String(respuestaUsuario.dropLast())
        let palabraRespuestaConH = "H" + respuestaUsuario
        let palabraRespuestaConL = respuestaUsuario + "L"
        let palabraRespuestaRecortadaPrincipio = String(respuestaUsuario.dropFirst())
        let palabraRespuestaYLL = respuestaUsuario.replacingOccurrences(of: "LL", with: "Y", options: .literal, range: nil)
        let palabraRespuestaSC = respuestaUsuario.replacingOccurrences(of: "C", with: "S", options: .literal, range: nil)
        let palabraRespuestaSZ = respuestaUsuario.replacingOccurrences(of: "S", with: "Z", options: .literal, range: nil)
        let palabraRespuestaconS = respuestaUsuario + "S"
        let palabraRespuestaConN = respuestaUsuario + "N"
        let palabraRespuestaConAR = respuestaUsuario + "AR"
        let palabraRespuestaConVerbo = respuestaUsuario + "R"
        let palabraRespuestaConIFinal = respuestaUsuario + "I"
        let palabraRespuestaInicioT = "T" + palabraRespuestaRecortadaPrincipio
        let palabraRespuestaBV = respuestaUsuario.replacingOccurrences(of: "V", with: "B", options: .literal, range: nil)
        let palabraRespuestaBV2 = respuestaUsuario.replacingOccurrences(of: "B", with: "V", options: .literal, range: nil)
        var palabraRespuestaJG = respuestaUsuario
        var palabraRespuestaVB = respuestaUsuario
        let palabraRespuestaConF = "F" + palabraRespuestaRecortadaPrincipio
        let palabraRespuestaConDPrincipio = "D" + palabraRespuestaRecortadaPrincipio
        let palabraRespuestaConP = "P" + palabraRespuestaRecortadaPrincipio
        
        if(respuestaUsuario.first == "B"){
            palabraRespuestaVB =  "V" + String(palabraRespuestaVB.dropFirst())
        } else {
            palabraRespuestaVB =  "B" + String(palabraRespuestaVB.dropFirst())
          
        }
        
        if(respuestaUsuario.first == "G"){
            palabraRespuestaJG =  "J" + String(palabraRespuestaVB.dropFirst())
        } else {
            palabraRespuestaJG =  "G" + String(palabraRespuestaVB.dropFirst())
            
        }
        
        if(!preguntaRespondida){
            print(respuestaUsuario)
        //Si la palabra que el usuario introduce coincide con palabra buscada...
        if(respuestaUsuario == palabraJuego.trimmingCharacters(in: .whitespaces) || palabraRespuestaRecortada == palabraJuego.trimmingCharacters(in: .whitespaces) || palabraRespuestaConH == palabraJuego.trimmingCharacters(in: .whitespaces) || palabraRespuestaVB == palabraJuego.trimmingCharacters(in: .whitespaces) || palabraRespuestaConL == palabraJuego.trimmingCharacters(in: .whitespaces) || palabraRespuestaRecortadaPrincipio == palabraJuego.trimmingCharacters(in: .whitespaces) || palabraRespuestaYLL == palabraJuego.trimmingCharacters(in: .whitespaces) || palabraRespuestaconS == palabraJuego.trimmingCharacters(in: .whitespaces) || palabraRespuestaJG == palabraJuego.trimmingCharacters(in: .whitespaces) || palabraRespuestaBV == palabraJuego.trimmingCharacters(in: .whitespaces) ||  palabraRespuestaBV2 == palabraJuego.trimmingCharacters(in: .whitespaces) ||  palabraRespuestaConN == palabraJuego.trimmingCharacters(in: .whitespaces) ||  palabraRespuestaSC == palabraJuego.trimmingCharacters(in: .whitespaces) ||  palabraRespuestaInicioT == palabraJuego.trimmingCharacters(in: .whitespaces) ||  palabraRespuestaConAR == palabraJuego.trimmingCharacters(in: .whitespaces) ||  palabraRespuestaConVerbo == palabraJuego.trimmingCharacters(in: .whitespaces) ||  palabraRespuestaConF == palabraJuego.trimmingCharacters(in: .whitespaces) ||  palabraRespuestaSZ == palabraJuego.trimmingCharacters(in: .whitespaces) ||  palabraRespuestaConDPrincipio == palabraJuego.trimmingCharacters(in: .whitespaces) ||  palabraRespuestaConIFinal == palabraJuego.trimmingCharacters(in: .whitespaces) ||  palabraRespuestaConP == palabraJuego.trimmingCharacters(in: .whitespaces)  ) {
            mandarFusionarImagenes(f: "v")
            sumarUnoAciertos() //sumamos uno a acie            rtos
            preguntasContestadas = preguntasContestadas + 1 //sumamos uno a preguntas contestadas.
            continuarJugando() //Y continuamos jugando.
            return
        } else if(respuestaUsuario.trimmingCharacters(in: .whitespaces) != palabraJuego.trimmingCharacters(in: .whitespaces) && respuestaUsuario != "SIGUIENTE") {
            mandarFusionarImagenes(f: "r")
            sumarUnoFallos()
            preguntasContestadas = preguntasContestadas + 1 //suma uno a preguntas contestadas.
            if(fallos > fallosPermitidos){ //Si el usuario pasa los fallos permitidos
                juegoAcabado()
            }else{
                //Si no, continua jugando.
                continuarJugando()
            }
            
            return
        } else if (respuestaUsuario == "SIGUIENTE") {
            if(primeraRonda == true){
                preguntasVozPasadas.append(preguntasVozFinal[contadorPregunta - 1])
            } else {
                //Si el usuario pasa en la segunda ronda, añadimos la palabra que ha pasado.
                preguntasVozPasadas.append(preguntasVozPasadas[contadorPreguntasPasadas - 1])
            }
            continuarJugando() //Da igual lo que pase, que tiene que seguir jugando.
            return
        }
    }
        preguntaRespondida = true
        tf_respuesta.text = nil
        
    }
    
    private func juegoAcabado(){
        if(fallos > fallosPermitidos){
            modoPerderJugador = false
            jugadorPierde(modoPerder: 1) //El modo perder es 1 cuando ha superado los fallos,
        } else if(tiempoRestante <= 0) {
            modoPerderJugador = true
            jugadorPierde(modoPerder: 0) //El modo perder es 0 cuando se queda sin tiempo
        } else {
            jugadorGana()
        }
        timerGame.invalidate()
    }

    private func jugadorPierde(modoPerder: Int){
        btn_responder.isHidden = true
        btn_jugar.isHidden = true
        if(UserDefaults.standard.bool(forKey: "sound")){
            reproducirSonido(url: "fintiempo.wav")
        }
        newImage = UIImage(named: "letraVacia.png")!
        img_letrasFondo.image = nil
        ponerPopUp(modo: 0) //Si es un 0, jugador pierde.
    }
    
    private func jugadorGana(){
        btn_jugar.isHidden = true
        btn_responder.isHidden = true
        ponerPopUp(modo: 1) //Llamar la funcion de POP UP!
    }
    
    private func continuarJugando(){
        sleep(UInt32(1.1))

        if(preguntasContestadas == letrasNivel.count){ //El usuario ha contestado todo? -> Se acaba tu juego.
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
    
    private func sumarUnoAciertos(){
        if(UserDefaults.standard.bool(forKey: "sound")){
            reproducirSonido(url: "acierto.wav")
        }
        aciertos = aciertos + 1
        lb_aciertos.text = String(aciertos)
    }
    
    private func mandarFusionarImagenes(f: String){
        if(primeraRonda == false){
            fusionarImagenes(imagenRecibida: preguntasVozPasadas[contadorPreguntasPasadas - 1].letra! + f)
        } else {
            fusionarImagenes(imagenRecibida: preguntasVozFinal[contadorPregunta - 1].letra! + f)
        }
    }
    
    private func fusionarImagenes(imagenRecibida: String){
        var imagenRecibidaLocal = imagenRecibida.lowercased()
        var letraNivel: String
        if(nivelElegido == "ROMBO"){
            letraNivel = "ro"
        } else if(nivelElegido == "TRAPECIO") {
            letraNivel = "tr"
        } else {
            letraNivel = String(nivelElegido[nivelElegido.index(nivelElegido.startIndex, offsetBy: 0)]).lowercased()
        }
        
        if(imagenRecibidaLocal == "Ñv"){
            imagenRecibidaLocal = "nnv"
        } else if (imagenRecibidaLocal == "Ñr"){
            imagenRecibidaLocal = "nnr"
        }
        
        let bottomImage:UIImage = UIImage(named: letraNivel + imagenRecibidaLocal)!
        let newSize = img_letrasFondo.bounds.size
        
        UIGraphicsBeginImageContext(newSize)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        bottomImage.draw(in: img_letrasFondo.bounds)
        newImage.draw(in: img_letrasFondo.bounds)
        newImage = UIGraphicsGetImageFromCurrentImageContext()!
        img_letrasFondo.isHidden = false
        img_letrasFondo.image = newImage
        UIGraphicsEndImageContext()
    }
    
    private func sumarUnoFallos(){
        if(UserDefaults.standard.bool(forKey: "sound")){
            reproducirSonido(url: "fallo.wav")
        }
        fallos = fallos + 1
        img_aciertos.shake()
        lb_aciertos.shake()
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred() // Actuate `Pop` feedback (strong boom)
    }
    
    
    @IBAction func btn_truco(_ sender: Any) {
        responderPreguntaVoz()
    }
    @objc private func restarUno(){ //Metodo que resta 1s. Si llega a 0 llamamos a la funcion donde el jugador pierde.
        if(tiempoRestante > 0){
            tiempoRestante = tiempoRestante - 1
            if(tiempoRestante < 11 && tiempoRestante > 0){
                 lb_tiempo.textColor = UIColor.red
                 lb_tiempo.text = String(tiempoRestante)
            } else {
                 lb_tiempo.text = String(tiempoRestante)
            }
        } else {
             juegoAcabado()
        }
    }

    func transformarPalabra(palabraRecibida: String) -> String { //Metodo que transforma la palabra recibida
        var palabraEnviar =  palabraRecibida.uppercased()
        palabraEnviar = palabraEnviar.folding(options: .diacriticInsensitive, locale: .current)
        return palabraEnviar
    }

    private func ponPalabraPasada(sumarUno: Int) -> Bool{ //Funcion que hara lo de poner una palabra que hayamos pasado.
        
        //Si no hay mas palabras.... el juego se acaba.
        if(preguntasVozPasadas.isEmpty == true){
            juegoAcabado()
            return false
        } else { //En caso de que si haya mas palabras.
            //Sumamos 1 al contador para que se ponga en 0 (empieza en -1).
            contadorPreguntasPasadas = contadorPreguntasPasadas + 1
            //Si llega al final de la palabra, entramos y el contador lo ponemos en el anterior para que no nos de error.
            if(contadorPreguntasPasadas == preguntasVozPasadas.count){
                return true
            }
            
            //En este caso, el contador es menor, por tanto, si entra. (En este caso seguimos viendo las palabras pasadas).
            if(contadorPreguntasPasadas < preguntasVozPasadas.count){
                speakTextPasado = AVSpeechUtterance(string: preguntasVozPasadas[contadorPreguntasPasadas].respuesta!)
                speakTextPasado.voice = AVSpeechSynthesisVoice(language: "es-ES")
                speakTextPasado.volume = 0.5
                speakTextPasado.rate = 0.52
                speakTextPasado.pitchMultiplier = 1
                if(preguntasVozPasadas[contadorPreguntasPasadas].letra!.lowercased() == "ñ"){
                    preguntasVozPasadas[contadorPreguntasPasadas].letra! = "nn"
                }

                img_letra.image = UIImage(named: preguntasVozPasadas[contadorPreguntasPasadas].letra! + "azul.png")
                speakTalkPasado.speak(speakTextPasado)
                return true
                
            } else {
                return false
            }
        }
    }


    private func ponerPopUp(modo: Int){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if(modo == 1){
            if(nivelElegido == "RECTANGULO"){
                let secondViewController = storyboard.instantiateViewController(withIdentifier: "VideoFinal") as! VideoFinalController
                secondViewController.aciertos = aciertos
                secondViewController.formaHecha = nivelElegido
                secondViewController.modoDeJuego = modoDeJuego
                secondViewController.tiempoEmpleado = Constantes.tiempoInicialVoz - tiempoRestante
                self.present(secondViewController, animated: true, completion: nil)
            } else {
                let rankingViewController = storyboard.instantiateViewController(withIdentifier: "RankingPropio") as! RankingPropioViewController
                rankingViewController.aciertos = aciertos
                rankingViewController.formaHecha = nivelElegido
                rankingViewController.modoDeJuego = modoDeJuego
                rankingViewController.tiempoEmpleado = Constantes.tiempoInicialVoz - tiempoRestante
                self.present(rankingViewController, animated: true, completion: nil)
            }
            
        } else {
            if(interstitial.isReady){
                interstitial.present(fromRootViewController: self)
                showingInterstitial = true
             }
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpErrorID") as! PopUpErrorVozController
            if(modoPerderJugador){ //Si se queda sin tiempo
                popOverVC.modoPerder = "SE HA TERMINADO EL TIEMPO"
            } else { //Si se queda sin fallos
                popOverVC.modoPerder = "HAS SUPERADO EL NUMERO DE ERRORES."
            }
            self.addChildViewController(popOverVC)
            popOverVC.view.frame = self.view.frame
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParentViewController: self)
        }
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
    
    private func eliminarSubviews(){ //removemos la view de los videos.
        viewVideo.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopTalking()
        timerGame.invalidate()
        timerAnimacion.invalidate()
        NotificationCenter.default.removeObserver(self)
        eliminarSubviews()
    }

    override func viewDidAppear(_ animated: Bool) {
        if(!showingInterstitial){
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popUpAnuncio") as! PopUpAnuncioVidas
            self.addChildViewController(popOverVC)
            popOverVC.view.frame = self.view.frame
            self.view.addSubview(popOverVC.view)
            popOverVC.vidas = oportunidades
            popOverVC.tiempo = String(tiempoRestante)
            popOverVC.modoDeJuego = modoDeJuego
        }
    }
    
    
    @IBAction func fromPopUpVolverJugarVoz(segue:UIStoryboardSegue){
        //Cuando vuelve ponemos los valores por defecto.
        restaurarPreguntas()
        efectoSonido = nil
        btn_responder.isEnabled = false
        btn_responder.isHidden = false
        self.btn_responder.setImage(UIImage(named: "micro_negro.png"), for: UIControlState.normal)
        lb_tiempo.textColor = UIColor.black
        lb_aciertos.text = String(letrasNivel.count)
        lb_tiempo.text = String(Constantes.tiempoInicialVoz)
        btn_jugar.isHidden = false
        playVideo()
    }
    
    private func restaurarPreguntas(){
        preguntasVozFinal.removeAll()
        preguntasVozPasadas.removeAll()
        loadData()
    }
    
    @IBAction func fromPopUpVolverMenuVoz(segue:UIStoryboardSegue){
        self.dismiss(animated: true, completion: nil)
    }
    
    func stopTalking(){
        speakTalkPasado.stopSpeaking(at: AVSpeechBoundary(rawValue: 0)!)
        speakTalk.stopSpeaking(at: AVSpeechBoundary(rawValue: 0)!)
    }
    
    //Fade in de la view oscura del inicio
    func fadeInView(withDuration duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration, animations: {
            self.viewFundido.alpha = 0.6
        })
    }
    
  
    @IBAction func btn_atras(_ sender: Any) {
        managedObjectContext = nil
        viewVideo.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        NotificationCenter.default.removeObserver(self)
        timerGame.invalidate()
        timerAnimacion.invalidate()
        player = nil
        avpController = nil
        efectoSonido = nil
        stopTalking()
        if(player == nil && avpController == nil){
            print("Players has been deallocated")
        }
    }
    
    func restarUnoFundidoNegro(){
        tiempoFundidoNegro = tiempoFundidoNegro - 1
        if(tiempoFundidoNegro <= 0){
            fadeInView(withDuration: 0.5)
        }
    }
    
    @IBAction func segueAnuncioVidasTiempoVoz(segue:UIStoryboardSegue){
        self.removeFromParentViewController()
        playVideo()
        timerGame = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MecanicaVoz.restarUnoFundidoNegro), userInfo: nil, repeats: true) //Ejecutamos el contador por si el usuario no se entera que tiene que darle al play
    }
}
