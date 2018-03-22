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
    func testExample() {
        let interpolator = try? Interpolator(dataDirectory: URL(fileURLWithPath: "/"))
    }
    static let allTests = [
       ("testExample", testExample),
    ]
}
