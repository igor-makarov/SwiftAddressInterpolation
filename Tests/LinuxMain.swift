import XCTest
@testable import AddressInterpolation_Tests

XCTMain([
    testCase(BasicTests.allTests),
    testCase(HouseNumberTests.allTests),
])
