import Foundation

/// Frequency in Hz.
public typealias Frequency = Double

/// Represents pitch in terms of an exponent of 2. For example, value of 0 equals to standard pitch, 1 equals to an octave higher than standard pitch.
///
/// This value is usually produced by a `Function` and rounded to the closest pitch class in the given tuning system.
public typealias Pitch = Double

public typealias Interval = Double

/// Double-precision real number ratio. Used to represent interval.
public struct Ratio: Equatable, Codable, Hashable {
    fileprivate var numerator: Int = 1
    fileprivate var denominator: Int = 1
    
    public init(_ numerator: Int, _ denominator: Int) {
        self.value = (numerator, denominator)
    }
    
    public var value: (numerator: Int, denominator: Int) {
        get {
            return (numerator, denominator)
        }
        set {
            let numeratorFactors = newValue.numerator.primeFactors
            let denominatorFactors = newValue.denominator.primeFactors
            
            let maxNFactor = numeratorFactors.max(by: { $0.prime < $1.prime }) ?? (2, 0)
            let maxDFactor = denominatorFactors.max(by: { $0.prime < $1.prime }) ?? (2, 0)
            
            guard let maxPrime = [maxNFactor, maxDFactor].max(by: { $0.prime < $1.prime })?.prime else { return }
            
            let primes = Int.findPrimes(under: maxPrime)
            
            var newNumerator: Int = 1
            var newDenominator: Int = 1
            
            for prime in primes {
                let numeratorFactor = numeratorFactors.first { $0.prime == prime } ?? (prime, 0)
                let denominatorFactor = denominatorFactors.first { $0.prime == prime } ?? (prime, 0)
                
                let newExponent = numeratorFactor.exponent - denominatorFactor.exponent
                
                switch newExponent {
                case ..<0:
                    newDenominator *= Int(pow(Double(prime), Double(-newExponent)))
                case 1...:
                    newNumerator *= Int(pow(Double(prime), Double(newExponent)))
                default:
                    break
                }
            }
            
            self.numerator = newNumerator
            self.denominator = newDenominator
        }
    }
    
    public var decimalValue: Double {
        return Double(numerator) / Double(denominator)
    }
}

extension Ratio: CustomStringConvertible {
    public var description: String {
        return "\(numerator)/\(denominator)"
    }
}

extension Ratio: Comparable {
    public static func < (lhs: Ratio, rhs: Ratio) -> Bool {
        return lhs.decimalValue < rhs.decimalValue
    }
}

extension Ratio: AdditiveArithmetic {
    public static var zero: Ratio = Ratio(0, 1)
    
    public static func - (lhs: Ratio, rhs: Ratio) -> Ratio {
        let commonDenominator = lhs.denominator * rhs.denominator
        let lhsNumerator = lhs.numerator * rhs.denominator
        let rhsNumerator = rhs.numerator * lhs.denominator
        
        return Ratio(lhsNumerator - rhsNumerator, commonDenominator)
    }
    
    public static func + (lhs: Ratio, rhs: Ratio) -> Ratio {
        let commonDenominator = lhs.denominator * rhs.denominator
        let lhsNumerator = lhs.numerator * rhs.denominator
        let rhsNumerator = rhs.numerator * lhs.denominator
        
        return Ratio(lhsNumerator + rhsNumerator, commonDenominator)
    }
}

public func primeLimitedIntervals(n: Int, max: Int) -> Set<Ratio> {
    let a = Int.findSmoothNumbers(n: n, under: max)
    let b = a

    var result: Set<Ratio> = []

    for x in a {
        for y in b {
            if (x <= y || x >= y * 2) { continue }
            let interval = Ratio(x, y)
            result.insert(interval)
        }
    }
    
    return result
}

/// A struct representing a tuning system.
public struct Tuning: Codable {
    public var intervals: [Interval]
    
    public var n: Int = 5 {
        didSet {
            switch mode {
            case .primeLimitedTuning:
                intervals = [1] + primeLimitedIntervals(n: n, max: max).sorted().map { $0.decimalValue }
            default:
                break
            }
        }
    }
    public var max: Int = 40 {
        didSet {
            switch mode {
            case .primeLimitedTuning:
                intervals = [1] + primeLimitedIntervals(n: n, max: max).sorted().map { $0.decimalValue }
            default:
                break
            }
        }
    }
    public var toneCount: Int = 12 {
        didSet {
            switch mode {
            case .equalTemperamentTuning:
                intervals = (0..<toneCount).map { (tone: Int) in pow(2, Double(tone) / Double(toneCount)) }
            default:
                break
            }
        }
    }
    
    public var standardFrequency: Frequency {
        didSet {
            switch mode {
            case .equalTemperamentTuning:
               intervals = (0..<toneCount).map { (tone: Int) in pow(2, Double(tone) / Double(toneCount)) }
            case .primeLimitedTuning:
               intervals = [1] + primeLimitedIntervals(n: n, max: max).sorted().map { $0.decimalValue }
            }
        }
    }
    
    public var mode: Mode {
        didSet {
            switch mode {
            case .equalTemperamentTuning:
                intervals = (0..<toneCount).map { (tone: Int) in pow(2, Double(tone) / Double(toneCount)) }
            case .primeLimitedTuning:
                intervals = [1] + primeLimitedIntervals(n: n, max: max).sorted().map { $0.decimalValue }
            }
        }
    }
    
    /// Just intonation tuning system where all the intervals are prime-limited within given parameters.
    /// - Parameters:
    ///     - n: Prime limit of generated intervals. All intervals' denominators and numerators will be n-smooth.
    ///     - max: Maximum of denominator and numerator value.
    ///     - standardFrequency: Standard pitch for the tuning. Defaults to 440Hz.
    public init(n: Int, max: Int, standardFrequency: Frequency = 440) {
        self.n = n
        self.max = max
        self.standardFrequency = standardFrequency
        self.mode = .primeLimitedTuning
        self.intervals = [1] + primeLimitedIntervals(n: n, max: max).sorted().map { $0.decimalValue }
    }
    
    /// Equal temperament tuning system that can have arbitrary number of tones in an octave. Standard 12TET system can be achieved with this.
    /// - Parameters:
    ///     - toneCount: Total number of tones in an octave. Defaults to 12.
    ///     - standardFrequency: Standard pitch for the tuning. Defaults to 440Hz.
    public init(toneCount: Int = 12, standardFrequency: Frequency = 440) {
        self.toneCount = toneCount
        self.standardFrequency = standardFrequency
        self.mode = .equalTemperamentTuning
        self.intervals = (0..<toneCount).map { (tone: Int) in pow(2, Double(tone) / Double(toneCount)) }
    }
    
    public enum Mode: String, Codable {
        case primeLimitedTuning
        case equalTemperamentTuning
    }
}

extension Tuning {
    public func noteToFrequency(note: Pitch) -> Frequency {
        let octave = floor(note)
        let pitchClass = note - octave

        guard let closestNote = intervals.sorted(by: { a, b in
            abs(Double(a) - pow(2, pitchClass)) < abs(Double(b) - pow(2, pitchClass))
        }).first else {
            return standardFrequency * octave
        }

        return (standardFrequency * Double(closestNote)) * pow(2, octave)
    }
    
    public func closestNoteInTune(note: Pitch) -> Pitch {
        let octave = floor(note)
        let pitchClass = note - octave

        guard let closestNote = intervals.sorted(by: { a, b in
            abs(Double(a) - pow(2, pitchClass)) < abs(Double(b) - pow(2, pitchClass))
        }).first else {
            return note
        }
        
        return octave + log2(Double(closestNote))
    }
}

/// Standard 12TET at 440Hz tuning.
public let twelveToneEqualTemperamentTuning = Tuning(toneCount: 12, standardFrequency: 440)

extension Double {
    public init(_ other: Ratio) {
        self.init(other.decimalValue)
    }
}
