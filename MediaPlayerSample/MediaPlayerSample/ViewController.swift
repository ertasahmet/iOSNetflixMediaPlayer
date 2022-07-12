//
//  ViewController.swift
//  MediaPlayerSample
//
//  Created by Ahmet Ertas on 12.07.2022.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!
    var player: AVPlayer!
    var avpController = AVPlayerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleVideoPlayer()
    }

    // Video oynatma
    private func handleVideoPlayer() {
        let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        player = AVPlayer(url: url!)
        avpController.player = player
        avpController.view.frame.size.height = videoView.frame.size.height
        avpController.view.frame.size.width = videoView.frame.size.width
        self.videoView.addSubview(avpController.view)
        player.play()
    }

}

