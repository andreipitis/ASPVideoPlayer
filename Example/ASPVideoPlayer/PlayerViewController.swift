//
//  PlayerViewController.swift
//  ASPVideoPlayer
//
//  Created by Andrei-Sergiu Pițiș on 09/12/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import ASPVideoPlayer
import AVFoundation

class PlayerViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var videoPlayer: ASPVideoPlayer!

    let firstLocalVideoURL = Bundle.main.url(forResource: "video", withExtension: "mp4")
    let secondLocalVideoURL = Bundle.main.url(forResource: "video2", withExtension: "mp4")

    let firstNetworkURL = URL(string: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8")
    let secondNetworkURL = URL(string: "http://www.easy-fit.ae/wp-content/uploads/2014/09/WebsiteLoop.mp4")

    override func viewDidLoad() {
        super.viewDidLoad()
        let firstAsset = AVURLAsset(url: firstLocalVideoURL!)
        let secondAsset = AVURLAsset(url: secondLocalVideoURL!)
        let thirdAsset = AVURLAsset(url: firstNetworkURL!)
        let fourthAsset = AVURLAsset(url: secondNetworkURL!)
        //        videoPlayer.videoURLs = [firstLocalVideoURL!, secondLocalVideoURL!, firstNetworkURL!, secondNetworkURL!]
        videoPlayer.videoAssets = [firstAsset, secondAsset, thirdAsset, fourthAsset]
//        videoPlayer.configuration = ASPVideoPlayer.Configuration(videoGravity: .aspectFit, shouldLoop: true, startPlayingWhenReady: true, controlsInitiallyHidden: true)

        videoPlayer.resizeClosure = { [weak self] isExpanded in
            guard let strongSelf = self else { return }
            strongSelf.isExpanded = isExpanded
            strongSelf.rotate()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    var isExpanded: Bool = false
    var previousConstraints: [NSLayoutConstraint] = []

    func rotate() {
        let views: [String:Any] = ["videoPlayer": videoPlayer]

        if isExpanded == false {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [], animations: {
                self.containerView.removeConstraints(self.videoPlayer.constraints)
                self.view.addSubview(self.videoPlayer)

                let padding = (self.view.bounds.height - self.view.bounds.width) / 2.0

                let metrics: [String:Any] = ["padding":padding, "negativePadding":-padding]

                self.videoPlayer.transform = CGAffineTransform(rotationAngle: .pi / 2.0)

                var constraints: [NSLayoutConstraint] = []
                constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-(negativePadding)-[videoPlayer]-(negativePadding)-|", options: [], metrics: metrics, views: views))

                constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-(padding)-[videoPlayer]-(padding)-|", options: [], metrics: metrics, views: views))

                self.view.addConstraints(constraints)
                self.view.layoutIfNeeded()

                self.previousConstraints = constraints
            }, completion: { finished in
                self.isExpanded = true
            })
        } else {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [], animations: {
                self.view.removeConstraints(self.previousConstraints)
                self.containerView.addSubview(self.videoPlayer)

                self.videoPlayer.transform = CGAffineTransform(rotationAngle: 0.0)

                var constraints: [NSLayoutConstraint] = []

                constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[videoPlayer]|", options: [], metrics: nil, views: views))

                constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[videoPlayer]|", options: [], metrics: nil, views: views))

                self.containerView.addConstraints(constraints)
                self.view.layoutIfNeeded()

                self.previousConstraints = constraints
            }, completion: { finished in
                self.isExpanded = false
            })
        }
    }
}
