//
//  LatLon.swift
//  AddressInterpolation
//
//  Created by Igor Makarov on 22/03/2018.
//

import Foundation

let LESS_THAN_ONE_METER = 0.0000001

public struct LatLon : Equatable {
    public let lat: Double
    public let lon: Double
    
    public init(lat: Double, lon: Double) {
        self.lat = lat
        self.lon = lon
    }
    
    public static let nan = LatLon(lat: .nan, lon: .nan)
    public var isNan: Bool { return lat.isNaN || lon.isNaN }
    public var description: String {
        return String(format: "%.6f,%.6f", lat, lon)
    }
    
    public static func == (lhs: LatLon, rhs: LatLon) -> Bool {
        return abs(lhs.lat - rhs.lat) < LESS_THAN_ONE_METER &&
               abs(lhs.lon - rhs.lon) < LESS_THAN_ONE_METER
    }

}


func deg2rad(_ deg: Double) -> Double {
    return deg * .pi / 180
}

func rad2deg(_ rad: Double) -> Double {
    return rad * 180.0 / .pi
}

func distance(_ a: LatLon, _ b: LatLon) -> Double {
    return rad2deg( acos( sin( deg2rad(a.lat) ) * sin( deg2rad(b.lat) ) +
        cos( deg2rad(a.lat) ) * cos( deg2rad(b.lat) ) * cos( deg2rad(a.lon) - deg2rad(b.lon) )) )
}
func interpolate(distance d: Double, ratio f: Double, a: LatLon, b: LatLon) -> LatLon {
    let A = sin( (1-f) * d ) / sin( d )
    let B = sin( f * d ) / sin( d )
    let X = A * cos( deg2rad(a.lat) ) * cos( deg2rad(a.lon) ) + B * cos( deg2rad(b.lat) ) * cos( deg2rad(b.lon) )
    let Y = A * cos( deg2rad(a.lat) ) * sin( deg2rad(a.lon) ) + B * cos( deg2rad(b.lat) ) * sin( deg2rad(b.lon) )
    let Z = A * sin( deg2rad(a.lat) ) + B * sin( deg2rad(b.lat) )
    return LatLon(
        lat: rad2deg( atan2( Z, sqrt( pow( X, 2 ) + pow( Y, 2 ) ) ) ),
        lon: rad2deg( atan2( Y, X ) )
    )
}
