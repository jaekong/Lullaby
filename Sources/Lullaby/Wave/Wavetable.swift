import Foundation

/// Generates wavetable that only interpolates the phase value.
///
/// To make a square wave function, you can provide five sample points like below.
/// ```
/// let square = wavetable(from: [1, -1])
/// ```
public func wavetable(from table: [Sample]) -> Wave {
    let sampleCount = Phase(table.count)
    return { phase in
        let currentIndex = Int((sampleCount * (phase).truncatingRemainder(dividingBy: 1)).rounded(.down))
        
        return table[currentIndex]
    }
}
