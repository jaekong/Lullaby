import Foundation

public func sine(frequency: Signal, phase: Phase = 0) -> Signal {
    return Oscillator(wave: wavetable(from: LookupTables.sineTable), frequency: frequency, phase: phase).output
}

public func triangle(frequency: Signal, phase: Phase = 0) -> Signal {
    return Oscillator(wave: triangleWave, frequency: frequency, phase: phase).output
}

public func square(frequency: Signal, phase: Phase = 0) -> Signal {
    return Oscillator(wave: squareWave, frequency: frequency, phase: phase).output
}
