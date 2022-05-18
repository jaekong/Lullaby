import Foundation
import Collections

public struct SynthEvent {
    public let frequency: Signal
    public let duration: Time
}

public actor MonophonicSynth {
    private var oscillator: Oscillator
    private var envelope: EnvelopeGenerator
    
    public var frequency: Signal = 0
    
    public var output: Signal {
        return oscillator.output * envelope.output
    }
    
    public init(wave: @escaping Wave, envelope: Envelope) {
        self.oscillator = Oscillator(wave: wave, frequency: frequency, phase: 0)
        self.envelope = EnvelopeGenerator(envelope: envelope)
    }
    
    public func play(event: SynthEvent) async {
        self.oscillator.frequency = event.frequency
        await self.envelope.impulse(sustain: event.duration)
        await Task.sleep(seconds: self.envelope.envelope.release)
    }
    
    public func play(event: SynthEvent) {
        Task {
            await self.play(event: event)
        }
    }
}

public actor Synth {
//    private var synths: Deque<MonophonicSynth> = []
    
    private var wave: Wave
    private var envelope: Envelope
    
    public var signals: [Signal] = []
    public var output: Signal {
        return Signal {
            self.mixedSignal($0)
        }
    }
    
    public var currentPolyphonyCount: Signal = 0
    
    public init(wave: @escaping Wave, envelope: Envelope) {
        self.wave = wave
        self.envelope = envelope
    }
    
    public func play(event: SynthEvent) async {
        let synth = MonophonicSynth(wave: wave, envelope: envelope)
        let signal = await synth.output
        
        signals.append(signal)
        currentPolyphonyCount = currentPolyphonyCount + 1
        
        await synth.play(event: event)

        signals.removeAll { $0 == signal }
        currentPolyphonyCount = currentPolyphonyCount - 1
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
        return signals(time)
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
