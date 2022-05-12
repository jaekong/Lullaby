import Foundation

internal enum LookupTables {
    static let sineTable: [Float] = (0..<44100).map {
        return sin(2 * .pi * (Float($0) / 44100))
    }

    static let squareTable: [Float] = [1, -1]
}

/// A pre-defined wavetable based sine wave function.
public let sineWave = wavetable(from: LookupTables.sineTable)

/// A pre-defined linear-interpolated wavetable based triangle wave function.
public let triangleWave = linearInterpolatedWavetable(samplePoints: [0, 1, 0, -1, 0])

/// A pre-defined wavetable based square wave function.
public let squareWave = wavetable(from: LookupTables.squareTable)
