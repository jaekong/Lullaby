import Collections

public actor LBBuffer {
    private var internalBuffer: Deque<Float> = []
    
    init() {
        
    }
    
    func append(values: [Float]) {
        internalBuffer.append(contentsOf: values)
    }
    
    func pop(count: Int) -> [Float] {
        Array(internalBuffer.dropFirst(count))
    }
}
