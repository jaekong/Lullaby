import Foundation
//import Collections

public struct Note: ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Pitch
    
    private let pitch: Pitch
    
    public init(floatLiteral value: Pitch) {
        self.pitch = value
    }
}

/// Interval Classes in 12TET based western music theory.
public enum Interval: Hashable, Comparable, Codable {
    case unison
    case major(Int)
    case minor(Int)
    case perfect(Int)
    case diminished(Int)
    case augmented(Int)
    
    public init?(semitones: Int) {
        guard semitones >= 0 else { return nil }
        guard semitones != 0 else { self = .unison; return }
        
        let octave = semitones / 12
        let convertedSemitones = semitones % 12
        
        switch convertedSemitones {
        case 0:
            self = .perfect(1 + octave * 7)
        case 1:
            self = .minor(2 + octave * 7)
        case 2:
            self = .major(2 + octave * 7)
        case 3:
            self = .minor(3 + octave * 7)
        case 4:
            self = .major(3 + octave * 7)
        case 5:
            self = .perfect(4 + octave * 7)
        case 6:
            self = .diminished(5 + octave * 7)
        case 7:
            self = .perfect(5 + octave * 7)
        case 8:
            self = .minor(6 + octave * 7)
        case 9:
            self = .major(6 + octave * 7)
        case 10:
            self = .minor(7 + octave * 7)
        case 11:
            self = .major(7 + octave * 7)
        default:
            return nil
        }
    }
    
    public var semitones: Int {
        switch self {
        case .unison:
            return 0
        case .major(let interval):
            let convertedInterval = (interval - 1) % 7 + 1
            let octave = (interval - 1) / 7
            
            switch convertedInterval {
            case 2...3:
                return ((convertedInterval - 1) * 2) + octave * 12
            case 6...7:
                return ((convertedInterval - 1) * 2 - 1) + octave * 12
            default:
                fatalError("")
            }
        case .minor(let interval):
            let convertedInterval = (interval - 1) % 7 + 1
            let octave = (interval - 1) / 7
            
            switch convertedInterval {
            case 2...3:
                return ((convertedInterval - 1) * 2 - 1) + octave * 12
            case 6...7:
                return ((convertedInterval - 1) * 2 - 2) + octave * 12
            default:
                return 0
            }
        case .perfect(let interval):
            let convertedInterval = (interval - 1) % 7 + 1
            let octave = (interval - 1) / 7
            
            switch convertedInterval {
            case 1:
                return octave * 12
            case 4:
                return 5 + octave * 12
            case 5:
                return 7 + octave * 12
            default:
                return 0
            }
        case .diminished(let interval):
            let convertedInterval = (interval - 1) % 7 + 1
            
            switch convertedInterval {
            case 1, 4, 5:
                return Interval.perfect(interval).semitones - 1
            case 2, 3, 6, 7:
                return Interval.minor(interval).semitones - 1
            default:
                fatalError("")
            }
        case .augmented(let interval):
            let convertedInterval = (interval - 1) % 7 + 1
            
            switch convertedInterval {
            case 1, 4, 5:
                return Interval.perfect(interval).semitones + 1
            case 2, 3, 6, 7:
                return Interval.major(interval).semitones + 1
            default:
                fatalError("")
            }
        }
    }
    
    public var octaves: Int {
        return semitones / 12
    }
    
    public var normalizedInterval: Interval {
        return Interval(semitones: semitones % 12)!
    }
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.semitones == rhs.semitones
    }
    
    public static func <(lhs: Self, rhs: Self) -> Bool {
        return lhs.semitones < rhs.semitones
    }
    
    public static func +(lhs: Self, rhs: Self) -> Self? {
        return Interval(semitones: lhs.semitones + rhs.semitones)
    }
    
    public static func -(lhs: Self, rhs: Self) -> Self? {
        return Interval(semitones: lhs.semitones - rhs.semitones)
    }
    
    public static func *(lhs: Self, rhs: Self) -> Self? {
        return Interval(semitones: lhs.semitones * rhs.semitones)
    }
    
    public static func *(lhs: some BinaryInteger, rhs: Self) -> Self? {
        return Interval(semitones: Int(lhs) * rhs.semitones)
    }
}

public typealias Chord = Set<Interval>

public extension Chord {
    var normalized: Chord {
        let root = self.min { $0 < $1 } ?? .unison
        
        let rootNormalized = self.map {
            $0 - root ?? .unison
        }
        
        let octaveNormalized = rootNormalized.compactMap {
            Interval(semitones: $0.semitones % 12)
        }
        
        let result = [.unison] + octaveNormalized.compactMap {
            $0 - .minor(2)
        }
        
        return Chord(result)
    }
}

public enum ChordClass {
    private static let base: [(key: ChordClass, value: Chord)] = [
        (.major(), [.unison, .major(3), .perfect(5)]),
        (.minor(), [.unison, .minor(3), .perfect(5)]),
        (.diminished(), [.unison, .minor(3), .diminished(5)]),
        (.augmented(), [.unison, .major(3), .augmented(5)])
    ]
    
    case major(_ extensions: Chord)//, inversion: Int = 0)
    case minor(_ extensions: Chord)//, inversion: Int = 0)
    case diminished(_ extensions: Chord)//, inversion: Int = 0)
    case augmented(_ extensions: Chord)//, inversion: Int = 0)
    
    public static func major(_ extensions: Interval...) -> Self {
        return .major(Chord(extensions))
    }
    
    public static func minor(_ extensions: Interval...) -> Self {
        return .minor(Chord(extensions))
    }
    
    public static func diminished(_ extensions: Interval...) -> Self {
        return .diminished(Chord(extensions))
    }
    
    public static func augmented(_ extensions: Interval...) -> Self {
        return .augmented(Chord(extensions))
    }
    
    public init(from intervals: Interval...) throws {
        try self.init(from: Chord(intervals).normalized)
    }
    
    public init(from chord: Chord) throws {
        let intervalSet = chord.normalized
        
        guard let mostLikely = Self.base.min(by: {
            return intervalSet.subtracting($0.value).count < intervalSet.subtracting($1.value).count
        }) else {
            fatalError("")
        }
        
        let extensions = intervalSet.subtracting(mostLikely.value)
        
        switch mostLikely.key {
        case .major:
            self = .major(extensions)
        case .minor:
            self = .minor(extensions)
        case .diminished:
            self = .diminished(extensions)
        case .augmented:
            self = .augmented(extensions)
        }
    }
}
