import XCTest
@testable import Lullaby
@testable import LullabyMusic

final class LullabyTests: XCTestCase {
    func test() async throws {
        let tuning = Tuning(toneCount: 24, standardFrequency: 440)
        
        let value = Value(value: Sample(tuning.intervals[0]) * 440)
        
        let modulator: Signal = await sine(frequency: value.output) * ((sine(frequency: 1) + 1) * 250) + value.output
        let carrier = sine(frequency: modulator)
        
        Task {
            for i in tuning.intervals {
                await value.setValue(Sample(i * 440))
                await Task.sleep(seconds: 1)
            }
        }

        let engine = try await LBEngine()

        await engine.setOutput(to: carrier)
        try await engine.prepare()
        try await engine.start()
        
        while true {
            await Task.yield()
        }
    }
}
