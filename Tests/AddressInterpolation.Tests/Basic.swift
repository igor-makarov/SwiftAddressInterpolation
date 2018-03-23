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

class BasicTests: XCTestCase {
    var dataDir: String! = ProcessInfo.processInfo.environment["INTERPOLATION_DATA_DIR"]
    
    override func setUp() {
        super.setUp()
        XCTAssertNotNil(dataDir, "INTERPOLATION_DATA_DIR not set!")
    }
    
    func testExact() throws {
        let url = URL(fileURLWithPath: dataDir).appendingPathComponent("basic")
        let interpolator = try Interpolator(dataDirectory: url)
        let result = try interpolator.interpolate(street: "glasgow street",
                                                  houseNumber: "18",
                                                  coordinate: LatLon(lat: -41.288788, lon: 174.766843))
        XCTAssertNotNil(result)
        XCTAssertEqual(result!,
                       Interpolator.Result(type: .exact,
                                           source: "OA",
                                           id: "cfb26db2d9d2f1a8",
                                           number: "18",
                                           coordinate: LatLon(lat: -41.2887878, lon: 174.7668435)))
    }
    
    static let allTests = [
       ("testExact", testExact),
    ]
}
