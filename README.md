# ASPVideoPlayer

[![CI Status](http://img.shields.io/travis/andreipitis/ASPVideoPlayer.svg?style=flat)](https://travis-ci.org/andreipitis/ASPVideoPlayer)
[![codebeat badge](https://codebeat.co/badges/0901c849-d9a7-4b2f-901b-7aa804e9da4b)](https://codebeat.co/projects/github-com-andreipitis-aspvideoplayer)
[![codecov](https://codecov.io/gh/andreipitis/ASPVideoPlayer/branch/master/graph/badge.svg)](https://codecov.io/gh/andreipitis/ASPVideoPlayer)
[![Version](https://img.shields.io/cocoapods/v/ASPVideoPlayer.svg?style=flat)](http://cocoapods.org/pods/ASPVideoPlayer)
[![License](https://img.shields.io/cocoapods/l/ASPVideoPlayer.svg?style=flat)](http://cocoapods.org/pods/ASPVideoPlayer)
[![Platform](https://img.shields.io/cocoapods/p/ASPVideoPlayer.svg?style=flat)](http://cocoapods.org/pods/ASPVideoPlayer)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

There are two objects you can use to display a video:

 1. `ASPVideoPlayer`
 2. `ASPVideoPlayerView`
 
### 1. ASPVideoPlayer

![aspvideoplayer](https://github.com/andreipitis/ASPVideoPlayer/blob/master/ASPVideoPlayer.gif?raw=true)

`ASPVideoPlayer` is a full video player with UI controls. 

You should use this if you just want to display videos in a player with controls such as play, pause, scrub, next, previous.

- You can instantiate the object from code:

```swift
let videoPlayer = ASPVideoPlayer()
```

- You can also instantiate it from Interface Builder and create an IBOutlet:

```swift
@IBOutlet weak var videoPlayer: ASPVideoPlayer!
```

- Once you have the reference, you can set the video URLs, the gravity and whether the videos should loop:

```swift
let firstVideoURL = Bundle.main.url(forResource: "video", withExtension: "mp4")
let secondVideoURL = Bundle.main.url(forResource: "video2", withExtension: "mp4")

videoPlayer.videoURLs = [firstVideoURL!, secondVideoURL!]

videoPlayer.gravity = .aspectFit

videoPlayer.shouldLoop = true
```

### 2. ASPVideoPlayerView
 
`ASPVideoPlayerView` is a component that `ASPVideoPlayer` uses to display the video, but you can also use it by itself. 

It's a simple UIView with no UI elements.

If you wish to implement your own video player, or want a simple component to display a single video with no other UI elements, you should use this.

- You can instantiate the object from code:

```swift
let videoPlayer = ASPVideoPlayerView()
```

- You can also instantiate it from Interface Builder and create an IBOutlet:

```swift
@IBOutlet weak var videoPlayer: ASPVideoPlayerView!
```

- Once you have the reference, you can set a video url and use the closures to handle different events:

```swift
let videoURL = Bundle.main.url(forResource: "video", withExtension: "mp4")

videoPlayer.videoURL = videoURL

videoPlayer.readyToPlayVideo = {
  print("Video has been successfully loaded and can be played.")
}
    
videoPlayer.startedVideo = {
  print("Video has started playing.")			
}
```

## Installation

ASPVideoPlayer is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ASPVideoPlayer"
```

## Author

Andrei-Sergiu Pitis, andrei.pitis@lateral-inc.com

## License

ASPVideoPlayer is available under the MIT license. See the LICENSE file for more info.
