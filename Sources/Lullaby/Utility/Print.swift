import Foundation

public func print(_ signal: Signal, skippingBy: Int = 440) -> Signal {
    var count = 0
    return Signal { time in
        let sample = signal(time)
        if count % skippingBy == 0 {
            Task.detached {
                print(time, sample)
            }
        }
        count += 1
        return sample
    }
}
