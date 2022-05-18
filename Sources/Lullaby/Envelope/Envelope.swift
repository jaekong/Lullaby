import Foundation

/// ADSR / AR Envelope data with custom curve shapes.
public struct Envelope {
    public var attack: Time
    public var decay: Time? = nil
    public var sustain: Amplitude? = nil
    public var release: Time
    
    public var attackShape: Wave
    public var decayShape: Wave? = nil
    public var sustainShape: Wave? = nil
    public var releaseShape: Wave
    
    public init(attack: Time, decay: Time? = nil, sustain: Amplitude? = nil, release: Time, attackShape: @escaping Wave = BasicWaves.rampUp, decayShape: Wave? = BasicWaves.rampDown, sustainShape: Wave? = BasicWaves.constant, releaseShape: @escaping Wave = BasicWaves.rampDown) {
        
        precondition(attack >= 0, "Attack value should be positive.")
        precondition(release >= 0, "Release value should be positive.")
        
        guard
            let decay = decay,
            let sustain = sustain,
            let decayShape = decayShape,
            let sustainShape = sustainShape
        else {
            self.attackShape = attackShape
            self.releaseShape = releaseShape
            self.attack = attack
            self.release = release
            return
        }
        
        precondition(decay >= 0, "Decay value should be positive.")
        precondition(sustain >= 0, "Sustain value should be positive.")
        
        self.attackShape = attackShape
        self.decayShape = decayShape
        self.sustainShape = sustainShape
        self.releaseShape = releaseShape
        self.attack = attack
        self.decay = decay
        self.sustain = sustain
        self.release = release
    }
}

/// ADSR / AR Envelope Generator with custom curve shapes.
public class EnvelopeGenerator {
    public let envelope: Envelope
    
    private var attackShape: Wave { return envelope.attackShape }
    private var decayShape: Wave? { return envelope.decayShape }
    private var sustainShape: Wave? { return envelope.sustainShape }
    private var releaseShape: Wave { return envelope.releaseShape }
    
    private var attack: Time { return envelope.attack }
    private var decay: Time? { return envelope.decay }
    private var sustain: Amplitude? { return envelope.sustain }
    private var release: Time { return envelope.release }
    
    private var activated: Bool = false
    
    private var internalTriggeredTime: Time? = nil
    private var internalReleasedTime: Time? = nil
    
    private var lastValue: Amplitude? = nil
    
    public init(attack: Time, decay: Time? = nil, sustain: Amplitude? = nil, release: Time, attackShape: @escaping Wave = BasicWaves.rampUp, decayShape: Wave? = BasicWaves.rampDown, sustainShape: Wave? = BasicWaves.constant, releaseShape: @escaping Wave = BasicWaves.rampDown) {
        self.envelope = Envelope(attack: attack, decay: decay, sustain: sustain, release: release, attackShape: attackShape, decayShape: decayShape, sustainShape: sustainShape, releaseShape: releaseShape)
    }
    
    public init(envelope: Envelope) {
        self.envelope = envelope
    }
    
    public func impulse(sustain: Time? = nil) async {
        activate()
        await Task.sleep(seconds: sustain ?? self.attack + self.release)
        deactivate()
    }
    
    public func activate() {
        activated = true
        self.internalReleasedTime = nil
        self.internalTriggeredTime = nil
        self.lastValue = nil
    }
    
    public func deactivate() {
        activated = false
    }
    
    public var output: Signal {
        guard
            let decay = decay,
            let sustain = sustain,
            let decayShape = decayShape,
            let sustainShape = sustainShape
        else {
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
                }
                
                let elapsedTime = time - triggeredTime
                
                if let releasedTime = self.internalReleasedTime {
                    if releasedTime + self.release <= time {
                        self.internalTriggeredTime = nil
                        self.internalReleasedTime = nil
                        self.lastValue = nil
                        
                        return 0
                    }
                    
                    if elapsedTime >= self.attack {
                        return self.releaseShape(min((elapsedTime - self.attack) / self.release, 1))
                    }
                    
                    return self.releaseShape(min((time - releasedTime) / self.release, 1)) * (self.lastValue ?? 1)
                }
                
                switch elapsedTime {
                case ..<self.attack:
                    self.lastValue = self.attackShape(elapsedTime / self.attack)
                    return self.lastValue!
                case self.attack...:
                    if let releasedTime = self.internalReleasedTime, releasedTime + self.release <= time {
                        self.internalTriggeredTime = nil
                        self.internalReleasedTime = nil
                        self.lastValue = nil
                        
                        return 0
                    }
                    
                    return self.releaseShape(min((elapsedTime - self.attack) / self.release, 1))
                default:
                    return 0
                }
            }
        }
        
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
                return self.releaseShape(0) * (self.lastValue ?? sustain)
            }
            
            let elapsedTime = time - triggeredTime
            
            if let releasedTime = self.internalReleasedTime {
                if releasedTime + self.release <= time {
                    self.internalTriggeredTime = nil
                    self.internalReleasedTime = nil
                    self.lastValue = nil
                    
                    return 0
                }
                
                return self.releaseShape((time - releasedTime) / self.release) * (self.lastValue ?? sustain)
            }
            
            switch elapsedTime {
            case ..<self.attack:
                self.lastValue = self.attackShape(elapsedTime / self.attack)
                return self.lastValue!
            case ..<(self.attack + decay):
                self.lastValue = decayShape((elapsedTime - self.attack) / decay) * (1 - sustain) + sustain
                return self.lastValue!
            case (self.attack + decay)...:
                guard let releasedTime = self.internalReleasedTime else {
                    self.lastValue = sustainShape(((elapsedTime - (self.attack + decay))).truncatingRemainder(dividingBy: 1)) * sustain
                    return self.lastValue!
                }
                                        
                if releasedTime + self.release <= time {
                    self.internalTriggeredTime = nil
                    self.internalReleasedTime = nil
                    self.lastValue = nil
                    
                    return 0
                }
                
                return self.releaseShape((time - releasedTime) / self.release) * (self.lastValue ?? sustain)
            default:
                return 0
            }
        }
    }
}
