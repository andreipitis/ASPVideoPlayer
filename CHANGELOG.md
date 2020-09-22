# Change Log
All notable changes to this project will be documented in this file.

## [6.1.2](https://github.com/andreipitis/ASPVideoPlayer/releases/tag/6.1.2) - 2020-09-22

### Fixed
- Resize Button appears outside of the player bounds if the player does not fill the entire width of the parent and the `resizeClosure` is not set

## [6.1.0](https://github.com/andreipitis/ASPVideoPlayer/releases/tag/6.1.0) - 2019-10-07

### Added
- `currentTime` property to `ASPVideoPlayer`.

## [6.0.0](https://github.com/andreipitis/ASPVideoPlayer/releases/tag/6.0.0) - 2019-04-25

### Changed
- Updated to Swift 5 by [Roman Gille](https://github.com/r-dent) in Pull Request [#42](https://github.com/andreipitis/ASPVideoPlayer/pull/42)

## [5.0.2](https://github.com/andreipitis/ASPVideoPlayer/releases/tag/5.0.2) - 2018-10-03

### Changed
- Updated to Swift 4.2

## [4.2.0](https://github.com/andreipitis/ASPVideoPlayer/releases/tag/4.2.0) - 2018-07-04

### Added
- New methods to `ASPVideoPlayerViewDelegate` for controls visibility.

### Fixed
- Added missing delegate calls for `error(:)` in `ASPVideoPlayerView`.

## [4.1.0](https://github.com/andreipitis/ASPVideoPlayer/releases/tag/4.1.0) - 2018-07-01

### Added
- Ability to play video sound in background for  `ASPVideoPlayer` and `ASPVideoPlayerView`.
- Delegate to `ASPVideoPlayer` to handle events.

## [4.0.0](https://github.com/andreipitis/ASPVideoPlayer/releases/tag/4.0.0) - 2018-03-17

### Fixed
- `buttonState` return value for `PlayPauseButton` and `ResizeButton`.
- `buttonState` updating UI for `PlayPauseButton`.
- `buttonState` updating UI for `ResizeButton`.
- Animation for `ResizeButton` state change.
- Deallocation delay caused by `perform(selector:afterDelay:)` on `ASPVideoPlayer`

### Added
- Ability to set the controls of `ASPVideoPlayer` as initially hidden.
- Property to set `preferredRate` for both `ASPVideoPlayer` and `ASPVideoPlayerView`

### Changed
- `ASPVideoPlayer` properties are grouped in a `Configuration` structure.
- `ASPVideoPlayer` next and previous actions to wrap around.

## [3.1.0](https://github.com/andreipitis/ASPVideoPlayer/releases/tag/3.1.0) - 2017-12-23

### Fixed
- `buttonState` on `PlayPauseButton` setting the opposite state.
- `buttonState` updating on video player state change using the default controls.
- Autohide delay for the resize action.

### Added
-  `startPlayingWhenReady`property to `ASPVideoPlayer`

## [3.0.1](https://github.com/andreipitis/ASPVideoPlayer/releases/tag/3.0.1) - 2017-10-05

### Fixed
- Length label positioning.
- Resize button not disappearing when closure is not set.

## [3.0.0](https://github.com/andreipitis/ASPVideoPlayer/releases/tag/3.0.0) - 2017-09-17

### Added
- Resize button with callback.
- Ability to use `AVAssets` to set videos.
- Delay for loader animation.
- `VideoPlayerView` rotation.

### Changed
- Updated to Swift 4.
- Updated UI Tests.
- Internal player logic to not create a separate `AVPlayer` for each video

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
- `ASPVideoPlayer` implementation as a full video player with controls.
- `ASPVideoPlayer` Example for the full video player (Set as the default ViewController in the Storyboard).
- Code comments.

### Changed
- Renamed existing `ASPVideoPlayer` to `ASPVideoPlayerView`.
- Updated `ASPVideoPlayerControls` implementation and UI.

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
