# Poly

`Poly` is an unofficial [Google Poly](https://poly.google.com) SDK, written in [Swift](https://developer.apple.com/swift/).

This library makes it easy to integrate with Google Poly while providing a few additional client-side features.

[![Build Status](https://travis-ci.org/piemonte/Poly.svg?branch=master)](https://travis-ci.org/piemonte/Poly) [![Pod Version](https://img.shields.io/cocoapods/v/Poly.svg?style=flat)](http://cocoadocs.org/docsets/Poly/) [![Swift Version](https://img.shields.io/badge/language-swift%204.2-brightgreen.svg)](https://developer.apple.com/swift) [![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/piemonte/Poly/blob/master/LICENSE)

|  | Features |
|:---------:|:---------------------------------------------------------------|
| &#128269;  | 3D model search  |
| &#11015;  | 3D model download management |
| &#128230; | advanced 3D data caching |
| &#128225; | Poly reachability support |
| &#128038; | [Swift 4.2](https://developer.apple.com/swift/) |

## Important

Before you begin, ensure that you have read Google’s Poly [documentation](https://developers.google.com/poly/develop/), understand best practices for attribution, and have generated your API key.

## Quick Start

The sample project provides several examples for integration.

You can install the dependencies with the command `pod install` or by running the makefile commands `make setup && make pods`.

```ruby

# CocoaPods

pod "Poly", "~> 0.2.0"

# Carthage

github "piemonte/Poly" ~> 0.2.0

# Swift PM

let package = Package(
    dependencies: [
        .Package(url: "https://github.com/piemonte/Poly", majorVersion: 0)
    ]
)

```

With Xcode 10.2, one of Poly's dependencies currently requires this script in your `Podfile` to use this post install routine until [this PR](https://github.com/hyperoslo/Cache/pull/236) has landed.

```sh
post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'Cache'
      target.build_configurations.each do |config|
        level = '-Osize'
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = level
        puts "Set #{target.name} #{config.name} to Optimization Level #{level}"
      end
    end
  end
end
```

Alternatively, drop the [source files](https://github.com/piemonte/Poly/tree/master/Sources) into your Xcode project.

## Examples

Import the library.

```swift
import Poly
```

Setup your API key.

```swift
Poly.shared.apiKey = "REPLACE_WITH_API_KEY"
```

List assets using keywords.

```swift
Poly.shared.list(assetsWithKeywords: ["fox"]) { (assets, totalCount, nextPage, error) in
	// assets array provides objects with information such as URLs for thumbnail images
}

// you may also query for the data directly for your own model creation

Poly.shared.list(assetsWithKeywords: ["fox", "cat"]) { (data, error) in
}
```

Get independent asset information.

```swift
Poly.shared.get(assetWithIdentifier: "10u8FYPC5Br") { (asset, count, page, error) in
	// asset object provides information such as URLs for thumbnail images
}

// you may also query for the data directly for your own model creation

Poly.shared.get(assetWithIdentifier: "10u8FYPC5Br") { (data, error) in
}
```

Download a 3D asset and it's resources for rendering, either using the asset identifier or the asset model object itself.

```swift
Poly.shared.download(assetWithIdentifier: "10u8FYPC5Br", progressHandler: { (progress) in
}) { (rootFileUrl, resourceFileUrls, error) in
    if let rootFileUrl = rootFileUrl {
        let node = SCNNode.createNode(withLocalUrl: rootFileUrl)
        self._arView?.scene.rootNode.addChildNode(node)
    }
}
```

The API also provides private object loading but additional endpoints may need to be added. Auth support is setup and available via the `authToken` property.

## Documentation

You can find [the docs here](https://piemonte.github.io/Poly). Documentation is generated with [jazzy](https://github.com/realm/jazzy) and hosted on [GitHub-Pages](https://pages.github.com).

## Resources

* [Poly iOS Quickstart](https://developers.google.com/poly/develop/ios)
* [Poly API Reference](https://developers.google.com/poly/reference/api/rest/)
* [Poly Google Developer Website](https://developers.google.com/poly/)
* [Poly iOS Sample Project](https://github.com/googlevr/poly-sample-ios)
* [Swift Evolution](https://github.com/apple/swift-evolution)
* [NextLevel](http://nextlevel.engineering/) Media Capture Library

## License

`Poly` is available under the MIT license, see the [LICENSE](https://github.com/piemonte/Poly/blob/master/LICENSE) file for more information.
