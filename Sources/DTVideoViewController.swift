//
//  DTVideoViewController.swift
//  DTMediasViewController
//
//  Created by 但 江 on 16/8/31.
//  Copyright © 2016年 Dan Thought Studio. All rights reserved.
//

import UIKit
import AVFoundation

class DTVideoViewController: DTMediaViewController {
  
  var video: DTMedia
  
  fileprivate let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
  fileprivate let playerView = DTPlayerView()
  fileprivate let controlButton = UIButton()
  fileprivate var play = false {
    didSet {
      if oldValue != play {
        if play {
          canAutoPlay = false
          playerView.player?.play()
          controlButton.setImage(DTMediasViewController.imageWithName("pause"), for: .normal)
          showControlButtonWithAutoHidden()
        } else {
          playerView.player?.pause()
          controlButton.setImage(DTMediasViewController.imageWithName("play"), for: .normal)
          controlButton.isHidden = false
        }
      }
    }
  }
  fileprivate var isViewAppear = false
  fileprivate var canAutoPlay = true
  fileprivate var controlButtonHiddenTimer = Timer()
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    playerView.player?.removeObserver(self, forKeyPath: "status")
    NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerView.player?.currentItem)
  }

  init(video: DTMedia) {
    self.video = video
    super.init(nibName: nil, bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.black
    
    layoutPlayerView()
    layoutIndicatorView()
    layoutControlButton()
    
    if let url = video.url {
      indicatorView.startAnimating()
      let player = AVPlayer(url: url)
      player.actionAtItemEnd = .none
      player.addObserver(self, forKeyPath: "status", options:NSKeyValueObservingOptions(), context: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
      playerView.player = player
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    isViewAppear = true
    autoPlay()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    isViewAppear = false
    play = false
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if let keyPath = keyPath {
      if keyPath == "status" {
        if let player = object as? AVPlayer {
          if player.status == .readyToPlay {
            indicatorView.stopAnimating()
            controlButton.isHidden = false
            autoPlay()
          }
        }
      }
    }
  }
  
  func controlPlay() {
    play = !play
  }
  
  func playerDidFinishPlaying(_ note: Notification) {
    play = false
  }
  
  func playerViewSingleTapped(_ recognizer: UITapGestureRecognizer) {
    if play == true {
      showControlButtonWithAutoHidden()
    } else {
      presentingViewController?.dismiss(animated: true, completion: nil)
    }
  }
  
  func hideControlButton() {
    if play == true {
      controlButton.isHidden = true
    }
  }
  
  // MARK: - Private
  
  fileprivate func layoutIndicatorView() {
    indicatorView.hidesWhenStopped = true
    
    view.addSubview(indicatorView)
    
    indicatorView.translatesAutoresizingMaskIntoConstraints = false
    
    let centerX = NSLayoutConstraint(item: indicatorView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
    let centerY = NSLayoutConstraint(item: indicatorView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)

    view.addConstraints([centerX, centerY])
  }
  
  fileprivate func layoutPlayerView() {
    playerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playerViewSingleTapped(_:))))

    view.addSubview(playerView)
    
    playerView.translatesAutoresizingMaskIntoConstraints = false
    
    let leading = NSLayoutConstraint(item: playerView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
    let trailing = NSLayoutConstraint(item: playerView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
    let top = NSLayoutConstraint(item: playerView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
    let bottom = NSLayoutConstraint(item: playerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
    
    view.addConstraints([leading, trailing, top, bottom])
  }
  
  fileprivate func layoutControlButton() {
    controlButton.isHidden = true
    
    controlButton.setImage(DTMediasViewController.imageWithName("play"), for: .normal)
    controlButton.addTarget(self, action: #selector(controlPlay), for: .touchUpInside)
    
    view.addSubview(controlButton)
    
    controlButton.translatesAutoresizingMaskIntoConstraints = false
    
    let centerX = NSLayoutConstraint(item: controlButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
    let centerY = NSLayoutConstraint(item: controlButton, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
    
    view.addConstraints([centerX, centerY])
  }
  
  fileprivate func showControlButtonWithAutoHidden() {
    controlButton.isHidden = false
    controlButtonHiddenTimer.invalidate()
    controlButtonHiddenTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(hideControlButton), userInfo: nil, repeats: false)
  }
  
  fileprivate func autoPlay() {
    if isViewAppear && canAutoPlay {
      play = true
    }
  }
  
}
