<H1 align="center">Client</H1>

<H4 align="center">Client for request http/https api</H4>

---

## About Client

__Client__ enable you to request api easly

## Requirements
- Swift 5 / Xcode 10
- OS X 10.14 or later
- iOS 12.0 or later
- watchOS 5.0 or later
- tvOS 12.0 or later

---

## Installation

### [CocoaPods](https://cocoapods.org/)
Add the following to your Podfile:
```ruby
use_frameworks!

target 'YOUR_TARGET_NAME' do
  pod 'Client', :git => 'https://github.com/amine2233/Client.git'
end
```
```sh
$ pod install
```

### [Carthage](https://github.com/Carthage/Carthage)
Add the following to your Cartfile:
```ruby
github "amine2233/Client"
```
```sh
$ carthage update
```

### [Swift Package Manager](https://github.com/Carthage/Carthage)
Add the following to your Package.swift:
```swift
dependencies: [
    // Dependencies declare other packages that this package depends on.
    // ...
    .package(url: "https://github.com/amine2233/Client.git", from: "1.0.0"), // where 1.0.0 is tag version
],
```
```sh
$ swift package update
```

## Basic Example

> Todo: usage exemple

## Contribution
Welcome to fork and submit pull requests!!

Before submitting pull request, please ensure you have passed the included tests.
If your pull request including new function, please write test cases for it.

---

## License
Client is released under the MIT License.
