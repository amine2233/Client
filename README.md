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

### [Swift Package Manager](https://swift.org/package-manager/)
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

## RUN on Linux with Docker

### Running the Docker container

First, download, install, and run Docker Desktop or on Terminal for Mac.

In Terminal, switch to the directory of the Swift package you want to test.

Then run this command:

```Bash
docker run --rm --privileged --interactive --tty \
    --volume "$(pwd):/src" \
    --workdir "/src" \
    swift:latest
```

This tells Docker to create a Linux container with the latest Swift version installed and open a shell in it. The first time you run it, Docker will need a few seconds to download the image for the container; subsequent runs will be instantaneous.


```
# Older Swift versions
To test on older Swift versions, replace swift:latest with a different tag, e.g. swift:5.0. The Docker Hub page for the official Swift image lists all available tags for released Swift versions.

# Prerelease Swift versions
Recently, the Swift CI team has also begun to publish nightly Swift builds to Docker. For instance, use the swiftlang/swift:nightly-5.2-bionic image to test your code on the latest Swift 5.2 snapshot. The available tag names are listed on the downloads page on swift.org.
```

### Running Swift commands in the Linux container

Use the usual commands to interact with the Swift compiler or package manager in the Linux environment. For example:

```Bash
swift --version
swift build
swift test --enable-test-discovery
```
> Note that the `/src` directory in the Linux container is a direct mirror of the current directory on the host OS, not a copy. If you delete a file in `/src` in the Linux container, that file will be gone on the host OS, too.

Type `exit` or `Ctrl+D` to exit the Linux shell and return to macOS.

### Generate tests for Linux

There is an option in the swift package manager to update `LinuxMain.swift` to generate all files and functions needed to run all the tests inside linux

`swift test --generate-linuxmain`

## Contribution
Welcome to fork and submit pull requests!!

Before submitting pull request, please ensure you have passed the included tests.
If your pull request including new function, please write test cases for it.

---

## License
Client is released under the MIT License.
