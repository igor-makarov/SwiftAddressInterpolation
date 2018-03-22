//
//  LatLon.swift
//  AddressInterpolation
//
//  Created by Igor Makarov on 22/03/2018.
//

import Foundation
import Commander

public struct LatLon {
    public let lat: Double
    public let lon: Double
    
    public init(lat: Double, lon: Double) {
        self.lat = lat
        self.lon = lon
    }
    
    static let nan = LatLon(lat: .nan, lon: .nan)
    public var isNan: Bool { return lat.isNaN || lon.isNaN }
    public var description: String {
        return "\(lat),\(lon)"
    }
}
