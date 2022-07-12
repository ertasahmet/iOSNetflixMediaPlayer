//
//  NetflixViewController.swift
//  MediaPlayerSample
//
//  Created by Ahmet Ertas on 12.07.2022.
//

import UIKit
import AVKit
import SnapKit

class NetflixViewController: UIViewController {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var remainingTimeLbl: UILabel!
    let playerView = UIView()
    var player: AVPlayer?
    var timeObserver: Any?
    var timer: Timer?
    let playPauseButton = UIButton()
    let forwardButton = UIButton()
    let backwardButton = UIButton()
    
    let videoTitle = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        handleViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupVideoPlayer()
        resetTimer()
        playVideo()
    }
    
    func setupVideoPlayer() {
        guard let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") else {
            return
        }
        player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = playerView.bounds
        playerView.layer.addSublayer(playerLayer)
        
        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { elapsedTime in
            self.updateVideoPlayerSlider()
        })
    }
    
    func playVideo() {
        guard let player = player else { return }
            if !player.isPlaying {
                player.play()
                playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            } else {
                playPauseButton.setImage(UIImage(named: "play"), for: .normal)
                player.pause()
            }
    }

    func updateVideoPlayerSlider() {
        guard let currentTime = player?.currentTime() else { return }
        let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
        slider.value = Float(currentTimeInSeconds)
        if let currentItem = player?.currentItem {
            let duration = currentItem.duration
            if (CMTIME_IS_INVALID(duration)) {
                return;
            }
            let currentTime = currentItem.currentTime()
            slider.value = Float(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))
            
            let totalTimeInSeconds = CMTimeGetSeconds(duration)
            let remainingTimeInSeconds = totalTimeInSeconds - currentTimeInSeconds

            let mins = remainingTimeInSeconds / 60
            let secs = remainingTimeInSeconds.truncatingRemainder(dividingBy: 60)
            let timeformatter = NumberFormatter()
            timeformatter.minimumIntegerDigits = 2
            timeformatter.minimumFractionDigits = 0
            timeformatter.roundingMode = .down
            guard let minsStr = timeformatter.string(from: NSNumber(value: mins)), let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
                return
            }
            let remainingTime = "\(minsStr):\(secsStr)"
            
            let currentTimeTotalSecs = CMTimeGetSeconds(currentTime)
            let time = secondsToTimeString(Int(currentTimeTotalSecs))
            remainingTimeLbl.text = time
        }
        
        
    }
    
    func resetTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(hideControls), userInfo: nil, repeats: false)
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        guard let duration = player?.currentItem?.duration else { return }
            let value = Float64(slider.value) * CMTimeGetSeconds(duration)
            let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
            player?.seek(to: seekTime)
    }
    
}

// MARK: Views
extension NetflixViewController {
    
    private func handleViews() {
        handleGestures()
        handlePlayerView()
        makePlayPauseButton()
        make10SecForwardButton()
        make10SecBackwardButton()
        makeVideoTitleLabel()
    }
    
    private func handleGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleControls))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func handlePlayerView() {
        view.backgroundColor = .black
        view.addSubview(playerView)
        
        playerView.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width)
            make.height.equalTo(view.frame.height)
            make.center.equalTo(view.center)
        }
        
        view.sendSubviewToBack(playerView)
    }
    
    private func makePlayPauseButton() {
        view.addSubview(playPauseButton)
        playPauseButton.setImage(UIImage(named: "play"), for: .normal)
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        
        playPauseButton.snp.makeConstraints { make in
            make.height.equalTo(80)
            make.width.equalTo(80)
            make.center.equalTo(view.center)
        }
        
    }
    
    private func make10SecForwardButton() {
        view.addSubview(forwardButton)
        forwardButton.setImage(UIImage(named: "10sec_forward"), for: .normal)
        forwardButton.addTarget(self, action: #selector(forwardTapped), for: .touchUpInside)
        
        forwardButton.snp.makeConstraints { make in
            make.height.equalTo(80)
            make.width.equalTo(80)
            make.centerY.equalTo(view.center.y)
            make.centerX.equalTo(playPauseButton).offset(200)
        }
        
    }
    
    private func make10SecBackwardButton() {
        view.addSubview(backwardButton)
        backwardButton.setImage(UIImage(named: "10sec_backward"), for: .normal)
        backwardButton.addTarget(self, action: #selector(backwardTapped), for: .touchUpInside)
        
        backwardButton.snp.makeConstraints { make in
            make.height.equalTo(80)
            make.width.equalTo(80)
            make.centerY.equalTo(view.center.y)
            make.centerX.equalTo(playPauseButton).offset(-200)
        }
        
    }
    
    private func makeVideoTitleLabel() {
        
        view.addSubview(videoTitle)
        videoTitle.text = "Big Buck Bunny"
        videoTitle.textColor = .white
        
        videoTitle.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(15)
            make.centerX.equalTo(view.snp.centerX)
        }
        
    }
    
    @objc private func playPauseTapped() {
        playVideo()
    }
    
    @objc private func forwardTapped() {
        guard let currentTime = player?.currentTime() else { return }
            let currentTimeInSecondsPlus10 =  CMTimeGetSeconds(currentTime).advanced(by: 10)
            let seekTime = CMTime(value: CMTimeValue(currentTimeInSecondsPlus10), timescale: 1)
            player?.seek(to: seekTime)
    }
    
    @objc private func backwardTapped() {
        guard let currentTime = player?.currentTime() else { return }
            let currentTimeInSecondsMinus10 =  CMTimeGetSeconds(currentTime).advanced(by: -10)
            let seekTime = CMTime(value: CMTimeValue(currentTimeInSecondsMinus10), timescale: 1)
            player?.seek(to: seekTime)
    }
    
    @objc private func toggleControls() {
        self.playPauseButton.isHidden = !self.playPauseButton.isHidden
        self.slider.isHidden = !self.slider.isHidden
        self.remainingTimeLbl.isHidden = !self.remainingTimeLbl.isHidden
        self.forwardButton.isHidden = !self.forwardButton.isHidden
        self.backwardButton.isHidden = !self.backwardButton.isHidden
        self.videoTitle.isHidden = !self.videoTitle.isHidden
        self.resetTimer()
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func secondsToTimeString(_ seconds: Int) -> String {
        var timeString = ""
        let hour = seconds / 3600
        let minute = (seconds % 3600) / 60
        let second = (seconds % 3600) % 60
        
        if hour < 10 {
            timeString += "0\(hour)"
        } else { timeString += "\(hour)" }
        
        if minute < 10 {
            timeString += ":0\(minute)"
        } else { timeString += ":\(minute)" }
        
        if second < 10 {
            timeString += ":0\(second)"
        } else { timeString += ":\(second)" }
        
        return timeString
    }
    
    @objc func hideControls() {
        playPauseButton.isHidden = true
        slider.isHidden = true
        remainingTimeLbl.isHidden = true
        forwardButton.isHidden = true
        backwardButton.isHidden = true
        videoTitle.isHidden = true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
