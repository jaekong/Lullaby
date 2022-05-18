import Foundation

/// A class that converts a wave function to a signal.
public class Oscillator {
    public init(wave: @escaping Wave, frequency: Signal, phase: Phase) {
        self.wave = wave
        self.frequency = frequency
        self.phase = phase
    }
    
    public var wave: Wave
    public var frequency: Signal
    public var phase: Phase
    
    public var output: Signal {
        var lastTime: Time = 0
        
        return Signal { time in
            let deltaTime = max(time - lastTime, 0)
            self.phase += Phase(self.frequency(time) * (deltaTime))
            self.phase = self.phase.truncatingRemainder(dividingBy: 1)

            defer { lastTime = time }

            return self.wave(self.phase)
        }
    }
}
