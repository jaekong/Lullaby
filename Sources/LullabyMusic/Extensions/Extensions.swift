import Foundation

extension Collection where Index == Int {
    public func split(into size: Int) -> [Self.SubSequence] {
        return stride(from: 0, to: count, by: size).map {
            self[$0 ..< Swift.min($0 + size, count)]
        }
    }
}

extension Data {
    public func padded(chunkSize: Int) -> Data {
        if count % chunkSize != 0 {
            let paddingSize = chunkSize - count % chunkSize
            let padding = Data(count: paddingSize)
            var newData = self
            newData.append(padding)
            return newData
        } else {
            return self
        }
    }
}

extension UInt8 {
    public func interlaceBits() -> UInt8 {
        let filtered1 = 0b01010101 & self
        let filtered2 = 0b10101010 & self
        return filtered1 << 1 + filtered2 >> 1
    }
    
    public func binaryString() -> String {
        let number = String(self, radix: 2)
        let padding = String(repeating: "0", count: (8 - number.count))
        return String(padding + number)
    }
}

extension String {
    public func split(into size: Int) -> [Substring] {
        return stride(from: 0, to: count, by: size).map {
            self[(self.index(startIndex, offsetBy: $0)) ..< (self.index(startIndex, offsetBy: $0 + size, limitedBy: endIndex) ?? endIndex)]
        }
    }
}

extension Int {
    public var isPrime: Bool {
        get {
            if self <= 1 {
                return false
            }
            
            if self == 2 || self == 3 {
                return true
            }
            
            for i in 2...(self / 2) {
                if self % i == 0 {
                    return false
                }
            }
            
            return true
        }
    }
    
    public var primeFactors: [(prime: Int, exponent: Int)] {
        get {
            let primes = Int.findPrimes(under: self)
            var factoringPrimes: [(Int, Int)] = []
            
            var currentExponent = 0
            
            for prime in primes {
                guard self % prime == 0 else { continue }
                
                currentExponent = 1
                
                while self % Int(pow(Double(prime), Double(currentExponent))) == 0 {
                    currentExponent += 1
                }
                
                factoringPrimes.append((prime, currentExponent - 1))
            }
            
            return factoringPrimes
        }
    }
    
    public func isSmooth(n: Int) -> Bool {
        guard n >= 2 else { return false }
        return self.primeFactors.filter { (prime, _) -> Bool in prime > n }.count == 0
    }
    
    public static func findPrimes(under max: Int) -> [Int] {
        let preCalculated = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509, 521, 523, 541, 547, 557, 563, 569, 571, 577, 587, 593, 599, 601, 607, 613, 617, 619, 631, 641, 643, 647, 653, 659, 661, 673, 677, 683, 691, 701, 709, 719, 727, 733, 739, 743, 751, 757, 761, 769, 773, 787, 797, 809, 811, 821, 823, 827, 829, 839, 853, 857, 859, 863, 877, 881, 883, 887, 907, 911, 919, 929, 937, 941, 947, 953, 967, 971, 977, 983, 991, 997]
        
        var primes: [Int] = []
        let preCalculatedMax = 1000
        
        if max <= preCalculatedMax {
            primes = preCalculated.filter { $0 <= max }
        } else {
            primes = preCalculated
            
            for number in (preCalculatedMax + 1)...max {
                if number.isPrime {
                    primes.append(Int(number))
                }
            }
        }
        
        return primes
    }

    public static func findSmoothNumbers(n: Int, under max: Int) -> [Int] {
        guard n >= 2 else { return [] }
        
        var result: [Int] = []
        
        for number in 2...max {
            if number.isSmooth(n: n) {
                result.append(number)
            }
        }
        
        return result
    }
}
