import XCTest
@testable import swift_coredata

final class swift_coredataTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(swift_coredata().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
