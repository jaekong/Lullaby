import Foundation

/// Generates linear-interpolated Wave function from given sample points.
///
/// To make a triangle wave function, you can provide five sample points like below.
/// ```
/// let triangle = linearInterpolatedWavetable(samplePoints: [0, 1, 0, -1, 0])
/// ```
func linearInterpolatedWavetable(samplePoints: [Sample]) -> Wave {
    let sampleCount = samplePoints.count - 1
    let sampleRange = Phase(sampleCount)

    guard sampleCount != -1 else {
        return { _ in 0 }
    }

    guard sampleCount != 0 else {
        return { _ in samplePoints[0] }
    }

    return { phase in
        let lerpIndex = (phase * sampleRange).truncatingRemainder(dividingBy: sampleRange)
        let leftIndex = Int(lerpIndex.rounded(.down))
        let rightIndex = Int(lerpIndex.rounded(.up).truncatingRemainder(dividingBy: sampleRange + 1))
        
        return samplePoints[leftIndex] + (samplePoints[rightIndex] - samplePoints[leftIndex]) * (Sample(lerpIndex) - Sample(leftIndex))
    }
}
