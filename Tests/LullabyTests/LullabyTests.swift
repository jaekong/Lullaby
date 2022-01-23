import XCTest
@testable import Lullaby
@testable import LullabyMusic

final class LullabyTests: XCTestCase {
    func testSine() async throws {
        let value = Value(value: 440)
        
        let carrier = await sine(frequency: value.output)
        
        let task = Task {
            for i in twelveToneEqualTemperamentTuning.intervals {
                await value.setValue(Sample(i * 440))
                await Task.sleep(seconds: 0.5)
            }
        }

        let engine = try await SoundIOEngine()

        await engine.setOutput(to: carrier)
        try await engine.prepare()
        try await engine.start()
        
        await task.value
        
        try await engine.stop()
    }
    
    func testFM() async throws {
        let value = Value(value: 440)
        
        let modulator: Signal = await sine(frequency: value.output) * ((sine(frequency: value.output) + 1) * 250) + value.output
        let carrier = sine(frequency: modulator)
        
        let task = Task {
            for i in twelveToneEqualTemperamentTuning.intervals {
                await value.setValue(Sample(i * 440))
                await Task.sleep(seconds: 0.5)
            }
        }

        let engine = try await SoundIOEngine()

        await engine.setOutput(to: carrier)
        try await engine.prepare()
        try await engine.start()
        
        await task.value
        
        try await engine.stop()
    }
}
