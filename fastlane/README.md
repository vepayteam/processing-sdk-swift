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

### ios lintTestCoverage

```sh
[bundle exec] fastlane ios lintTestCoverage
```

Lint, Test and Coverage

### ios sonarQube

```sh
[bundle exec] fastlane ios sonarQube
```

SonarQube Scanner for Build Process

### ios buildVepaySDKExample

```sh
[bundle exec] fastlane ios buildVepaySDKExample
```

Build VEPAY SDK Example app

### ios uploadToBrowserStack

```sh
[bundle exec] fastlane ios uploadToBrowserStack
```

Upload *.ipa to BrowserStack

### ios dumpSharedValues

```sh
[bundle exec] fastlane ios dumpSharedValues
```

Dump Build Shared Values

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
