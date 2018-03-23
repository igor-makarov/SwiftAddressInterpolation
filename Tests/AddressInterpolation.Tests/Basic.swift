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
    static let dirName = "basic"
    let dataDir: URL = {
        let result = ProcessInfo.processInfo.environment["INTERPOLATION_DATA_DIR"]
        XCTAssertNotNil(result)
        return URL(fileURLWithPath: result!).appendingPathComponent(BasicTests.dirName)
    }()
    
    override func setUp() {
        super.setUp()
    }
    
    func testExact() throws {
        let interpolator = try Interpolator(dataDirectory: dataDir)
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

    func testInterpolated() throws {
        let interpolator = try Interpolator(dataDirectory: dataDir)
        let result = try interpolator.interpolate(street: "glasgow street",
                                                  houseNumber: "16",
                                                  coordinate: LatLon(lat: -41.288788, lon: 174.766843))
        XCTAssertNotNil(result)
        XCTAssertEqual(result!,
                       Interpolator.Result(type: .interpolated,
                                           source: "mixed",
                                           id: "",
                                           number: "16",
                                           coordinate: LatLon(lat: -41.2886487, lon: 174.7670925)))
    }

    static let allTests = [
       ("testExact", testExact),
    ]
}
