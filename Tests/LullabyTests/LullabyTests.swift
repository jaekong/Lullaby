import XCTest
@testable import Lullaby
@testable import LullabyMusic
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
        
        let trigger = Gate()
        
        let envelope = adsr(trigger: await trigger.output, attack: 0.1, decay: 0.5, sustain: 0.5, release: 0.5)
        
        let task = Task {
            for i in twelveToneEqualTemperamentTuning.pitches {
                await value.setValue(Sample(i * 440))
                await trigger.impulse(sustain: 1)
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
    
    func testADSR2() async throws {
        let value = Value(value: 440)

        let modulator: Signal = await sine(frequency: value.output) * ((sine(frequency: value.output) + 1) * 250) + value.output
        let carrier = sine(frequency: modulator)
        
        let envelope = EnvelopeGenerator(attack: 0.1, release: 0.5)
        
        let task = Task {
            for i in twelveToneEqualTemperamentTuning.pitches {
                await value.setValue(Sample(i * 440))
                await envelope.impulse(sustain: 1)
                await Task.sleep(seconds: 0.1)
            }
        }

        let engine = try await MiniAudioEngine()

        await engine.setOutput(to: carrier * envelope.output)
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
    
    func testTrigger() async throws {
        let value = Value(value: 440)

        let modulator: Signal = await sine(frequency: value.output) * ((sine(frequency: value.output) + 1) * 250) + value.output
        let carrier = sine(frequency: modulator)
        
        let trigger = Gate()
        
        let envelope = adsr(trigger: await trigger.output, attack: 0.01, decay: 0.2, sustain: 0.8, release: 0.3)
        
        let task = Task {
            while true {
                guard let input = readLine() else {
                    continue
                }
                
                guard input != "exit" else {
                    return
                }
                
                if !input.isEmpty {
                    await trigger.impulse(sustain: 0.5)
                }
            }
        }

        let engine = try await MiniAudioEngine()

        engine.setOutput(to: carrier * envelope)
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
