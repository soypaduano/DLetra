//
//  ViewControllerVoiceRecog.swift
//  PruebaRankingSebastian
//
//  Created by Desarrollo MAC on 24/3/17.
//  Copyright © 2017 Desarrollo MAC. All rights reserved.
//

/*
 

import UIKit
import Speech

class ViewControllerVoiceRecog: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var btn_grabar: UIButton!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "es-ES"))
    
    @IBOutlet weak var tf_textoVoice: UITextField!
    
    //Objetos para controlar el reconocimiento de voz del usuario
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest? //This object handles the speech recognition requests. It provides an audio input to the speech recognizer.
    private var recognitionTask: SFSpeechRecognitionTask? // The recognition task where it gives you the result of the recognition request. Having this object is handy as you can cancel or stop the task.
    private let audioEngine = AVAudioEngine() // This is your audio engine. It is responsible for providing your audio input.
    
    El reconocimiento de voz será usado para determinar las palabras que dirás al microfono del dispositivo.
    Speech recognition will be used to determine which words you speak into this device's microphone.
    
    //No olvidemos que tenemos que dar los permisos a la app!:
   /* NSMicrophoneUsageDescription – the custom message for authorization of your audio input. Note that Input Audio Authorization will only happen when the user clicks the microphone button.
    NSSpeechRecognitionUsageDescription – the custom message for speech recognition*/
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
         btn_grabar.isEnabled = false
       
        //Tenemos que pedir permiso al usuario.
        speechRecognizer?.delegate = self  //Este es el objeto que maneja el reconocimiento de voz.
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            //Por defecto, desactivamos el boton hasta que la autorizacion haya sido realizada.
            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.btn_grabar.isEnabled = isButtonEnabled
            }
        }
    }
    

    
    
    func startRecording(){
        
        
        /* Vemos si la tarea de reconocimiento esta en proceso. Si no, cancelamos y la ponemos en nil*/
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        
        /*Creamos un Audio Session
         Here we set the category of the session as recording, the mode as measurement, 
         and activate it. Note that setting these properties may throw an exception, 
         so you must put it in a try catch clause.
         */
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
       // Instantiate the recognitionRequest. Here we create the SFSpeechAudioBufferRecognitionRequest object. Later, we use it to pass our audio data to Apple’s servers.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        
        //Check if the audioEngine (your device) has an audio input for recording. If not, we report a fatal error.
        guard let inputNode = audioEngine.inputNode else {
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
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            //Define a boolean to determine if the recognition is final.
            var isFinal = false
            
            // If the result isn’t nil, set the textField property as our result‘s best transcription. Then if the result is the final result, set isFinal to true.
            if result != nil {
                self.tf_textoVoice.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.btn_grabar.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        tf_textoVoice.placeholder = "Di algo, te escucho."
        
    }
    
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            btn_grabar.isEnabled = true
        } else {
            btn_grabar.isEnabled = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func btn_grabar(_ sender: Any) {
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            btn_grabar.isEnabled = false
            btn_grabar.setTitle("Start Recording", for: .normal)
            
        } else {
            
            startRecording()
            
            
            btn_grabar.setTitle("Stop Recording", for: .normal)
        }
    }
}
    
    
    
    
*/
    


