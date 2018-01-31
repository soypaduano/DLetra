// 9/1/2018
//  DLetra App
//  Created by SEBASTIAN PADUANO (DUWAFARM) on 2018
//  Copyright © 2018 DUWAFARM. All rights reserved.

import UIKit
import AVFoundation
import AVKit

class VideoFinalController: UIViewController {

    var formaHecha = String()
    var tiempoEmpleado = Int()
    var aciertos = Int()
    var modoDeJuego = Bool()
    var player: AVPlayer! //Declaramos una varialble de tipo AVPlayer
    var avpController = AVPlayerViewController() //Y un controller
    var efectoSonido: AVAudioPlayer? //Variable para los sonidos
    
    @IBOutlet weak var viewVideo: UIView!

    func playerDidFinishPlaying(note: NSNotification) { //Cuando se termine de ejecutar el video, lanzamos el segue.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rankingViewController = storyboard.instantiateViewController(withIdentifier: "RankingPropio") as! RankingPropioViewController
        rankingViewController.aciertos = aciertos
        rankingViewController.formaHecha = formaHecha
        rankingViewController.modoDeJuego = modoDeJuego
        rankingViewController.tiempoEmpleado = tiempoEmpleado
        self.present(rankingViewController, animated: true, completion: nil)
    } 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playVideoMenu()
    }
    
    private func playVideoMenu(){
        let moviePath = Bundle.main.path(forResource: "video_rectangulo", ofType: "mp4")
        if let path = moviePath{
            let url = NSURL.fileURL(withPath: path)
            let item = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem: item)
            self.avpController = AVPlayerViewController()
            self.avpController.player = self.player
            avpController.view.frame = viewVideo.frame
            avpController.showsPlaybackControls = false
            avpController.videoGravity = AVLayerVideoGravityResize
            self.addChildViewController(avpController)
            self.view.addSubview(avpController.view)
            avpController.view.isUserInteractionEnabled = false
            avpController.player?.isMuted = !UserDefaults.standard.bool(forKey: "sound")
            player.play()
            NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
}
