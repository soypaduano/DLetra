//  9/1/2018
//  DLetra App
//  Created by SEBASTIAN PADUANO (DUWAFARM) on 2018
//  Copyright © 2018 DUWAFARM. All rights reserved.

import UIKit
import AVFoundation
import AVKit

@available(iOS 8.0, *)
class MenuViewController: UIViewController {
    
    private var player = AVPlayer() //AvPlayer para el video.
    private var avpController = AVPlayerViewController() //AvpController para el video
    var modoDeJuego = Bool() //Modo de juego con el que jugamos.
    
    @IBOutlet weak var btn_sonido: UIButton!
    @IBOutlet weak var viewVideoMenu: UIView! //View para poner el video.
    @IBOutlet weak var btn_jugar: UIButton!
    @IBOutlet weak var btn_ranking: UIButton!
    @IBOutlet weak var btn_volver: UIButton!
    @IBOutlet weak var btn_acercaDe: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playVideoMenu()
        checkSoundStatus()
        self.view.bringSubview(toFront: btn_sonido)
        
    }
    
    private func checkSoundStatus(){
        if(UserDefaults.standard.bool(forKey: "sound")){
            if let image = UIImage(named: "sonido_on.png") {
                btn_sonido.setImage(image, for: .normal)
            }
        } else {
            if let image = UIImage(named: "sonido_off.png") {
                btn_sonido.setImage(image, for: .normal)
            }
        }
    }
    
    private func playVideoMenu(){
        let moviePath = Bundle.main.path(forResource: "v_inicio2", ofType: "mp4")
        if let path = moviePath{
            let url = NSURL.fileURL(withPath: path)
            let item = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem: item)
            self.avpController = AVPlayerViewController()
            self.avpController.player = self.player
            avpController.view.frame = viewVideoMenu.frame
            avpController.showsPlaybackControls = false
            avpController.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.addChildViewController(avpController)
            self.view.addSubview((avpController.view))
            avpController.view.isUserInteractionEnabled = false
            player.play()
        }
    }

   
    @IBAction func btn_acercaDe(_ sender: Any) {  //Boton acerca de
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbContactar") as! PopUpContactoDuwa
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //Preparamos el segue.

       if sender as! UIButton == btn_ranking {
            let viewRankingGeneral = segue.destination as! RankingGeneral
            viewRankingGeneral.modoDeJuego = modoDeJuego
        } else if sender as! UIButton == btn_jugar{
            let viewMenuNiveles = segue.destination as! MenuNiveles
            viewMenuNiveles.modoDeJuego = modoDeJuego
        }
    }

    @IBAction func button_sound(_ sender: Any) {
        UserDefaults.standard.set(!UserDefaults.standard.bool(forKey: "sound"), forKey: "sound")
        checkSoundStatus()
    }
    
    @IBAction func unwindBackRankingGeneral(_ sender: UIStoryboardSegue){
        reproducirVideo()
    }
    
    @IBAction func unwindMenuNiveles(_ sender: UIStoryboardSegue){
        reproducirVideo()
    }

    @IBAction func fromRankingPropio(segue:UIStoryboardSegue){
        reproducirVideo()
    }
    
    private func reproducirVideo(){
       player.seek(to: kCMTimeZero)
       player.play()
    }
}
