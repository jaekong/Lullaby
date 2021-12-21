import Foundation

enum LookupTables {
    static let sineTable: [Float] = (0..<44100).map {
        return sin(2 * .pi * (Float($0) / 44100))
    }

    static let triangleTable: [Float] = (0...11025).map {
        return Float((11025 - $0)) / 11025.0
    }

    static let squareTable: [Float] = [-1, 1]
}

public let sineWave = wavetable(from: LookupTables.sineTable)
