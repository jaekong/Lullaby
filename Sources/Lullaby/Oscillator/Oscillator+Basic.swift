import Foundation

public enum BasicOscillators {
    static public func sine(frequency: Signal, phase: Phase = 0) -> Oscillator {
        return Oscillator(wave: BasicWaves.sine, frequency: frequency, phase: phase)
    }

    static public func triangle(frequency: Signal, phase: Phase = 0) -> Oscillator {
        return Oscillator(wave: BasicWaves.triangle, frequency: frequency, phase: phase)
    }

    static public func square(frequency: Signal, phase: Phase = 0) -> Oscillator {
        return Oscillator(wave: BasicWaves.square, frequency: frequency, phase: phase)
    }
}
