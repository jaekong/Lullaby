import Foundation

public func adsr(trigger: Signal, attack: Time, decay: Time, sustain: Amplitude, release: Time) -> Signal {
    var internalTriggeredTime: Time? = nil
    var internalReleasedTime: Time? = nil
    
    precondition(attack >= 0, "Attack value should be positive.")
    precondition(decay >= 0, "Decay value should be positive.")
    precondition(sustain >= 0, "Sustain value should be positive.")
    precondition(release >= 0, "Release value should be positive.")
    
    return Signal({ time -> Sample in
        let triggerSample = trigger(time)
        if internalTriggeredTime == nil && triggerSample >= 0.5 {
            internalTriggeredTime = time
            return 0
        }
        
        guard let triggeredTime = internalTriggeredTime else {
            return 0
        }
        
        if internalReleasedTime == nil && triggerSample < 0.5 {
            internalReleasedTime = time
            return sustain
        }
        
        let elapsedTime = time - triggeredTime
        
        switch elapsedTime {
        case ..<attack:
            return elapsedTime / attack
        case ..<(attack + decay):
            return 1 - ((1 - sustain) / decay) * (elapsedTime - attack)
        case (attack + decay)...:
            guard let releasedTime = internalReleasedTime else {
                return sustain
            }
            
            if releasedTime + release <= time {
                internalTriggeredTime = nil
                internalReleasedTime = nil
            }
            
            return sustain - (sustain * (time - releasedTime) / release)
        default:
            return 0
        }
    })
}
