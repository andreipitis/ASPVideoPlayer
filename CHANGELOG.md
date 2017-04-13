# Change Log
All notable changes to this project will be documented in this file.

## [2.0.2] - 2017-04-13
### Changed
- Updated UI Tests.

### Fixed
- Strong references to `self` in closures.
  - Fixed by [Rob Phillips](https://github.com/iwasrobbed) in Pull Request [#8](https://github.com/andreipitis/ASPVideoPlayer/pull/8)

## [2.0.1] - 2016-12-18
### Added
- UI Tests.
- More Unit Tests.
- Image to README.

### Changed
- Access for some variables and functions from `fileprivate` to `internal`.

## [2.0.0] - 2016-12-16
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

## [1.2.0] - 2016-10-13

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
