import Foundation

final public class DummyEngine: LBEngine {
    private var output: Signal = 0
    private var audioTask: Task<Void, Never>?
    
    public var buffer: Int = 512
    public var sampleRate: Int = 44100
    
    public var printEnabled = true
    
    public var latency: Time {
        return Time(buffer) / Time(sampleRate)
    }
    
    public init() async throws {
        
    }
    
    public func setOutput(to signal: Signal) {
        self.output = signal
    }
    
    public func prepare() throws {
        
    }
    
    public func start() throws {
        audioTask = Task {
            let secondsPerFrame = 1.0 / Float(sampleRate)
            var secondsOffset: Time = 0
            
            while true {
                for _ in 0..<buffer {
                    if printEnabled {
                        print(output(secondsOffset))
                    } else {
                        let _ = output(secondsOffset)
                    }
                    
                    secondsOffset += secondsPerFrame
                }
                
                await Task.sleep(seconds: Double(latency))
                if Task.isCancelled {
                    break
                }
            }
        }
    }
    
    public func stop() throws {
        audioTask?.cancel()
    }
    
    public static func playTest(of signal: Signal, for seconds: Double) async throws {
        let engine = try await Self()
        engine.setOutput(to: signal)
        try engine.prepare()
        try engine.start()
        await Task.sleep(seconds: seconds)
        try engine.stop()
    }
}
