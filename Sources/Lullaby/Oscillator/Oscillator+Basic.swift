import Foundation

public func sine(frequency: Signal, phase: Phase = 0) -> Signal {
    let osc = Oscillator(wave: wavetable(from: LookupTables.sineTable), frequency: frequency, phase: phase)
    
    return osc()
}
