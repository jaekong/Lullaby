import Foundation

/// An actor that can be used to trigger envelopes.
public actor Trigger {
    private var value: Value
    
    public var output: Signal {
        get async {
            return await value.output
        }
    }
    
    init() {
        value = Value(value: 0)
    }
    
    public func impulse(sustain: Time? = nil) async {
        await value.setValue(1)
        if let sustain = sustain {
            await Task.sleep(seconds: sustain)
        }
        await value.setValue(0)
    }
    
    public func activate() async {
        await value.setValue(1)
    }
    
    public func deactivate() async {
        await value.setValue(0)
    }
}
