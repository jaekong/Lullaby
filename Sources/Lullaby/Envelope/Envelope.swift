import Foundation

public protocol Envelope: Actor {
    func activate()
    func deactivate()
    func impulse(sustain: Time?) async
}

/// ADSR Envelope with custom curve shapes.
public actor ADSR: Envelope {
    public var attackShape: Wave
    public var decayShape: Wave
    public var sustainShape: Wave
    public var releaseShape: Wave
    
    public var attack: Time
    public var decay: Time
    public var sustain: Amplitude
    public var release: Time
    
    private var activated: Bool = false
    
    private var internalTriggeredTime: Time? = nil
    private var internalReleasedTime: Time? = nil
    
    init(attack: Time, decay: Time, sustain: Amplitude, release: Time, attackShape: @escaping Wave = BasicWaves.rampUp, decayShape: @escaping Wave = BasicWaves.rampDown, sustainShape: @escaping Wave = BasicWaves.constant, releaseShape: @escaping Wave = BasicWaves.rampDown) {
        precondition(attack >= 0, "Attack value should be positive.")
        precondition(decay >= 0, "Decay value should be positive.")
        precondition(sustain >= 0, "Sustain value should be positive.")
        precondition(release >= 0, "Release value should be positive.")
        
        self.attack = attack
        self.decay = decay
        self.sustain = sustain
        self.release = release
        
        self.attackShape = attackShape
        self.decayShape = decayShape
        self.sustainShape = sustainShape
        self.releaseShape = releaseShape
    }
    
    public func impulse(sustain: Time? = nil) async {
        activated = true
        if let sustain = sustain {
            await Task.sleep(seconds: sustain)
        }
        activated = false
    }
    
    public func activate() {
        activated = true
    }
    
    public func deactivate() {
        activated = false
    }
    
    public var output: Signal {
        return Signal { time -> Sample in
            if self.internalTriggeredTime == nil && self.activated {
                self.internalTriggeredTime = time
                return 0
            }
            
            guard let triggeredTime = self.internalTriggeredTime else {
                return 0
            }
            
            if self.internalReleasedTime == nil && !self.activated {
                self.internalReleasedTime = time
                return self.sustain
            }
            
            let elapsedTime = time - triggeredTime
            
            switch elapsedTime {
            case ..<self.attack:
                return self.attackShape(elapsedTime / self.attack)
            case ..<(self.attack + self.decay):
                return self.decayShape((elapsedTime - self.attack) / self.decay) * (1 - self.sustain) + self.sustain
            case (self.attack + self.decay)...:
                guard let releasedTime = self.internalReleasedTime else {
                    return self.sustainShape(((elapsedTime - (self.attack + self.decay))).truncatingRemainder(dividingBy: 1)) * self.sustain
                }
                                        
                if releasedTime + self.release <= time {
                    self.internalTriggeredTime = nil
                    self.internalReleasedTime = nil
                    
                    return 0
                }

                return self.releaseShape((time - releasedTime) / self.release) * self.sustain
            default:
                return 0
            }
        }
    }
}
