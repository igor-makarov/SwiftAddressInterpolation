import XCTest
@testable import AddressInterpolation

func XCTAssert<T, SeqT>(sequence: SeqT, contains element: T, file: StaticString = #file, line: UInt = #line) where SeqT: Sequence, SeqT.Element == T, T: Equatable {
    for e in sequence {
        if e == element { return }
    }
    XCTFail(file: file, line: line)
}

func XCTAssert<T, SeqT>(sequence: SeqT, doesNotContain element: T, file: StaticString = #file, line: UInt = #line) where SeqT: Sequence, SeqT.Element == T, T: Equatable {
    for e in sequence {
        if e == element { XCTFail(file: file, line: line) }
    }
}

class AddressInterpolationTests: XCTestCase {
    var dataDir: String! = ProcessInfo.processInfo.environment["INTERPOLATION_DATA_DIR"]
    
    override func setUp() {
        super.setUp()
        XCTAssertNotNil(dataDir)
    }
    
    func testExample() throws {
        let interpolator = try Interpolator(dataDirectory: URL(fileURLWithPath: dataDir))
        let result = try interpolator.interpolate(street: "NE Killingsworth St", houseNumber: "5309", coordinate: LatLon(lat: 45.562752, lon: -122.608138))
        XCTAssertNotNil(result)
    }
    static let allTests = [
       ("testExample", testExample),
    ]
}
