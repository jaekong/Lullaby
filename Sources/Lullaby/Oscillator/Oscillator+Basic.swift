import Foundation

public func sine(frequency: Signal, phase: Phase = 0) -> Signal {
    return Oscillator(wave: BasicWaves.sine, frequency: frequency, phase: phase).output
}

public func triangle(frequency: Signal, phase: Phase = 0) -> Signal {
    return Oscillator(wave: BasicWaves.triangle, frequency: frequency, phase: phase).output
}

public func square(frequency: Signal, phase: Phase = 0) -> Signal {
    return Oscillator(wave: BasicWaves.square, frequency: frequency, phase: phase).output
}
