# Lullaby

![For Swift 5.5+](https://img.shields.io/badge/swift-5.5%2B-orange?style=flat-square)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjaekong%2FLullaby%2Fbadge%3Ftype%3Dswift-versions&style=flat-square)](https://swiftpackageindex.com/jaekong/Lullaby)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjaekong%2FLullaby%2Fbadge%3Ftype%3Dplatforms&style=flat-square)](https://swiftpackageindex.com/jaekong/Lullaby)

Lullaby is an audio synthesis framework for Swift that supports both macOS and Linux! It was inspired by other audio environments like FAUST, SuperCollider, Max and an article "Functional Signal Processing in Swift".

Currently, it is not production-ready, but I would like to know what you think!

## What Can I do with it?

- Audio Synthesis
- Computer Music Composition
- Real-time Reactive Audio Effects for Games and Apps
- Data Sonification

## Supported Platforms

- Tested on macOS / Linux[^1]
- Swift 5.5

## Usage

```swift
//...
dependencies: [
    // ...
    .package(url: "https://github.com/jtodaone/Lullaby.git", from: "0.2.0")
],
targets: [
    .executableTarget(
        // ...
        dependencies: [
            .product(name: "Lullaby", package: "Lullaby"),
            .product(name: "LullabyMusic", package: "Lullaby"),
            .product(name: "LullabyMiniAudioEngine", package: "Lullaby")
        ]
    )
]
//...
```

## Examples

```swift
import Lullaby
import LullabyMusic
import LullabyMiniAudioEngine

func sineTest() async throws {
    let value = Value(value: 440)
    
    let carrier = await sine(frequency: value.output)
    
    let task = Task {
        for i in twelveToneEqualTemperamentTuning.pitches {
            await value.setValue(Sample(i * 440))
            await Task.sleep(seconds: 0.5)
        }
        
        return
    }

    let engine = try await MiniAudioEngine()

    engine.setOutput(to: carrier)
    try engine.prepare()
    try engine.start()
    
    await task.value
    
    try engine.stop()
}

let task = Task {
    try await sineTest()
    task.cancel()
}

while !task.isCancelled {}

```

## Future Plans

- Triggers subscribing to external events - key presses, MIDI, etcs.
- Musical Composition DSL system
  - Writing musical pieces through custom DSL.
  - Phrases, Loops and more.
- Test on other platforms (iOS, Windows, etcs.)
- API Documentation

## Attribution

- [SoundIO](https://github.com/thara/SoundIO), a Swift binding of [libsoundio](https://github.com/andrewrk/libsoundio) is used in the source code, but it will be deprecated in favour of miniaudio.
- [miniaudio](https://miniaud.io) is used internally to handle audio I/O.

- Lullaby is licensed under [MIT License](LICENSE). You don't have to, but it would be nice if you let me know if you used Lullaby!

[^1]: Tested on Raspberry Pi 4B running Raspberry Pi OS Bullseye and Ubuntu 22.04 LTS. Theoretically, it should work on other platforms too. I couldn't test it though. If it doesn't work, please open an issue.
