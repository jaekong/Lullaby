import XCTest
@testable import Lullaby
@testable import LullabyMusic
//import LullabySoundIOEngine
import LullabyMiniAudioEngine

final class LullabyTestsMiniAudio: XCTestCase {
    func testSine() async throws {
        let value = Value(value: 440)
        
        let carrier = await sine(frequency: value.output)
        
        let task = Task {
            for i in twelveToneEqualTemperamentTuning.pitches {
                await value.setValue(Sample(i * 440))
                await Task.sleep(seconds: 0.5)
            }
        }

        let engine = try await MiniAudioEngine()

        engine.setOutput(to: carrier)
        try engine.prepare()
        try engine.start()
        
        await task.value
        
        try engine.stop()
    }
    
    func testADSR() async throws {
        let value = Value(value: 440)

        let modulator: Signal = await sine(frequency: value.output) * ((sine(frequency: value.output) + 1) * 250) + value.output
        let carrier = sine(frequency: modulator)
        
        let trigger = Value(value: 0)
        
        let envelope = adsr(trigger: await trigger.output, attack: 0.1, decay: 0.5, sustain: 0.5, release: 0.5)
        
        let task = Task {
            for i in twelveToneEqualTemperamentTuning.pitches {
                await value.setValue(Sample(i * 440))
                await trigger.setValue(1)
                print(await trigger.value)
                await Task.sleep(seconds: 2)
                await trigger.setValue(0)
                print(await trigger.value)
                await Task.sleep(seconds: 2)
            }
        }

        let engine = try await MiniAudioEngine()

        engine.setOutput(to: carrier * envelope)
        try engine.prepare()
        try engine.start()
        
        await task.value
        
        try engine.stop()
    }
    
    func testFM() async throws {
        let value = Value(value: 440)

        let modulator: Signal = await sine(frequency: value.output) * ((sine(frequency: value.output) + 1) * 250) + value.output
        let carrier = sine(frequency: modulator)

        let task = Task {
            for i in twelveToneEqualTemperamentTuning.pitches {
                await value.setValue(Sample(i * 440))
                await Task.sleep(seconds: 0.5)
            }
        }

        let engine = try await MiniAudioEngine()

        engine.setOutput(to: carrier)
        try engine.prepare()
        try engine.start()

        await task.value

        try engine.stop()
    }
}

//final class LullabyTestsSoundIO: XCTestCase {
//    func testSine() async throws {
//        let value = Value(value: 440)
//        
//        let carrier = await sine(frequency: value.output)
//        
//        let task = Task {
//            for i in twelveToneEqualTemperamentTuning.pitches {
//                await value.setValue(Sample(i * 440))
//                await Task.sleep(seconds: 0.5)
//            }
//        }
//
//        let engine = try await SoundIOEngine()
//
//        engine.setOutput(to: carrier)
//        try engine.prepare()
//        try engine.start()
//        
//        await task.value
//        
//        try engine.stop()
//    }
//    
//    func testFM() async throws {
//        let value = Value(value: 440)
//
//        let modulator: Signal = await sine(frequency: value.output) * ((sine(frequency: value.output) + 1) * 250) + value.output
//        let carrier = sine(frequency: modulator)
//
//        let task = Task {
//            for i in twelveToneEqualTemperamentTuning.pitches {
//                await value.setValue(Sample(i * 440))
//                await Task.sleep(seconds: 0.5)
//            }
//        }
//
//        let engine = try await SoundIOEngine()
//
//        engine.setOutput(to: carrier)
//        try engine.prepare()
//        try engine.start()
//
//        await task.value
//
//        try engine.stop()
//    }
//}
