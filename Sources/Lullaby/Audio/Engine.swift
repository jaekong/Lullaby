import Foundation
import SoundIO
import CSoundIO

@available(macOS 12.0.0, *)
public actor LBEngine {
    private let io: SoundIO
    private var eventLoop: Task<Void, Never>!
    private var audioTask: Task<(), Error>?
    private var _inputDeviceCount: Int32?
    private var _outputDeviceCount: Int32?
    
    fileprivate var _output: Signal = .constant(0)
    
    private var device: Device!
    private var out: OutStream!
    
    public func setOutput(to signal: Signal) {
        self._output = signal
    }
    
    public init() async throws {
        io = try SoundIO()
        
        #if os(macOS)
        try io.connect(to: Backend.coreAudio)
        #else
        do {
            try io.connect(to: Backend.jack)
        } catch {
            try io.connect()
        }
        #endif
        
        io.flushEvents()
        
        io.onDevicesChange {
            self._inputDeviceCount = try? $0.inputDeviceCount()
            self._outputDeviceCount = try? $0.outputDeviceCount()
        }
        
        eventLoop = Task.detached {
            while true {
                self.io.waitEvents()
            }
        }
    }
    
    deinit {
        eventLoop?.cancel()
        try! io.withInternalPointer { pointer in
            soundio_disconnect(pointer)
        }
    }
    
    public func prepare() throws {
        print("Device Count:", try self.io.outputDeviceCount())
        device = try self.io.getOutputDevice(at: io.defaultOutputDeviceIndex())
        
        print("Current Device:", device.name)
        
        out = try OutStream(to: device)
        out.format = .float32bitLittleEndian
    }
    
    public func start() async throws {
        audioTask = Task(priority: .high) {
            var secondsOffset: Float = 0
            
            
            out.writeCallback { (outstream, frameCountMin, frameCountMax) in
                let layout = outstream.layout
                let secondsPerFrame = 1.0 / Float(outstream.sampleRate)

                var framesLeft = frameCountMax

                while 0 < framesLeft {
                    var frameCount = framesLeft
                    let areas = try! outstream.beginWriting(theNumberOf: &frameCount)

                    if frameCount == 0 {
                        break
                    }

                    for frame in 0..<frameCount {
                        let time = Float(frame) * secondsPerFrame + secondsOffset
                        
                        
                        let sample = self._output(time)
                        
                        for area in areas!.iterate(over: layout.channelCount) {
                            area.write(sample, stepBy: frame)
                        }
                    }
                    secondsOffset = (secondsOffset + secondsPerFrame * Float(frameCount))
//                        .truncatingRemainder(dividingBy: 1)
                    try! outstream.endWrite()

                    framesLeft -= frameCountMax
                }
            }
            
            try out.open()
            try out.start()
            
            while !Task.isCancelled {
                await Task.yield()
            }
        }
    }
    
    public func stop() {
        audioTask?.cancel()
    }
    
    static public func playTest(of signal: Signal = sine(frequency: 440.0), for seconds: Double = 1) async throws {
        let engine = try await Self()
        await engine.setOutput(to: signal)
        try await engine.prepare()
        try await engine.start()
        await Task.sleep(seconds: seconds)
        await engine.stop()
    }
}
