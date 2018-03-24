//
//  Search.swift
//  AddressInterpolation
//
//  Created by Igor Makarov on 22/03/2018.
//

import Foundation
import SQLite

// maximum names to match on
var MAX_NAMES = 10;

// maximum address records to return
var MAX_MATCHES = 20;

/**
 this query should only ever return max 3 rows.
 note: the amount of rows returned does not adequently indicate whether an
 exact match was found or not.
 **/
let SQL = [
    "WITH base AS (",
    "SELECT address.* FROM street.rtree",
    "JOIN street.names ON street.names.id = street.rtree.id",
    "JOIN address ON address.id = street.rtree.id",
    "WHERE (",
    "street.rtree.minX<=?1 AND street.rtree.maxX>=?1 AND",
    "street.rtree.minY<=?2 AND street.rtree.maxY>=?2",
    ")",
    "AND ( %%NAME_CONDITIONS%% )",
    "ORDER BY address.housenumber ASC", // @warning business logic depends on this
    ")",
    "SELECT * FROM (",
    "(",
    "SELECT * FROM base",
    "WHERE housenumber < \"%%TARGET_HOUSENUMBER%%\"",
    "GROUP BY id HAVING( MAX( housenumber ) )",
    "ORDER BY housenumber DESC",
    ")",
    ") UNION SELECT * FROM (",
    "(",
    "SELECT * FROM base",
    "WHERE housenumber >= \"%%TARGET_HOUSENUMBER%%\"",
    "GROUP BY id HAVING( MIN( housenumber ) )",
    "ORDER BY housenumber ASC",
    ")",
    ")",
    "ORDER BY housenumber ASC", // @warning business logic depends on this
    "LIMIT %%MAX_MATCHES%%;"
    ].joined(separator: "\n")

let NAME_SQL = "(street.names.name=?)"

struct Place {
    let id: Int64
    let source: String
    let sourceId: String
    let houseNumber: Double
    let coordinate: LatLon?
    let proj: LatLon
    
    init(columnNames: [String:Int], row: [Binding?]) {
        id = row[columnNames["id"]!]! as! Int64
        source = row[columnNames["source"]!]! as! String
        sourceId = row[columnNames["source_id"]!] as? String ?? ""
        houseNumber = row[columnNames["housenumber"]!]! as! Double
        if let lat = row[columnNames["lat"]!] as? Double,
            let lon = row[columnNames["lon"]!] as? Double {
            coordinate = LatLon(lat: lat, lon: lon)
        } else {
            coordinate = nil
        }
        proj = LatLon(lat: row[columnNames["proj_lat"]!]! as! Double, lon: row[columnNames["proj_lon"]!]! as! Double)
    }
}

extension Connection {
    func search(names: [String], houseNumber: Double, coordinate: LatLon) throws -> [Place] {
        if names.isEmpty { return [] }

        // max conditions to search on
        let maxNames = names.prefix(MAX_NAMES)

        // use named parameters to avoid sending coordinates twice for rtree conditions
        var position = 3 // 1 and 2 are used by lon and lat.

        let nameConditions: [String] = maxNames.map { name in
            let condition = NAME_SQL.replacingOccurrences(of: "?", with: "?\(position)")
            position += 1
            return condition
        }

        let sql = SQL
            .replacingOccurrences(of: "%%NAME_CONDITIONS%%", with: nameConditions.joined(separator: " OR "))
            .replacingOccurrences(of: "%%MAX_MATCHES%%", with: "\(MAX_MATCHES)")
            .replacingOccurrences(of: "%%TARGET_HOUSENUMBER%%", with: "\(houseNumber)")
        let params: [Binding] = [coordinate.lon, coordinate.lat] + Array(maxNames)
        let query = try self.prepare(sql, params)
        let columnMap = Dictionary.init(uniqueKeysWithValues: query.columnNames.enumerated().map { ($1, $0) })
        
        let result = query.map { bindings -> Place in
            return Place.init(columnNames: columnMap, row: bindings)
        }
        return result
    }
}
