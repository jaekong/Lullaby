import Foundation

public protocol LBEngine {
    func setOutput(to signal: Signal) async
    init() async throws
    func prepare() throws
    func start() throws
    func stop() throws
    static func playTest(of signal: Signal, for seconds: Double) async throws
}
