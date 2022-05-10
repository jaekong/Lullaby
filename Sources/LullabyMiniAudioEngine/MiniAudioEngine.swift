import Foundation
import CMiniAudio
import Lullaby

final public class MiniAudioEngine: LBEngine {
    
    private var device: ma_device!
    private var deviceConfig: ma_device_config!
    
    fileprivate var output: Signal = .constant(0)
    
    fileprivate var secondsPerFrame: Float = 0
    fileprivate var secondsOffset: Float = 0

    public init() async throws {
    }

    public func setOutput(to signal: Signal) {
        self.output = signal
    }

    public func prepare() throws {
        device = ma_device()
        deviceConfig = ma_device_config_init(ma_device_type_playback)
        deviceConfig.playback.format = ma_format_f32
        deviceConfig.playback.channels = 1
        deviceConfig.sampleRate = 44100
        
        secondsPerFrame = 1.0 / Float(deviceConfig.sampleRate)
        secondsOffset = 0
        
        deviceConfig.dataCallback = writeCallback
        deviceConfig.pUserData = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        guard ma_device_init(nil, &deviceConfig, &device) == MA_SUCCESS else { throw MiniAudioError.miniAudioDeviceInitFailure }
    }
    
    public func start() throws {
        guard ma_device_init(nil, &deviceConfig, &device) == MA_SUCCESS else {
            throw MiniAudioError.miniAudioDeviceInitFailure
        }
        
        guard ma_device_start(&device) == MA_SUCCESS else {
            ma_device_uninit(&device)
            throw MiniAudioError.miniAudioDeviceStartFailure
        }
    }
    
    public func stop() throws {
        guard ma_device_stop(&device) == MA_SUCCESS else {
            throw MiniAudioError.miniAudioDeviceStopFailure
        }
    }
    
    public static func playTest(of signal: Signal = sine(frequency: 440.0), for seconds: Double = 1) async throws {
        let engine = try await Self()
        engine.setOutput(to: signal)
        try engine.prepare()
        try engine.start()
        await Task.sleep(seconds: seconds)
        try engine.stop()
    }
    
    deinit {
        ma_device_uninit(&device)
    }
    
    enum MiniAudioError: Error {
        case miniAudioInitFailure
        case miniAudioDeviceInitFailure
        case miniAudioDeviceStartFailure
        case miniAudioDeviceStopFailure
    }
}

public func writeCallback(_ device: UnsafeMutablePointer<ma_device>?, _ pOutput: UnsafeMutableRawPointer?, _ pInput: UnsafeRawPointer?, _ frameCount: ma_uint32) -> Void {
    guard (device?.pointee) != nil else { return }
    
    guard var cursor = pOutput else { return }
    
    let selfPointer = Unmanaged<MiniAudioEngine>.fromOpaque((device?.pointee.pUserData)!).takeUnretainedValue()
    
    for frame in 0..<frameCount {
        let time = Float(frame) * selfPointer.secondsPerFrame + selfPointer.secondsOffset
        let sample = selfPointer.output(time)
        cursor.storeBytes(of: sample, as: Float.self)
        cursor = cursor.advanced(by: MemoryLayout<Float>.size)
    }
    
    selfPointer.secondsOffset = (selfPointer.secondsOffset + selfPointer.secondsPerFrame * Float(frameCount))
}
