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

    private var lastTime: Time = 0
    
    public var output: Signal {
        return Signal { time in
            self.phase += Phase(self.frequency(time) * (time - self.lastTime))
            self.phase = self.phase.truncatingRemainder(dividingBy: 1)

            self.lastTime = time

            return self.wave(self.phase)
        }
    }
}
