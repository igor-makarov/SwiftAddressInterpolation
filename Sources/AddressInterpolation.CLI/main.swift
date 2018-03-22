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
        let latLonStrings = Array(latLonString.split(separator: ","))
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
    print("INTERPOLATION_DATA_DIR not set")
    exit(1)
}

print(CommandLine.arguments)
//let street = CommandLine.arguments[4]
//let houseNumber = CommandLine.arguments[3]
//let coordinate = LatLon(lat: Double(CommandLine.arguments[1])!, lon: Double(CommandLine.arguments[2])!)

let street = "NE Killingsworth St"
//let houseNumber = "5309"
let houseNumber = "5310"
let coordinate = LatLon(lat: 45.562752, lon: -122.608138)

command(
    Argument<LatLon>("coordinate", description: "Disambiguation coordinate"),
    Argument<String>("house_number", description: "House to lookup"),
    Argument<String>("street", description: "Street identifier")
) { (coordinate: LatLon, houseNumber: String, street: String) in
    let interpolator = try Interpolator(dataDirectory: URL(fileURLWithPath: dir))
    let result = try interpolator.interpolate(street: street, houseNumber: houseNumber, coordinate: coordinate)
    print(result)
}.run()



