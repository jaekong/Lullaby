import XCTest
@testable import Lullaby
@testable import LullabyMusic

final class LullabyMusicTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testChordRecognition() throws {
        let cmaj = Chord(arrayLiteral: .unison, .major(3), .perfect(5))
        
        print(try ChordClass(from: cmaj))
        
    }

}
