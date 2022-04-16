import Foundation

/// Interval Classes in 12TET based western music theory.
public enum Interval: Equatable, Comparable {
    case major(Int)
    case minor(Int)
    case perfect(Int)
    case diminished(Int)
    case augmented(Int)
    
    init?(semitones: Int) {
        guard semitones >= 0 else { return nil }
        
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
    
    var semitones: Int {
        switch self {
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
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.semitones == rhs.semitones
    }
    
    public static func <(lhs: Self, rhs: Self) -> Bool {
        return lhs.semitones < rhs.semitones
    }
}

/// Common Intervals in 12TET based western music theory.
public enum CommonIntervals: Int, Hashable {
    case unison = 0
    case minor2 = 1
    case major2 = 2
    case minor3 = 3
    case major3 = 4
    case perfect4 = 5
    case tritone = 6
    case perfect5 = 7
    case minor6 = 8
    case major6 = 9
    case minor7 = 10
    case major7 = 11
    case octave = 12
    
    // one more octave for 9th 11th and stuff
    case minor9 = 13
    case major9 = 14
    case minor10 = 15
    case major10 = 16
    case perfect11 = 17
    case aug11 = 18
    case perfect12 = 19
    case minor13 = 20 // i mean at this point do we even need them?
    case major13 = 21
    case minor14 = 22
    case major14 = 23
    case perfect15 = 24
    
    public static let dim2: CommonIntervals = .unison
    public static let dim3: CommonIntervals = .major2
    public static let dim4: CommonIntervals = .major3
    public static let dim5: CommonIntervals = .tritone
    public static let dim6: CommonIntervals = .perfect5
    public static let dim7: CommonIntervals = .major6
    public static let dim8: CommonIntervals = .major7
    
    // not gonna bother putting all the diminished and augmented
    public static let dim12: CommonIntervals = .aug11
    
    public static let aug1: CommonIntervals = .minor2
    public static let aug2: CommonIntervals = .minor3
    public static let aug3: CommonIntervals = .perfect4
    public static let aug4: CommonIntervals = .tritone
    public static let aug5: CommonIntervals = .minor6
    public static let aug6: CommonIntervals = .minor7
    public static let aug7: CommonIntervals = .octave
    
    public init(semitones: Int) {
        if semitones > 12 {
            self = Self.init(rawValue: semitones % 24)!
        } else if semitones < 0 {
            self = Self.init(rawValue: (semitones % 24) + 24)!
        } else {
            self = Self.init(rawValue: semitones)!
        }
    }
    
    public func diminished() -> Self {
        return Self.init(semitones: self.rawValue - 1)
    }
    
    public func augmented() -> Self {
        return Self.init(semitones: self.rawValue - 1)
    }
}

public enum ChordClass {
    public static let major: Set<CommonIntervals> = [.unison, .major3, .perfect5]
    public static let minor: Set<CommonIntervals> = [.unison, .minor3, .perfect5]
    public static let diminished: Set<CommonIntervals> = [.unison, .minor3, .dim5]
    public static let augmented: Set<CommonIntervals> = [.unison, .major3, .aug5]
}
