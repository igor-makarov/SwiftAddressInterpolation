//
//  main.swift
//  CLI
//
//  Created by Igor Makarov on 20/03/2018.
//

import Foundation
import AddressInterpolation
import Commander

extension LatLon: ArgumentConvertible {
    public init(parser: ArgumentParser) throws {
        guard let latLonString = parser.shift() else {
            throw ArgumentError.missingValue(argument: nil)
        }
        let latLonStrings = Array(latLonString.trimmingCharacters(in: .whitespaces).split(separator: ","))
        guard latLonStrings.count == 2 else {
            throw ArgumentError.invalidType(value: "\(latLonStrings)", type: "lat/lon", argument: nil)
        }
        guard let lat = Double(latLonStrings[0]) else {
            throw ArgumentError.invalidType(value: String(latLonStrings[0]), type: "number", argument: nil)
        }
        guard let lon = Double(latLonStrings[1]) else {
            throw ArgumentError.invalidType(value: String(latLonStrings[1]), type: "number", argument: nil)
        }
        self.init(lat: lat, lon: lon)
    }
}

guard let dir = ProcessInfo.processInfo.environment["INTERPOLATION_DATA_DIR"] else {
    print("INTERPOLATION_DATA_DIR not set", stream: .stderr)
    exit(1)
}

command(
    Argument<LatLon>("coordinate", description: "Disambiguation coordinate"),
    Argument<String>("house_number", description: "House to lookup"),
    Argument<String>("street", description: "Street identifier")
) { (coordinate: LatLon, houseNumber: String, street: String) in
    let interpolator = try Interpolator(dataDirectory: URL(fileURLWithPath: dir))
    let result = try interpolator.interpolate(street: street, houseNumber: houseNumber, coordinate: coordinate)
    if let result = result {
        print(result)
    } else {
        print("Not found", stream: .stderr)
        exit(1)
    }
}.run()



