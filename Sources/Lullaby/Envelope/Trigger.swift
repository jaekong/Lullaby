import Foundation

/// An actor that can be used to trigger envelopes.
public actor Trigger {
    private var value: Sample = 0
    
    public var output: Signal {
        get async {
            return Signal { _ in
                return self.value
            }
        }
    }
    
    public var targetValue: Sample
    
    init(target: Sample = 1) {
        self.targetValue = target
    }
    
    public func impulse(sustain: Time? = nil) async {
        value = targetValue
        if let sustain = sustain {
            await Task.sleep(seconds: sustain)
        }
        value = 0
    }
    
    public func activate() async {
        value = targetValue
    }
    
    public func deactivate() async {
        value = 0
    }
}
