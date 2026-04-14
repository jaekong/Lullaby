import Foundation

public protocol LBEngine {
    func setOutput(to signal: Outputting) async
    init() async throws
    func prepare() throws
    func start() throws
    func stop() throws
    static func playTest(of signal: Outputting, for seconds: Double) async throws
}
