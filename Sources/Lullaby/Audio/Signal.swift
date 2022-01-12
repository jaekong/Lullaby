public typealias DSPFunction = (Time) -> (Sample)

public struct Signal {
    public var function: DSPFunction
    
    public init(_ function: @escaping DSPFunction) {
        self.function = function
    }
    
    @inlinable
    public func callAsFunction(_ time: Time) -> Sample {
        function(time)
    }
}

extension Signal: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = .constant(Sample(value))
    }
}

extension Signal: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .constant(Sample(value))
    }
}

public extension Signal {
    static func +(lhs: Signal, rhs: Signal) -> Signal {
        return Signal { time in lhs(time) + rhs(time) }
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
    
    static func constant(_ value: Int) -> Signal {
        return Signal { _ in Sample(value) }
    }
    
    static func constant(_ value: Double) -> Signal {
        return Signal { _ in Sample(value) }
    }
}
