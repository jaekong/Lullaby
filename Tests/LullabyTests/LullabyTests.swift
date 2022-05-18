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
    
    func testSineAdd() async throws {
        let value = Value(value: 440)
        let value2 = Value(value: Sample(twelveToneEqualTemperamentTuning.pitches[Interval.major(3).semitones - 1]) * 440)
        
        var tones = [await sine(frequency: value.output)]

        let engine = try await MiniAudioEngine()
        
        engine.setOutput(to: Signal { tones($0) })
        try engine.prepare()
        try engine.start()
        
        await Task.sleep(seconds: 2)
        
        tones.append(await sine(frequency: value2.output))
        
        await Task.sleep(seconds: 3)
        
        try engine.stop()
    }
    
    func testSynth() async throws {
        let synth = Synth(wave: BasicWaves.sine, envelope: Envelope(attack: 0.1, decay: 0.5, sustain: 0.7, release: 3))

        let engine = try await MiniAudioEngine()

        engine.setOutput(to: await synth.output)
        try engine.prepare()
        try engine.start()

        let task = Task {
            for i in twelveToneEqualTemperamentTuning.pitches {
                Task { await synth.play(event: SynthEvent(frequency: .constant(i) * 440, duration: 0.3)) }
                await Task.sleep(seconds: 1)
            }
            await Task.sleep(seconds: 1)
        }

        await task.value

        try engine.stop()
    }
    
    
    func testMonophonicSynth() async throws {
        let synth = MonophonicSynth(wave: BasicWaves.sine, envelope: Envelope(attack: 0.1, decay: 0.5, sustain: 0.7, release: 0.5))
        
        let engine = try await MiniAudioEngine()

        engine.setOutput(to: await synth.output)
        try engine.prepare()
        try engine.start()
        
        let task = Task {
            for i in twelveToneEqualTemperamentTuning.pitches {
                await synth.play(event: SynthEvent(frequency: .constant(i) * 440, duration: 1))
            }
            
            await Task.sleep(seconds: 12)
        }
        
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

        let engine = try await MiniAudioEngine()

        engine.setOutput(to: carrier * envelope.output)
        try engine.prepare()
        try engine.start()
        
        let task = Task {
            for i in twelveToneEqualTemperamentTuning.pitches {
                await value.setValue(Sample(i * 440))
                await envelope.impulse(sustain: 1)
            }
        }
        
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
