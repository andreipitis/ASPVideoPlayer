# Change Log
All notable changes to this project will be documented in this file.

## [3.0.1](https://github.com/andreipitis/ASPVideoPlayer/releases/tag/3.0.1) - 2017-10-05

### Fixed
- Length label positioning
- Resize button not disappearing when closure is not set

## [3.0.0](https://github.com/andreipitis/ASPVideoPlayer/releases/tag/3.0.0) - 2017-09-17

### Added
- Resize button with callback
- Ability to use AVAssets to set videos
- Delay for loader animation
- VideoPlayerView rotation

### Changed
- Updated to Swift 4
- Updated UI Tests.
- Internal player logic to not create a separate AVPlayer for each video

### Fixed
- Strong references to `self` in closures.

## [2.0.2](https://github.com/andreipitis/ASPVideoPlayer/releases/tag/2.0.2) - 2017-04-13
### Changed
- Updated UI Tests.

### Fixed
- Strong references to `self` in closures.
- Fixed by [Rob Phillips](https://github.com/iwasrobbed) in Pull Request [#8](https://github.com/andreipitis/ASPVideoPlayer/pull/8)

## [2.0.1](https://github.com/andreipitis/ASPVideoPlayer/releases/tag/2.0.1) - 2016-12-18
### Added
- UI Tests.
- More Unit Tests.
- Image to README.

### Changed
- Access for some variables and functions from `fileprivate` to `internal`.

## [2.0.0](https://github.com/andreipitis/ASPVideoPlayer/releases/tag/2.0.0) - 2016-12-16
### Added
- Video control UI items (Buttons, Scrubber, Loader).
- ASPVideoPlayer implementation as a full video player with controls.
- ASPVideoPlayer Example for the full video player (Set as the default ViewController in the Storyboard).
- Code comments.

### Changed
- Renamed existing ASPVideoPlayer to ASPVideoPlayerView.
- Updated ASPVideoPlayerControls implementation and UI.

### Removed
- Unused methods throughout the Example.

## [1.2.0](https://github.com/andreipitis/ASPVideoPlayer/releases/tag/1.2.0) - 2016-10-13

### Added
- Second local video resource.
- Example in code for switching videos.
- More unit tests to improve code coverage.
- More code comments.

### Changed
- TravisCI setting to fix the failing CI Builds.
- Failing unit tests.

### Removed
- Unnecessary CGD usage.
