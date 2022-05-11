import Foundation

public typealias Precision = Float32

public typealias Sample = Precision
public typealias Amplitude = Sample

public extension Amplitude {
    var decibel: Self {
        return 20 * log10f(self)
    }
    
    init(from decibel: Float) {
        self = powf(10.0, (decibel / 20))
    }
}

public typealias Time = Precision

public extension Task where Success == Never, Failure == Never{
    static func sleep<T: BinaryFloatingPoint>(seconds: T) async {
        let nanoseconds = UInt64(seconds * 1_000_000_000)
        try? await Self.sleep(nanoseconds: nanoseconds)
    }
}

public actor Value {
    public init(value: Sample) {
        self.value = value
    }
    
    public func setValue(_ value: Sample) {
        self.value = value
    }
    
    public var value: Sample
    public var output: Signal {
        return Signal { _ in
            return self.value
        }
    }
}
