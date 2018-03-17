//
//  ASPVideoPlayer.swift
//  ASPVideoPlayer
//
//  Created by Andrei-Sergiu Pițiș on 09/12/2016.
//  Copyright © 2016 Andrei-Sergiu Pițiș. All rights reserved.
//

import UIKit
import AVFoundation

/**
 A video player implementation with basic functionality.
 */
@IBDesignable open class ASPVideoPlayer: UIView {
    public struct Configuration {
        /**
         The gravity of the video. Adjusts how the video fills the space of the container.
         */
        let videoGravity: ASPVideoPlayerView.PlayerContentMode

        /**
         Sets whether the playlist should loop. Once the last video has finished playing, the first one will start.
         */
        let shouldLoop: Bool

        /**
         Sets whether the video should start automatically after it has been successfuly loaded.
         */
        let startPlayingWhenReady: Bool

        /**
         Sets whether the video controls should be hidden initially.
         */
        let controlsInitiallyHidden: Bool

        public init(videoGravity: ASPVideoPlayerView.PlayerContentMode = .aspectFit, shouldLoop: Bool = false, startPlayingWhenReady: Bool = false, controlsInitiallyHidden: Bool = false) {
            self.videoGravity = videoGravity
            self.shouldLoop = shouldLoop
            self.startPlayingWhenReady = startPlayingWhenReady
            self.controlsInitiallyHidden = controlsInitiallyHidden
        }

        public static func `default`() -> Configuration {
            return Configuration(videoGravity: .aspectFit, shouldLoop: false, startPlayingWhenReady: false, controlsInitiallyHidden: false)
        }
    }

    // MARK: - Private Variables and Constants -

    fileprivate var videoPlayerView: ASPVideoPlayerView!

    /**
     Work item used to hide the controls with a delay.
     */
    private var controlsToggleWorkItem: DispatchWorkItem?

    // MARK: - Public Variables -

    /**
     Sets the controls to use for the player. By default the controls are ASPVideoPlayerControls.
     */
    open var videoPlayerControls: ASPBasicControls! {
        didSet {
            videoPlayerControls.videoPlayer = videoPlayerView
            updateControls(videoPlayerControls)
        }
    }

    /**
     The duration of the fade animation.
     */
    open var fadeDuration = 0.3

    /**
     Sets the preferred player rate. (ex. 0.5x, 1x, 2x, etc).

     The default value is 1.0
     */
    open var preferredRate: Float {
        set {
            videoPlayerView.preferredRate = newValue
        }
        get {
            return videoPlayerView.preferredRate
        }
    }

    /**
     An array of URLs that the player will load. Can be local or remote URLs. Do not use videoURLs and videoAssets together, only use one of the arrays.
     */
    open var videoURLs: [URL] = [] {
        didSet {
            videoPlayerView.videoURL = videoURLs.first
        }
    }

    /**
     An array of video assets that the player will load. Do not use videoURLs and videoAssets together, only use one of the arrays.
     */
    open var videoAssets: [AVAsset] = [] {
        didSet {
            videoPlayerView.videoAsset = videoAssets.first
        }
    }

    /**
     The current configuration of the video player.
     */
    open var configuration: Configuration = .default() {
        didSet {
            videoPlayerView.gravity = configuration.videoGravity
            videoPlayerView.shouldLoop = configuration.shouldLoop

            videoPlayerView.startPlayingWhenReady = configuration.startPlayingWhenReady
            if configuration.startPlayingWhenReady == true {
                if configuration.controlsInitiallyHidden == false {
                    perform(#selector(ASPVideoPlayer.hideControls), with: nil, afterDelay: 3.0)
                } else {
                    videoPlayerControls.alpha = 0.0
                }
            }
        }
    }

    /**
     Sets the callback method for the resize button action. You should implement your layout resizing code here and use weak references where appropriate to prevent retain cycles.
     */
    open var resizeClosure: ((Bool) -> Void)? {
        set {
            videoPlayerControls.didPressResizeButton = newValue
        }
        get {
            return videoPlayerControls.didPressResizeButton
        }
    }

    /**
     Sets the color of the controls.
     */
    override open var tintColor: UIColor! {
        didSet {
            videoPlayerControls.tintColor = tintColor
        }
    }

    // MARK: - Superclass methods -

    public override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    // MARK: - Private methods -

    @objc internal func toggleControls() {
        if videoPlayerControls.alpha == 1.0 && videoPlayerView.status == .playing {
            hideControls()
        } else {
            controlsToggleWorkItem?.cancel()
            controlsToggleWorkItem = DispatchWorkItem(block: { [weak self] in
                self?.hideControls()
            })

            showControls()

            if videoPlayerView.status == .playing {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: controlsToggleWorkItem!)
            }
        }
    }

    internal func showControls() {
        UIView.animate(withDuration: fadeDuration, animations: {
            self.videoPlayerControls.alpha = 1.0
        })
    }

    @objc internal func hideControls() {
        UIView.animate(withDuration: fadeDuration, animations: {
            self.videoPlayerControls.alpha = 0.0
        })
    }

    private func updateControls(_ controls: ASPBasicControls) {
        videoPlayerControls.tintColor = tintColor

        updateControlsNewVideoAction(controls)
        updateControlsFinishedVideoAction(controls)
        updateControlsNextButtonAction(controls)
        updateControlsPreviousButtonAction(controls)
        updateControlsInteractingAction(controls)
    }

    private func updateControlsNewVideoAction(_ controls: ASPBasicControls) {
        controls.newVideo = { [weak self] in
            guard let strongSelf = self else { return }

            if let videoURL = strongSelf.videoPlayerView.videoURL {
                if let currentURLIndex = strongSelf.videoURLs.index(of: videoURL) {
                    strongSelf.videoPlayerControls.nextButtonHidden = currentURLIndex == strongSelf.videoURLs.count - 1
                    strongSelf.videoPlayerControls.previousButtonHidden = currentURLIndex == 0
                }
            } else if let videoAsset = strongSelf.videoPlayerView.videoAsset {
                if let currentURLIndex = strongSelf.videoAssets.index(of: videoAsset) {
                    strongSelf.videoPlayerControls.nextButtonHidden = currentURLIndex == strongSelf.videoAssets.count - 1
                    strongSelf.videoPlayerControls.previousButtonHidden = currentURLIndex == 0
                }
            }
        }
    }

    private func updateControlsFinishedVideoAction(_ controls: ASPBasicControls) {
        controls.finishedVideo = { [weak self] in
            guard let strongSelf = self else { return }

            if let videoURL = strongSelf.videoPlayerView.videoURL {
                if videoURL == strongSelf.videoURLs.last {
                    if strongSelf.videoPlayerView.shouldLoop == true {
                        strongSelf.videoPlayerView.videoURL = strongSelf.videoURLs.first
                    }
                } else {
                    let currentURLIndex = strongSelf.videoURLs.index(of: videoURL)
                    let nextURL = strongSelf.videoURLs[currentURLIndex! + 1]

                    strongSelf.videoPlayerView.videoURL = nextURL
                }
            } else if let videoAsset = strongSelf.videoPlayerView.videoAsset {
                if videoAsset == strongSelf.videoAssets.last {
                    if strongSelf.videoPlayerView.shouldLoop == true {
                        strongSelf.videoPlayerView.videoAsset = strongSelf.videoAssets.first
                    }
                } else {
                    let currentURLIndex = strongSelf.videoAssets.index(of: videoAsset)
                    let nextAsset = strongSelf.videoAssets[currentURLIndex! + 1]

                    strongSelf.videoPlayerView.videoAsset = nextAsset
                }
            }
        }
    }

    private func updateControlsNextButtonAction(_ controls: ASPBasicControls) {
        controls.didPressNextButton = { [weak self] in
            guard let strongSelf = self else { return }

            if let videoURL = strongSelf.videoPlayerView.videoURL {
                if let currentURLIndex = strongSelf.videoURLs.index(of: videoURL) {
                    let newIndex = (currentURLIndex + 1) % strongSelf.videoURLs.count
                    let nextURL = strongSelf.videoURLs[newIndex]

                    strongSelf.videoPlayerView.videoURL = nextURL
                }
            } else if let videoAsset = strongSelf.videoPlayerView.videoAsset {
                if let currentURLIndex = strongSelf.videoAssets.index(of: videoAsset) {
                    let newIndex = (currentURLIndex + 1) % strongSelf.videoAssets.count
                    let nextAsset = strongSelf.videoAssets[newIndex]

                    strongSelf.videoPlayerView.videoAsset = nextAsset
                }
            }
        }
    }

    private func updateControlsPreviousButtonAction(_ controls: ASPBasicControls) {
        controls.didPressPreviousButton = { [weak self] in
            guard let strongSelf = self else { return }

            if let videoURL = strongSelf.videoPlayerView.videoURL {
                if let currentURLIndex = strongSelf.videoURLs.index(of: videoURL) {
                    let previousIndex = currentURLIndex > 0 ? currentURLIndex : strongSelf.videoURLs.count
                    let nextURL = strongSelf.videoURLs[previousIndex - 1]

                    strongSelf.videoPlayerView.videoURL = nextURL
                }
            } else if let videoAsset = strongSelf.videoPlayerView.videoAsset {
                if let currentURLIndex = strongSelf.videoAssets.index(of: videoAsset) {
                    let previousIndex = currentURLIndex > 0 ? currentURLIndex : strongSelf.videoAssets.count
                    let nextAsset = strongSelf.videoAssets[previousIndex - 1]

                    strongSelf.videoPlayerView.videoAsset = nextAsset
                }
            }
        }
    }

    private func updateControlsInteractingAction(_ controls: ASPBasicControls) {
        controls.interacting = { [weak self] (isInteracting) in
            guard let strongSelf = self else { return }

            strongSelf.controlsToggleWorkItem?.cancel()
            strongSelf.controlsToggleWorkItem = DispatchWorkItem(block: { [weak self] in
                self?.hideControls()
            })

            if isInteracting == true {
                strongSelf.showControls()
            } else {
                if strongSelf.videoPlayerView.status == .playing {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: strongSelf.controlsToggleWorkItem!)
                }
            }
        }
    }

    private func commonInit() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ASPVideoPlayer.toggleControls))
        tapGestureRecognizer.delegate = self
        addGestureRecognizer(tapGestureRecognizer)

        videoPlayerView = ASPVideoPlayerView()
        videoPlayerControls = ASPVideoPlayerControls(videoPlayer: videoPlayerView)
        configuration = .default()

        videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerControls.translatesAutoresizingMaskIntoConstraints = false

        videoPlayerControls.backgroundColor = UIColor.black.withAlphaComponent(0.15)

        updateControls(videoPlayerControls)

        addSubview(videoPlayerView)
        addSubview(videoPlayerControls)

        setupLayout()
    }

    private func setupLayout() {
        let viewsDictionary: [String: Any] = ["videoPlayerView":videoPlayerView,
                                              "videoPlayerControls":videoPlayerControls]

        var constraintsArray = [NSLayoutConstraint]()

        constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[videoPlayerView]|", options: [], metrics: nil, views: viewsDictionary))
        constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[videoPlayerView]|", options: [], metrics: nil, views: viewsDictionary))
        constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[videoPlayerControls]|", options: [], metrics: nil, views: viewsDictionary))
        constraintsArray.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[videoPlayerControls]|", options: [], metrics: nil, views: viewsDictionary))

        addConstraints(constraintsArray)
    }
}

extension ASPVideoPlayer: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view.isDescendant(of: self) == true, view != videoPlayerView,
            view != videoPlayerControls || touch.location(in: videoPlayerControls).y > videoPlayerControls.bounds.size.height - 50 {
            return false
        } else {
            return true
        }
    }
}
