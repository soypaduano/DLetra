// 9/1/2018
//  DLetra App
//  Created by SEBASTIAN PADUANO (DUWAFARM) on 2018
//  Copyright © 2018 DUWAFARM. All rights reserved.

import UIKit
import CoreData
import AVFoundation
import AVKit
import GoogleMobileAds
import AudioToolbox

class MecanicaTexto: UIViewController, GADBannerViewDelegate, GADInterstitialDelegate {
    
    @IBOutlet weak var img_fondo: UIImageView!
    @IBOutlet weak var viewVideoMenu: UIView! //View donde se va a poner el rosco.
    @IBOutlet weak var viewFundido: UIView! //View para el fundido.
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var img_letrasFondo: UIImageView!
    @IBOutlet weak var img_letra: UIImageView!
    @IBOutlet weak var lb_pregunta: UILabel!
    @IBOutlet weak var lb_tiempo: UILabel!
    @IBOutlet weak var lb_aciertos: UILabel!
    @IBOutlet weak var btn_1: UIButton!
    @IBOutlet weak var btn_2: UIButton!
    @IBOutlet weak var btn_3: UIButton!
    @IBOutlet weak var btn_siguiente: UIButton!
    @IBOutlet weak var btn_jugar: UIButton!
    @IBOutlet weak var btn_volver: UIButton!
    @IBOutlet weak var img_pastilla: UIImageView!

    private var interstitial : GADInterstitial!     //Intersticial
    private var showingInterstitial = Bool() //Variable para ver si se está mostrando el interstitial, así, no se vuelve a mostrar el anuncio del principio
    var player: AVPlayer? //Declaramos una varialble de tipo AVPlayer
    var avpController: AVPlayerViewController? //Y un controller
    var efectoSonido: AVAudioPlayer! //Variable para la voz y los sonidos
    //Variables generales del juego
    var modoDeJuego = Bool()
    var nivelElegido = ""
    var oportunidades = ""
    var modoPerderJugador = Bool()
    var newImage = UIImage()
    var tiempoFundidoNegro = 5
    //Variable para el timer
    var timerGame = Timer()
    var timerAnimacion = Timer()
    //Preguntas Texto
    private var preguntasTextoFinal = [PreguntasTexto]()
    private var preguntasTextoPasadas = [PreguntasTexto]()
    var managedObjectContext:NSManagedObjectContext!    //Objeto para manejar Core
    private var fontSize = CGFloat()
    private var fontSizeReduce = CGFloat()
    //Contadores y booleanos para tener el control del flujo de juego.
    private var preguntasContestadas = 0
    private var contadorPregunta = 0
    private var contadorPreguntasPasadas = -1
    private var primeraRonda = true
    var letrasNivel = [String]()
    //variables del juego
    private var numeroRandom = 0 //numero random utilizado cuando nos traemos preguntas
    private var tiempoRestante = 120
    private var aciertos = 0
    private var fallos = 0
    private var fallosPermitidos = Int()
    
    private func cargarInterstitial(){ //Cargamos el anuncio
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-1913552533139737/8261651805")
        let request: GADRequest = GADRequest()
        interstitial.load(request)
        interstitial.delegate = self
    }
    
    func appMovedToBackground() {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        cargarInterstitial()
        cargarBanner()
        playVideoMenu()
        player?.pause()
        screenSize()
        resizeTextos()
        desactivarBotones(bool: false)
        ponerImagenDeFondo() //Ponemos imagen de fondo
         timerAnimacion = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MecanicaTexto.animarBoton), userInfo: nil, repeats: true)
        loadData() //Cargamos los datos.
    }
    
    private func resizeTextos(){
        lb_pregunta.font = UIFont(descriptor: lb_pregunta.font.fontDescriptor, size: fontSize)
        lb_aciertos.font = UIFont(descriptor: lb_pregunta.font.fontDescriptor, size: fontSize + fontSizeReduce)
        lb_tiempo.font = UIFont(descriptor: lb_pregunta.font.fontDescriptor, size: fontSize + fontSizeReduce)
        btn_1.titleLabel?.font = UIFont(descriptor:  (btn_1.titleLabel?.font.fontDescriptor)!, size: fontSize - fontSizeReduce)
        btn_2.titleLabel?.font = UIFont(descriptor:  (btn_1.titleLabel?.font.fontDescriptor)!, size: fontSize - fontSizeReduce)
        btn_3.titleLabel?.font = UIFont(descriptor:  (btn_1.titleLabel?.font.fontDescriptor)!, size: fontSize - fontSizeReduce)
        btn_siguiente.titleLabel?.font = UIFont(descriptor:  (btn_1.titleLabel?.font.fontDescriptor)!, size: fontSize - fontSizeReduce)
    }
    
    private func screenSize() {
        let screenWidth = self.view.frame.size.width
        switch screenWidth {
        case 320: // iPhone 4 and iPhone 5
            fontSize = 13.0
            fontSizeReduce = 1
        case 375: // iPhone 6 //Iphone7
            fontSize = 15.0
            fontSizeReduce = 1
        case 414: // iPhone 6 Plus // Iphone7Plus
            fontSizeReduce = 1
            fontSize = 16.0
        case 768: // iPad
            fontSize = 30.0
            fontSizeReduce = 5
        case 1024:
            fontSize = 40.0
            fontSizeReduce = 5
        default: // iPad Pro
            fontSize = 10.0
        }
    }
    
    private func desactivarBotones(bool: Bool){
        btn_1.isEnabled = bool
        btn_2.isEnabled = bool
        btn_3.isEnabled = bool
        btn_siguiente.isEnabled = bool
    }
    
    private func fadeInView(withDuration duration: TimeInterval = 0.5) { //Fade in de la view oscura del inicio
        UIView.animate(withDuration: duration, animations: {
            self.viewFundido.alpha = 0.6
        })
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
    
    private func cargarBanner(){
        let request = GADRequest()
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-1913552533139737/4564762602" 
        bannerView.rootViewController = self
        bannerView.load(request)
    }
    
    private func ponerImagenDeFondo(){ //Metodo para poner la imagen de fondo
        img_fondo.image = UIImage(named: "fondo_" + nivelElegido.lowercased() + ".png")!
        guard let image = img_fondo.image, let _ = image.cgImage else {
            return
        }
    }
    
    private func playVideoMenu(){ //Metodo para reproducir video
        var videoname = String()
        videoname = String()
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
        avpController.view.frame = viewVideoMenu.frame
        let avPlayerLayer = AVPlayerLayer(player: avpController.player)
        avPlayerLayer.frame = viewVideoMenu.bounds
        avpController.videoGravity = AVLayerVideoGravityResizeAspectFill
        avpController.player?.isMuted = !UserDefaults.standard.bool(forKey: "sound")
        avpController.showsPlaybackControls = false
        viewVideoMenu.addSubview(avpController.view)
    }
    
    private func loadData () { //Vemos que nivel estamos jugando
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        letrasNivel = Constantes.setLetras(nivelElegido: nivelElegido)
        for index in 0...letrasNivel.count - 1{
            let predicateNivel:NSPredicate = NSPredicate(format: "niveles ==  %@", nivelElegido.uppercased())
            let predicateLetra:NSPredicate = NSPredicate(format: "letra == %@", letrasNivel[index])
            let predicateSinUsar = NSPredicate(format: "usado == %@", NSNumber(value: false))
            let predicate:NSPredicate  = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateNivel, predicateSinUsar, predicateLetra])
            let partidaRequest:NSFetchRequest<PreguntasTexto> = PreguntasTexto.fetchRequest()
            partidaRequest.predicate = predicate
            
            do{    //Try and catch para ver si funciona el cargado de datos
                let preguntasTexto = try managedObjectContext.fetch(partidaRequest)
                if(preguntasTexto.count == 0){
                    ponerPalabrasEnFalse(_letra: letrasNivel[index])
                    preguntasTextoFinal.append(loadQuestionAgain(_letra: letrasNivel[index]))
                } else {
                    preguntasTextoFinal.append(preguntasTexto[Int(arc4random_uniform(UInt32(preguntasTexto.count)))])
                }
            } catch {
            }
        }
    }
    
    private func loadQuestionAgain(_letra: String) -> PreguntasTexto {
        //managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        var pregunta = PreguntasTexto.init(entity: NSEntityDescription.entity(forEntityName: "PreguntasTexto", in: managedObjectContext)!, insertInto: managedObjectContext)
        let predicateNivel:NSPredicate = NSPredicate(format: "niveles ==  %@", nivelElegido.uppercased())
        let predicateLetra:NSPredicate = NSPredicate(format: "letra == %@", _letra)
        let predicateSinUsar = NSPredicate(format: "usado == %@", NSNumber(value: false))
        let predicate:NSPredicate  = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateNivel, predicateSinUsar, predicateLetra])
        let partidaRequest:NSFetchRequest<PreguntasTexto> = PreguntasTexto.fetchRequest()
        partidaRequest.predicate = predicate
        do{    //Try and catch para ver si funciona el cargado de datos
            let preguntasTextoLoad = try managedObjectContext.fetch(partidaRequest)
            print("las preguntas conseguidas de la " + _letra + "SON")
            pregunta = preguntasTextoLoad[Int(arc4random_uniform(UInt32(preguntasTextoLoad.count)))]
            return pregunta
        } catch {
    }
        return pregunta
}

    
    @IBAction func btn_jugar(_ sender: Any) { //Empieza el juego
        desactivarBotones(bool: true)
        viewFundido.isHidden = true
        fallos = 0
        aciertos = 0
        fallosPermitidos = Int(oportunidades)!
        preguntasContestadas = 0
        contadorPregunta = 0
        contadorPreguntasPasadas = -1
        primeraRonda = true
        preguntasContestadas = 0
        tiempoRestante = 120
        //Ejecutamos el timer, lo que va a controlar el tiempo.
        timerGame = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MecanicaTexto.restarUno), userInfo: nil, repeats: true)
        timerAnimacion.invalidate() //Quitamos el timer de la animacion de Play
        btn_jugar.isHidden = true
        lb_tiempo.isHidden = false
        lb_tiempo.text = String(tiempoRestante)
        lb_aciertos.text = String(aciertos)
        traermePreguntas() //Llamo al metodo que va a poner las preguntas.
    }
    
    private func traermePreguntas(){
        if(contadorPregunta <= letrasNivel.count){  //Si el contador de preguntas es menor o igual que la cantidad de preguntas que hay en un nivel...
            if(preguntasTextoFinal.count > 1){ //Si hay letras para poner....
                contadorPregunta = contadorPregunta + 1 //Y le sumamos 1
                ponPalabra() //Ponemos palabra
                
            } else {
                //ponerPalabrasEnFalse() //Ponemos todas las palabras en false
                traermePreguntas()
            }
        }
    }
    
    private func ponerPalabrasEnFalse(_letra: String){
        let predicate1:NSPredicate = NSPredicate(format: "letra ==  %@", _letra)
        let predicate2:NSPredicate = NSPredicate(format: "niveles ==  %@", nivelElegido)
        let predicate:NSPredicate  = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1,predicate2] )
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PreguntasTexto")
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

    private func ponPalabra(){  //Funcion que nos pone una palabra de la primera ronda.
        let palabraActual = preguntasTextoFinal[contadorPregunta - 1].correcta
        
        //Buscamos la palabra y la marcamos como usada.
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PreguntasTexto")
        fetchRequest.predicate = NSPredicate(format: "correcta = %@", palabraActual!)
        
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
    
        if(preguntasTextoFinal[contadorPregunta - 1].letra!  == "Ñ"){
            preguntasTextoFinal[contadorPregunta - 1].letra = "nn"
        }
        
        img_letra.image = UIImage(named: preguntasTextoFinal[contadorPregunta - 1].letra!.lowercased() + "azul.png")
        lb_pregunta.text = preguntasTextoFinal[contadorPregunta - 1].definicion!
      
        //Imprimimos las preguntas.
        var arrayMomentaneo = [String]()
        arrayMomentaneo.append(preguntasTextoFinal[contadorPregunta - 1].correcta!)
        arrayMomentaneo.append(preguntasTextoFinal[contadorPregunta - 1].erronea1!)
        arrayMomentaneo.append(preguntasTextoFinal[contadorPregunta - 1].erronea2!)
        //arrayMomentaneo.shuffle()
        btn_1.setTitle(arrayMomentaneo[0], for: .normal)
        btn_2.setTitle(arrayMomentaneo[1], for: .normal)
        btn_3.setTitle(arrayMomentaneo[2], for: .normal)
        arrayMomentaneo.removeAll() //Lo borramos
    }

    private func ponPalabraPasada() -> Bool{  //Funcion que hara lo de poner una palabra que hayamos pasado.
        if(preguntasTextoPasadas.isEmpty == true){  //Si no hay mas palabras.... el juego se acaba.
            juegoAcabado()
            return false
        } else { //En caso de que si haya mas palabras.
        
            contadorPreguntasPasadas = contadorPreguntasPasadas + 1 //Sumamos 1 al contador para que se ponga en 0 (empieza en -1).
            if(contadorPreguntasPasadas == preguntasTextoPasadas.count){ //Si llega al final de la palabra, entramos y el contador lo ponemos en el anterior para que no nos de error.
                return true
            }

            if(contadorPreguntasPasadas < preguntasTextoPasadas.count){ //En este caso, el contador es menor, por tanto, si entra. (En este caso seguimos viendo las palabras pasadas).
                //Los imprimimos por pantalla
                if(preguntasTextoPasadas[contadorPreguntasPasadas].letra!  == "Ñ"){
                    preguntasTextoPasadas[contadorPreguntasPasadas].letra = "nn"
                }
                
                lb_pregunta.text = preguntasTextoPasadas[contadorPreguntasPasadas].definicion!
                img_letra.image = UIImage(named: preguntasTextoPasadas[contadorPreguntasPasadas].letra!.lowercased() + "azul.png")
                
                var arrayMomentaneo = [String]()
                arrayMomentaneo.append(preguntasTextoPasadas[contadorPreguntasPasadas].correcta!)
                arrayMomentaneo.append(preguntasTextoPasadas[contadorPreguntasPasadas].erronea1!)
                arrayMomentaneo.append(preguntasTextoPasadas[contadorPreguntasPasadas].erronea2!)
                arrayMomentaneo.shuffle()
                btn_1.setTitle(arrayMomentaneo[0], for: .normal)
                btn_2.setTitle(arrayMomentaneo[1], for: .normal)
                btn_3.setTitle(arrayMomentaneo[2], for: .normal)
                return true
            } else {
                return false
            }
        }
    }

    private func usuarioRespondeTexto(palabraRecibida: String){ //Funcion encargada de comparar tanto el resultado como lo escrito

        var palabraJuego = ""
        var respuestaUsuario = palabraRecibida
    
        if(contadorPregunta == letrasNivel.count){ //Si contador pregunta ha llegado justo al final.. pasara lo siguiente
            //leemos ambas respuestas
            respuestaUsuario = transformarPalabra(palabraRecibida: palabraRecibida)
            palabraJuego = transformarPalabra(palabraRecibida: preguntasTextoFinal[contadorPregunta - 1].correcta!)
            
            //comprobamos la respuesta
            comprobarRespuesta(respuestaUsuario: respuestaUsuario, palabraJuego: palabraJuego)
            primeraRonda = false //la primera ronda se ha acabado, la ponemos en false
            contadorPregunta = 1000 //y cambiamos el contador para que no vuelva a entrar.
            
        } else if(primeraRonda == false) {    //Si ya se ha acabado la primera ronda...
            
            let MasPalabrasUsadas = ponPalabraPasada() //Llamamos a la funcion ponPalabraPasada, que nos devolvera un true siempre y cuando haya mas preguntas para utilizar
            
            //Si hay mas... comprobamos
            if(MasPalabrasUsadas){
                
                respuestaUsuario = transformarPalabra(palabraRecibida: palabraRecibida)
                palabraJuego = transformarPalabra(palabraRecibida: preguntasTextoPasadas[contadorPreguntasPasadas - 1].correcta!)
                //Y llamamos
                comprobarRespuesta(respuestaUsuario: respuestaUsuario, palabraJuego: palabraJuego)
            } else {
                //Si no hay mas, el juego se ha acabado
                respuestaUsuario = transformarPalabra(palabraRecibida: palabraRecibida)
                palabraJuego = transformarPalabra(palabraRecibida: preguntasTextoPasadas[contadorPreguntasPasadas - 1].correcta!)
                comprobarRespuesta(respuestaUsuario: respuestaUsuario, palabraJuego: palabraJuego)
                juegoAcabado()
            }
            
        } else { //En este caso, se sigue comprobando preguntas ya que sigue en la primera ronda
            respuestaUsuario = transformarPalabra(palabraRecibida: palabraRecibida)
            palabraJuego = transformarPalabra(palabraRecibida: preguntasTextoFinal[contadorPregunta - 1].correcta!)
            comprobarRespuesta(respuestaUsuario: respuestaUsuario, palabraJuego: palabraJuego)
        }
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
    
    private func mandarFusionarImagenes(f: String){
        if(primeraRonda == false){
            fusionarImagenes(imagenRecibida: preguntasTextoPasadas[contadorPreguntasPasadas - 1].letra! + f)
        } else {
            fusionarImagenes(imagenRecibida: preguntasTextoFinal[contadorPregunta - 1].letra! + f)
        }
    }
    
    private func comprobarRespuesta(respuestaUsuario: String, palabraJuego: String){ //Funcion que sirve para comprobar las respuestas.
    
        if(respuestaUsuario == palabraJuego){ //Si la palabra que el usuario introduce coincide con palabra buscada...
            mandarFusionarImagenes(f: "v")
            if(UserDefaults.standard.bool(forKey: "sound")){  
                reproducirSonido(url: "acierto.wav")
            }
            sumarUnoAciertos() //sumamos uno a aciertos
            preguntasContestadas = preguntasContestadas + 1 //sumamos uno a preguntas contestadas.
            continuarJugando() //Y continuamos jugando.
            
        } else if(respuestaUsuario != palabraJuego && respuestaUsuario != "SIGUIENTE"){
            mandarFusionarImagenes(f: "r")
            sumarUnoFallos() //suma uno a fallos
            preguntasContestadas = preguntasContestadas + 1 //suma uno a preguntas contestadas.
            if(UserDefaults.standard.bool(forKey: "sound")){
                reproducirSonido(url: "fallo.wav")
            }
            if(fallos > fallosPermitidos){ //Si el usuario pasa los fallos permitidos
                juegoAcabado()
            }else{
                //Si no, continua jugando.
                continuarJugando()
            }
        } else if(respuestaUsuario == "SIGUIENTE"){ //Si el usuario introduce la palabra siguiente....
            if(primeraRonda == true){
                preguntasTextoPasadas.append(preguntasTextoFinal[contadorPregunta - 1]) //Si es primera ronda, introducimos la palabra que el usuario haya pasado
            } else {
                preguntasTextoPasadas.append(preguntasTextoPasadas[contadorPreguntasPasadas - 1])  //Si el usuario pasa en la segunda ronda, añadimos la palabra que ha pasado.
            }
            continuarJugando() //Da igual lo que pase, que tiene que seguir jugando.
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
    
    private func transformarPalabra(palabraRecibida: String) -> String {
        var palabraEnviar =  palabraRecibida.uppercased()
        palabraEnviar = palabraEnviar.folding(options: .diacriticInsensitive, locale: .current)
        return palabraEnviar
    }
   
    @IBAction func btn_opcionA(_ sender: Any) {
        usuarioRespondeTexto(palabraRecibida: btn_1.currentTitle!)
    }
    
    @IBAction func btn_opcionB(_ sender: Any) {
        usuarioRespondeTexto(palabraRecibida: btn_2.currentTitle!)
    }
    
    @IBAction func btn_opcionC(_ sender: Any) {
        usuarioRespondeTexto(palabraRecibida: btn_3.currentTitle!)
    }
    
    @IBAction func btn_siguiente(_ sender: Any) {
        usuarioRespondeTexto(palabraRecibida: btn_siguiente.currentTitle!)
        
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
    
    private func continuarJugando(){
        if(preguntasContestadas == letrasNivel.count){  //El usuario ha contestado todo? -> Se acaba tu juego.
            juegoAcabado()
        } else { //Si no ha contestado todo y ya estamos en la ultima palabra de la ultima ronda, ponemos palabra pasada.
            if(contadorPregunta == letrasNivel.count){
                _ = ponPalabraPasada()
            } else {
                traermePreguntas() //Si no, traeme preguntas.
            }
        }
    }
    
    private func jugadorGana(){
        if(UserDefaults.standard.bool(forKey: "sound")){
            reproducirSonido(url: "resultado.wav")
        }
        ponerPopUp(modo: 1) //Si es un uno, jugador gana.
    }
    
    private func sumarUnoAciertos(){
        aciertos = aciertos + 1
        lb_aciertos.text = String(aciertos)
    }
    
    private func sumarUnoFallos(){
        fallos = fallos + 1
        AudioServicesPlaySystemSound(1520) // Actuate `Pop` feedback (strong boom)
        lb_aciertos.shake()
        img_pastilla.shake()
    }
    
    func restarUno(){ //Metodo que resta 1s. Si llega a 0 llamamos a la funcion donde el jugador pierde.
        if(tiempoRestante > 0){
            tiempoRestante = tiempoRestante - 1
            if(tiempoRestante < 11 && tiempoRestante > 0){
                lb_tiempo.textColor = UIColor.red
            }
            lb_tiempo.text = String(tiempoRestante)
        } else {  //Le mandamos un 0, el 0 significa que se ha quedado sin tiempo.
            juegoAcabado()
        }
    }
    
    private func ponerPopUp(modo: Int){
        if(modo == 1){  //SI RECIBE UN 1... ES QUE GANA.
            if(nivelElegido == "RECTANGULO"){ //rECTANGULO
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let secondViewController = storyboard.instantiateViewController(withIdentifier: "VideoFinal") as! VideoFinalController
                secondViewController.aciertos = aciertos
                secondViewController.formaHecha = nivelElegido
                //secondViewController.modoDeJuego = modoDeJuego
                secondViewController.tiempoEmpleado = Constantes.tiempoInicialTexto - tiempoRestante
                self.present(secondViewController, animated: true, completion: nil)
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let rankingViewController = storyboard.instantiateViewController(withIdentifier: "RankingPropio") as! RankingPropioViewController
                rankingViewController.aciertos = aciertos
                rankingViewController.formaHecha = nivelElegido
                rankingViewController.modoDeJuego = modoDeJuego
                rankingViewController.tiempoEmpleado = Constantes.tiempoInicialTexto - tiempoRestante
                self.present(rankingViewController, animated: true, completion: nil)
            }
        } else {   //SI RECIBE UN 0 ES QUE HA PERDIDO
            if(interstitial.isReady){
                showingInterstitial = true
                interstitial.present(fromRootViewController: self)
            }
            
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpErrorTextoID") as! PopUpErrorTextoController
            if(modoPerderJugador){
                popOverVC.modoPerder = "Se ha terminado el tiempo"
                self.addChildViewController(popOverVC)
                popOverVC.view.frame = self.view.frame
                self.view.addSubview(popOverVC.view)
                popOverVC.didMove(toParentViewController: self)
            } else {
                popOverVC.modoPerder = "Has superado el numero de errores."
                self.addChildViewController(popOverVC)
                popOverVC.view.frame = self.view.frame
                self.view.addSubview(popOverVC.view)
                popOverVC.didMove(toParentViewController: self)
            }
        }
    }
    
    private func jugadorPierde(modoPerder: Int){
        lb_pregunta.text = "PREGUNTA"
        btn_1.setTitle("OPCION A", for: .normal)
        btn_2.setTitle("OPCION B", for: .normal)
        btn_3.setTitle("OPCION C", for: .normal)
        timerGame.invalidate()
        if(UserDefaults.standard.bool(forKey: "sound")){
            reproducirSonido(url: "fintiempo.wav")
        }
        newImage = UIImage(named: "letraVacia.png")!
        img_letrasFondo.image = nil
        ponerPopUp(modo: 0)
    }
    
    @IBAction func fromPopUpVolverJugarTexto(segue:UIStoryboardSegue){
        restaurarPreguntas()
        lb_tiempo.textColor = UIColor.black
        animarBoton()
        timerAnimacion = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MecanicaTexto.animarBoton), userInfo: nil, repeats: true)
        lb_tiempo.text = String(Constantes.tiempoInicialTexto)
        lb_aciertos.text = "0"
        btn_jugar.isHidden = false
        desactivarBotones(bool: false)
        player?.seek(to: kCMTimeZero)
        player?.play()
    }
    
    @IBAction func fromPopUpVolverMenuTexto(segue:UIStoryboardSegue){
        self.dismiss(animated: true, completion: nil)
        desactivarBotones(bool: false)
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
    
    private func restaurarPreguntas(){
        preguntasTextoFinal.removeAll()
        preguntasTextoPasadas.removeAll()
        loadData()
    }
    @IBAction func btn_volver(_ sender: Any) {
        viewVideoMenu.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        NotificationCenter.default.removeObserver(self)
        timerGame.invalidate()
        timerAnimacion.invalidate()
        player = nil
        avpController = nil
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
    
    @IBAction func segueAnuncioVidasTiempoTexto(segue:UIStoryboardSegue){
        self.removeFromParentViewController()
        timerAnimacion = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MecanicaTexto.animarBoton), userInfo: nil, repeats: true)
        player?.play()
        timerGame = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MecanicaTexto.restarUnoFundidoNegro), userInfo: nil, repeats: true) //Ejecutamos el contador por si el usuario no se entera que tiene que darle al play
    }
}
