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
        do {
            io = try SoundIO()
            
            #if os(macOS)
            try io.connect(to: Backend.coreAudio)
            #else
            do {
                try io.connect(to: Backend.jack)
            } catch {
                print("Cannot establish JACK connection")
                do {
                    try io.connect()
                } catch {
                    print("Cannot establish Audio Backend connection")
                }
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
        } catch {
            print("Error occured: ", error.localizedDescription)
            fatalError()
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
        out.format = .signed16bitLittleEndian
        out.softwareLatency = 0
    }
    
    public func start() async throws {
        audioTask = Task(priority: .high) {
            var secondsOffset: Float = 0
            
            
            out.underflowCallback { outstream in
                print("Underflow Occured")
            }
            
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
                            area.write(Int16(sample * Float(Int16.max)), stepBy: frame)
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
            
            try out.withInternalPointer { pointer in
                var latency: Double = 0
                soundio_outstream_get_latency(pointer, &latency)
                print("Latency:", String(format: "%.8f", latency * 1000), "ms")
            }
            
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
