//
//  Search.swift
//  AddressInterpolation
//
//  Created by Igor Makarov on 22/03/2018.
//

import Foundation
import GRDB

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

struct Place : RowConvertible  {
    let rowid: Int64
    let id: Int64
    let source: String
    let sourceId: String
    let houseNumber: Double
    let coordinate: LatLon
    let parity: String
    let proj: LatLon
    
    init(row: Row) {
        rowid = row["rowid"]!
        id = row["id"]!
        source = row["source"]!
        sourceId = row["source_id"]!
        houseNumber = row["housenumber"]!
        coordinate = LatLon(lat: row["lat"]!, lon: row["lon"]!)
        parity = row["parity"]
        proj = LatLon(lat: row["proj_lat"]!, lon: row["proj_lon"]!)
    }
}

extension DatabaseQueue {
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
        let params: [DatabaseValueConvertible] = [coordinate.lon, coordinate.lat] + names
        return try self.inDatabase { db in
            return try Place.fetchAll(db, sql, arguments: StatementArguments(params))
        }
    }
}
