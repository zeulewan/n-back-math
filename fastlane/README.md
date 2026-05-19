fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios create_app

```sh
[bundle exec] fastlane ios create_app
```

Create the App Store Connect app if it does not exist

### ios upload

```sh
[bundle exec] fastlane ios upload
```

Build and upload to App Store Connect

### ios submit

```sh
[bundle exec] fastlane ios submit
```

Submit the latest uploaded build for review

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Upload App Store screenshots only

### ios ship

```sh
[bundle exec] fastlane ios ship
```

Create app, upload, then submit

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
