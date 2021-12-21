import Foundation

public func wavetable(from table: [Sample]) -> Wave {
    let sampleCount = Phase(table.count)
    return { phase in
        let currentIndex = Int((sampleCount * (phase).truncatingRemainder(dividingBy: 1)).rounded(.down))
        
        return table[currentIndex]
    }
}
