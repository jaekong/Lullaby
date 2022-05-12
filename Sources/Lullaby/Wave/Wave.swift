import Foundation

public typealias Phase = Precision

/// A type of function that recieves value in 0...1 and returns sample value.
public typealias Wave = (Phase) -> Sample
