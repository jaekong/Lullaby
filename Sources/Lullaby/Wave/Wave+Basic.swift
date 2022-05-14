import Foundation

internal enum LookupTables {
    static let sineTable: [Float] = (0..<44100).map {
        return sin(2 * .pi * (Float($0) / 44100))
    }

    static let squareTable: [Float] = [1, -1]
}

public enum BasicWaves {
    public static let rampUp: Wave = { phase in max(min(phase, 1), 0) }
    public static let rampDown: Wave = { phase in max(min(1 - phase, 1), 0) }
    public static let constant = wavetable(from: [1])
    
    /// A pre-defined wavetable based sine wave function.
    public static let sine = wavetable(from: LookupTables.sineTable)

    /// A pre-defined linear-interpolated wavetable based triangle wave function.
    public static let triangle = linearInterpolatedWavetable(samplePoints: [0, 1, 0, -1, 0])

    /// A pre-defined wavetable based square wave function.
    public static let square = wavetable(from: LookupTables.squareTable)
}
