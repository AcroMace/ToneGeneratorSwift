# Tone Generator in Swift

A direct port of [Matt Gallagher's tone generator on Cocoa with Love](https://www.cocoawithlove.com/2010/10/ios-tone-generator-introduction-to.html) to Swift.

<img src="https://github.com/AcroMace/ToneGeneratorSwift/raw/main/Demo.png" width="240">

The original example was in Objective-C and I originally ported it for the [Theramin](https://github.com/AcroMace/Theramin) project, but I also saw a lot of people asking for a Swift version on StackOverflow, so I'm publishing this separately.

The one difference is I refactored out the tone generation logic all into `ToneGenerator.swift` so it can be copied and pasted into other projects. I also used SwiftUI so I'm setting the frequency directly on the generator instead of reading from the view.

Both this and the original code from Matt Gallagher are **MIT licensed**.
