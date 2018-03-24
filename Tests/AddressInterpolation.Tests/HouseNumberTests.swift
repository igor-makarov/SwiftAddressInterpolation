//
//  HouseNumberTests.swift
//  AddressInterpolation.Tests
//
//  Created by Igor Makarov on 24/03/2018.
//

import XCTest
@testable import AddressInterpolation

class HouseNumberTests: XCTestCase {
    func testHouseNumberInvalid() {
        XCTAssertNil(houseNumber(string: "no numbers"), "no numbers")
        XCTAssertNil(houseNumber(string: ""), "blank")
        XCTAssertNil(houseNumber(string: "0"), "zero")
        XCTAssertNil(houseNumber(string: "0/0"), "zero")
        XCTAssertNil(houseNumber(string: "NULL"), "null")
        XCTAssertNil(houseNumber(string: "S/N"), "no numbers")
        XCTAssertNil(houseNumber(string: "-9"), "no house number")
        XCTAssertNil(houseNumber(string: "V"), "no numbers")
        XCTAssertNil(houseNumber(string: "2-40"), "possible range possibly not")
        XCTAssertNil(houseNumber(string: "2/1"), "ambiguous house/apt")
        XCTAssertNil(houseNumber(string: "1 flat b"), "apartment synonyms")
        XCTAssertNil(houseNumber(string: "4--"), "unrecognised delimiter")
        XCTAssertNil(houseNumber(string: "11-19"), "large ranges")
        XCTAssertNil(houseNumber(string: "1-4"), "ranges containing single digits")
        XCTAssertNil(houseNumber(string: "22/26"), "invalid range delimiter")
        XCTAssertNil(houseNumber(string: "51.1"), "arbitrary decimal suffix")
        XCTAssertNil(houseNumber(string: "260 UNIT #33"), "common label \"unit\" (followed by a number)")
        XCTAssertNil(houseNumber(string: "1434 SUITE #2"), "common label \"suite\" (followed by a number)")
        XCTAssertNil(houseNumber(string: "5285 #1"), "hash delimited numeric suffix")

    }

    func testHouseNumberValid() {
        XCTAssertNotNil(houseNumber(string: "1"), "regular")
        XCTAssertNotNil(houseNumber(string: " 2  A "), "spaces")
        XCTAssertNotNil(houseNumber(string: "3Z"), "unusually high apartment")
        XCTAssertNotNil(houseNumber(string: "4/-"), "null apartment")
        XCTAssertNotNil(houseNumber(string: "5/5"), "same house/apt number")
        XCTAssertNotNil(houseNumber(string: "6-6"), "same house/apt number")
        XCTAssertNotNil(houseNumber(string: "22-26"), "small ranges")
        XCTAssertNotNil(houseNumber(string: "51.5"), "decimal suffix")
        XCTAssertNotNil(houseNumber(string: "326 1/2"), "half suffix")
        XCTAssertNotNil(houseNumber(string: "8¼"), "quarter suffix")
        XCTAssertNotNil(houseNumber(string: "4701 #B"), "hash delimited suffix")
        XCTAssertNotNil(houseNumber(string: "1434 UNIT #B"), "remove common english label \"unit\"")
        XCTAssertNotNil(houseNumber(string: "1434 SUITE #B"), "remove common english label \"suite\"")
        XCTAssertNotNil(houseNumber(string: "158號"), "remove common mandarin label")
    }
    
    func testValues() {
        XCTAssertEqual(22.0, houseNumber(string: "22"), "numeric")
        XCTAssertEqual(22.03, houseNumber(string: "22A"), "apartment")
        XCTAssertEqual(22.78, houseNumber(string: "22z"), "apartment")
        XCTAssertEqual(22.06, houseNumber(string: "22 B"), "apartment with space")
        XCTAssertEqual(9, houseNumber(string: "9/-"), "apartment with a character symbolizing null")
        XCTAssertEqual(1.03, houseNumber(string: "1/A"), "apartment with forward slash between number and letter")
        XCTAssertEqual(200.18, houseNumber(string: "200/F"), "apartment with forward slash between number and letter")
    }

    static let allTests = [
        ("testHouseNumberInvalid", testHouseNumberInvalid),
        ("testHouseNumberValid", testHouseNumberValid),
        ("testValues", testValues),
        ]
}
