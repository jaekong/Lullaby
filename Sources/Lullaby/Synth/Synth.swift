import Foundation
import Collections

public struct SynthEvent {
    public init(frequency: Signal, duration: Time) {
        self.frequency = frequency
        self.duration = duration
    }
    
    public let frequency: Signal
    public let duration: Time
}

public class MonophonicSynth: Outputting {
    private var oscillator: Oscillator
    private var envelope: EnvelopeGenerator
    
    public var frequency: Signal = 0
    
    public var output: Signal {
        return Signal {
            self.mixedSignal($0)
        }
    }
    
    public init(oscillator: Oscillator, envelope: Envelope) {
        self.oscillator = oscillator
        self.envelope = EnvelopeGenerator(envelope: envelope)
    }
    
    public func play(event: SynthEvent) async {
        self.oscillator.frequency = event.frequency
        await self.envelope.impulse(sustain: event.duration)
        await Task.sleep(seconds: self.envelope.envelope.release)
    }
    
    private func mixedSignal(_ time: Time) -> Sample {
        oscillator.output(time) * envelope.output(time)
    }
    
    public func play(event: SynthEvent) {
        Task {
            await self.play(event: event)
        }
    }
    
    deinit {
        print("deinit monosynth \(output.hashValue)")
    }
}


public actor Synth {
    private var synths: [MonophonicSynth] = []
    
    private let oscillator: Oscillator
    private let envelope: Envelope
    
//    public var signals: [Signal] = []
    public var output: Signal {
        return Signal {
            self.mixedSignal($0)
        }
    }
    
    private var lastIndex: Int = 0
    
    public var currentPolyphonyCount: Signal = 0
    
    init(oscillator: Oscillator, envelope: Envelope, voiceCount: Int = 8) async {
        self.oscillator = oscillator
        self.envelope = envelope
        self.synths = (0..<voiceCount).map { _ in 
            MonophonicSynth(oscillator: oscillator, envelope: self.envelope)
        }
        
        print(voiceCount, "voices")
    }
    
    public func play(event: SynthEvent) async {
        let index = self.lastIndex
        
        Task {
            print("voice \(index) playing")
        }
        
        let playTask = Task {
            await synths[index].play(event: event)
        }
        
        if lastIndex >= synths.count - 1 { lastIndex = 0 }
        else { lastIndex += 1 }
        
        await playTask.value
        
        Task {
            print("voice \(index) stop")
        }
    }
    
    public func play(events: [SynthEvent]) async {
        await withTaskGroup(of: Void.self, returning: Void.self) { group in
            for event in events {
                group.addTask {
                    await self.play(event: event)
                }
            }
        }
    }
    
    private func mixedSignal(_ time: Time) -> Sample {
        return synths.reduce(0) {
            $0 + $1.output(time)
        }
    }
    
    nonisolated public func play(event: SynthEvent) {
        Task {
            await self.play(event: event)
        }
    }
    
    nonisolated public func play(events: [SynthEvent]) {
        Task {
            await self.play(events: events)
        }
    }
}

//public actor Synth {
//    private var oscillators: Deque<Oscillator> = []
//    private var envelopes: Deque<EnvelopeGenerator> = []
//    
//    private var envelopeData: Envelope
//    private var wave: Wave
//    
//    public var output: Signal {
//        zip(oscillators, envelopes).map {
//            $0.0.output * $0.1.output
//        }.reduce(0) { $0 + $1 }
//    }
//
//    public init(wave: @escaping Wave, envelope: Envelope) {
//        self.wave = wave
//        self.envelopeData = envelope
//    }
//    
//    public func play(event: SynthEvent) async {
//        let oscillator = Oscillator(wave: self.wave, frequency: event.frequency, phase: event.phase)
//        let envelope = EnvelopeGenerator(envelope: self.envelopeData)
//        
//        oscillators.append(oscillator)
//        envelopes.append(envelope)
//        
//        Task {
//            
//        }
//    }
//}
