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
        guard let latString = parser.shift() else {
            throw ArgumentError.missingValue(argument: nil)
        }
        guard let lat = Double(latString) else {
            throw ArgumentError.invalidType(value: latString, type: "number", argument: nil)
        }
        guard let lonString = parser.shift() else { throw ArgumentError.missingValue(argument: nil) }
        guard let lon = Double(lonString) else {
            throw ArgumentError.invalidType(value: lonString, type: "number", argument: nil)
        }
        self.init(lat: lat, lon: lon)
    }
}


command(
    Argument<String>("street", description: "Street identifier"),
    Argument<String>("house_number", description: "House to lookup"),
    Argument<LatLon>("coordinate", description: "Disambiguation coordinate")
) { (street: String, houseNumber: String, coordinate: LatLon) in
    print(street, houseNumber, coordinate)
    print(interpolate(street: street, houseNumber: houseNumber, coordinate: coordinate))
}.run()



