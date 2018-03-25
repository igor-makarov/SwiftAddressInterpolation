//
//  Expand.swift
//  SwiftPostal
//
//  Created by Igor Makarov on 19/03/2018.
//

import Foundation
import SwiftPostal
import SQLite
import Dispatch

public enum InterpolationError: Error {
    public typealias RawValue = Int
    case houseNumberError
}

public struct Interpolator {
    public struct Result {
        public enum ResultType: CustomStringConvertible {
            case exact
            case close
            case interpolated
            public var description: String {
                switch self {
                case .exact: return "exact"
                case .close: return "close"
                case .interpolated: return "interpolated"
                }
            }
        }
        public let type: ResultType
        public let source: String
        public let id: String
        public let number: String
        public let coordinate: LatLon
    }
    
    
    private let _database: Connection
    private static let _postalLock = DispatchSemaphore(value: 1)
    
    public init(dataDirectory: URL) throws {
        let addressDbPath = dataDirectory.appendingPathComponent("address.db").path
        _database = try Connection(addressDbPath, readonly: true)
        let streetDbPath = dataDirectory.appendingPathComponent("street.db").path
        _ = try Connection(streetDbPath, readonly: true) // check exist
        try _database.prepare("ATTACH DATABASE ? AS street").run([streetDbPath])
    }
    
    public func interpolate(street: String, houseNumber houseNumberString: String, coordinate: LatLon) throws -> Result? {
        Interpolator._postalLock.wait()
        let names = Expander().expand(address: street)
        Interpolator._postalLock.signal()
        guard let houseNumber = houseNumber(string: houseNumberString) else { throw InterpolationError.houseNumberError }
        let res = try _database.search(names: names, houseNumber: houseNumber, coordinate: coordinate)
        
        if res.isEmpty { return nil }
        
        if let match = res.first(where: { row in
            if row.source == "VERTEX" { return false }
            return row.houseNumber == houseNumber
        }) {
            return Result(type: .exact,
                          source: match.source,
                          id: match.sourceId,
                          number: "\(Int(match.houseNumber))",
                coordinate: match.coordinate!)
        }
        
        if let match = res.first(where: { row in
            if row.source == "VERTEX" { return false }
            return floor(row.houseNumber) == floor(houseNumber)
        }) {
            return Result(type: .close,
                          source: match.source,
                          id: match.sourceId,
                          number: "\(Int(match.houseNumber))",
                coordinate: match.coordinate!)
        }
        
        return res.interpolate(houseNumber: houseNumber)
    }
}

struct Segment {
    var before: Place?
    var after: Place?
    var diff: (before: Double, after: Double)?
}

extension Array where Element == Place {
    func interpolate(houseNumber: Double) -> Interpolator.Result? {
        var map = [Int64: Segment]()
        for row in self {
            map[row.id] = map[row.id] ?? Segment(before: nil, after: nil, diff: nil)
            if row.houseNumber < houseNumber { map[row.id]!.before = row }
            if row.houseNumber > houseNumber { map[row.id]!.after = row }
            if let before = map[row.id]!.before, let after = map[row.id]!.after {
                map[row.id]!.diff = (
                    before: before.houseNumber - houseNumber,
                    after: after.houseNumber - houseNumber
                )
            }
        }
        
        var segments = map
            .map { $0.value }
            .filter { $0.before != nil && $0.after != nil }
        
        if segments.isEmpty { return nil }
        
        segments.sort { abs($0.diff!.before + $0.diff!.after) < abs($1.diff!.before + $1.diff!.after) }
        
        let before = segments.first!.before!
        let after = segments.first!.after!
        
        let A = before.proj
        let B = after.proj
        let distanceMeters = AddressInterpolation.distance(A, B);
        
        var point = A
        if distanceMeters > 0 {
            let ratio = ((houseNumber - before.houseNumber) / (after.houseNumber - before.houseNumber));
            point = AddressInterpolation.interpolate(distance: distanceMeters, ratio: ratio, a: A, b: B)
        }
        
        return Interpolator.Result(type: .interpolated,
                                   source: "mixed",
                                   id: "",
                                   number: "\(Int(floor(houseNumber)))",
            coordinate: point)
    }
}



