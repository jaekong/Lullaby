import Foundation

public typealias DSPFunction = (Time) -> (Sample)

public struct Signal {
    public var function: DSPFunction
    fileprivate let uuid = UUID()
    
    public init(_ function: @escaping DSPFunction) {
        self.function = function
    }
    
    @inlinable
    public func callAsFunction(_ time: Time) -> Sample {
        function(time)
    }
}

extension Signal: Equatable {
    public static func == (lhs: Signal, rhs: Signal) -> Bool {
        withUnsafePointer(to: lhs.function) { lhsPointer in
            withUnsafePointer(to: rhs.function) { rhsPointer in
                return lhsPointer == rhsPointer
            }
        }
    }
}

extension Signal: Hashable {
    public func hash(into hasher: inout Hasher) {
        uuid.hash(into: &hasher)
    }
}

extension Collection where Element == Signal {
    public func callAsFunction(_ time: Time) -> Sample {
        reduce(0) {
            $0 + $1.callAsFunction(time)
        }
    }
    
    public var output: Signal {
        return Signal {
            self.callAsFunction($0)
        }
    }
}

extension Signal: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self.function = { _ in return Sample(value) }
    }
}

extension Signal: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self.function = { _ in return Sample(value) }
    }
}

public extension Signal {
    static func +(lhs: Signal, rhs: Signal) -> Signal {
        return Signal { time in lhs(time) + rhs(time) }
    }
    
    static func -(lhs: Signal, rhs: Signal) -> Signal {
        return Signal { time in lhs(time) - rhs(time) }
    }
    
    static func *(lhs: Signal, rhs: Signal) -> Signal {
        return Signal { time in lhs(time) * rhs(time) }
    }
    
    static func /(lhs: Signal, rhs: Signal) -> Signal {
        return Signal { time in
            guard rhs(time) != 0 else { return 0 }
            return lhs(time) / rhs(time)
        }
    }
}

public extension Signal {
    static func constant(_ value: Sample) -> Signal {
        return Signal { _ in value }
    }
    
    static func constant<T: BinaryInteger>(_ value: T) -> Signal {
        return Signal { _ in Sample(value) }
    }
    
    static func constant<T: BinaryFloatingPoint>(_ value: T) -> Signal {
        return Signal { _ in Sample(value) }
    }
}
