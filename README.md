# Vibes SDK example App - iOS

This is an example app using the Vibes SDK. It implements device
registration/unregistration and push registration/unregistration.

- [Requirements](#requirements)
- [Setup](#installation)
- [SDK Usage](#usage)

## Requirements <a name="requirements"></a>

- iOS 9.0+, iOS 10.0+
- Swift 4.1
- CocoaPods 1.3+

## Setup <a name="installation"></a>

[CocoaPods](http://cocoapods.org) is a dependency manager used by the example
app to install the Vibes Push iOS SDK. First, make sure that CocoaPods is
installed using the following command:

```bash
$ pod --version
1.3.1
$
```

If not, you can install it by running the following command:

```bash
$ gem install cocoapods
```

When you have finished installing Cocoapads, go into the example app folder and
run the following command:

```bash
$ pod update
```

This will install all of the necessary dependencies, including the Vibes iOS
SDK.  After the dependencies are installed, you are good to go:

1. Add your Vibes App ID in `AppDelegate.swift`
2. "Run" the app on a device (push notifications are not supported in the iOS
   Simulator)
3.  Check the console to see success or error messages.
