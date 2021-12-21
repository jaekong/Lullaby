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

extension Task where Success == Never, Failure == Never{
    static func sleep(seconds: Double) async {
        let nanoseconds = UInt64(seconds * 1_000_000_000)
        await Self.sleep(nanoseconds)
    }
}

public actor Value {
    init(value: Sample) {
        self.value = value
    }
    
    func setValue(_ value: Sample) {
        self.value = value
    }
    
    var value: Sample
    var output: Signal {
        return Signal { _ in
            return self.value
        }
    }
}
