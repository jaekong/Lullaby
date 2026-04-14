import Foundation

/// A class that converts a wave function to a signal.
public struct Oscillator: Outputting {
    public init(wave: @escaping Wave, frequency: Signal, phase: Phase) {
        self.wave = wave
        self.frequency = frequency
        self.phase = phase
    }
    
    public var wave: Wave
    public var frequency: Signal
    public let phase: Phase
    
    public var gain: Signal = 1
    public var offset: Signal = 0
    
    public var output: Signal {
        var lastTime: Time = 0
        var phase = self.phase
        
        return Signal { time in
            let deltaTime = max(time - lastTime, 0)
            phase += Phase(self.frequency(time) * (deltaTime))
            phase = phase.truncatingRemainder(dividingBy: 1)

            defer { lastTime = time }

            return self.wave(phase)
        } * gain + offset
    }
}

extension Oscillator {
    static func *(_ lhs: Oscillator, rhs: Signal) -> Oscillator {
        var result = lhs
        result.gain = result.gain * rhs
        return result
    }
    
    static func +(_ lhs: Oscillator, rhs: Signal) -> Oscillator {
        var result = lhs
        result.offset = result.offset + rhs
        return result
    }
}
