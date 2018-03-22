//
//  main.swift
//  aaa
//
//  Created by Igor Makarov on 20/03/2018.
//

import Foundation
import AddressInterpolation

let printEveryIteration = 1

let dir = "/Volumes/microSD/pelias/data/interpolation"
let interpolator = try Interpolator(dataDirectory: URL(fileURLWithPath: dir))

func test(houseNumber: Int) throws -> TimeInterval {
    let street = "NE Killingsworth St"
    let coordinate = LatLon(lat: 45.562752, lon: -122.608138)

    let date1 = Date()
    let result = try interpolator.interpolate(street: street, houseNumber: "\(houseNumber)", coordinate: coordinate)

    let date2 = Date()
    if houseNumber % printEveryIteration == 0 || houseNumber % printEveryIteration == 1 {
        if let result = result {
            print("Result: house: \(result.number) type: \(result.type.description) coord: \(result.coordinate.description)")
        }
    }
    return date2.timeIntervalSince(date1)
}

func main() {
    var houseNumber = 1
    var time: TimeInterval = 0
    while true {
        let timed = try! test(houseNumber: houseNumber)
        time += timed
        let average = time / Double(houseNumber)
        if houseNumber % printEveryIteration == 0 || houseNumber % printEveryIteration == 1 {
//            print("Average: \(average * 1000)ms, samples: \(houseNumber)")
        }
        houseNumber += 1
    }
}

main()
