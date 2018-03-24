//
//  HouseNumber.swift
//  AddressInterpolation
//
//  Created by Igor Makarov on 24/03/2018.
//

import Foundation
import Regex

// constants for controlling how we parse ranges, eg: 'α-β'
// some ranges such as '1-7' are ambiguous; it could mean 'apt 7, no 1'; or
// it could mean 'apt 1, no 7'; or could even be a valid range 'one to seven'.
// note: these values provide a means of setting some sane defaults for which
// ranges we try to parse and which ones we leave.
let MIN_RANGE = 1 // the miniumum amount β is higher than α
let MAX_RANGE = 6 // the maximum amount β is higher than α
let MIN_RANGE_HOUSENUMBER = 10 // the minimum acceptible value for both α and β

private extension String {
    func replace(_ pattern: String, with string: String, caseInsensitive: Bool = false) -> String {
        let regex = try! Regex(pattern: pattern,
                               options: caseInsensitive ? [.caseInsensitive] : [])
        return regex.replaceAll(in: self, with: string)
    }
    
    func match(_ pattern: String) -> Bool {
        let regex = try! Regex(pattern: pattern)
        return regex.matches(self)
    }

    func match(_ pattern: String) -> [String] {
        let regex = try! Regex(pattern: pattern)
        return regex.findFirst(in: self)?.subgroups.flatMap { $0 } ?? []
    }
}

private func parseFloat(_ string: String) -> Double {
    let clean = string.components(separatedBy: CharacterSet.init(charactersIn: "0123456789.").inverted).joined(separator: "")
    return Double(clean)!
}

func houseNumber(string: String) -> Double? {
    var number = string
    
    number = number
        .replacingOccurrences(of: " 1/4", with: "¼")
        .replacingOccurrences(of: " 1/2", with: "½")
        .replacingOccurrences(of: " 3/4", with: "¾")
    
    // remove common english labels
    number = number.replace("\\s+(apartment|apt|lot|space|ste|suite|unit)\\s+", with: "",
                            caseInsensitive: true)
    // remove common mandarin labels
    // see: https://eastasiastudent.net/china/mandarin/postal-address/
    number = number.replace("(号|號|室|宅|楼)", with: "")
    // remove spaces from housenumber. eg: '2 A' -> '2A'
    number = number.replace("\\s+", with: "").lowercased();

    // remove forward slash, minus or hash, but only if between a number and a letter.
    // eg: '2/a' or '2-a' -> '2a'
    if number.match("^[0-9]+(\\/|-|#)[a-z]$") { number = number.replace("\\/|-|#", with: "") }
        // remove forward slash when apartment number is null, eg: '9/-' -> '9'
    else if number.match("^[0-9]+\\/-$") { number = number.replace("\\/|-", with: "") }
        // replace decimal half with unicode half, eg: '9.5' -> '9½'
    else if number.match("^[0-9]+\\.5$") { number = number.replacingOccurrences(of: ".5", with: "½") }
    else {
        // split the components to attempt more advanced parsing
        let split = number.match("^([0-9]+)([\\/|-])([0-9]+)$") as [String]
        if !split.isEmpty {
            let house = split[0], delim = split[1], apt = split[2]
            
            // if the housenumber and apartment number are the same we can safely use either.
            // eg: '1/1' -> '1' or '31/31' -> '31'
            if house == apt { number = house }
                // handle small ranges, eg: '72-74' -> '73'
            else if delim == "-" {
                let start = Int(house)!, end = Int(apt)!, diff = end - start
                
                // don't parse single digit ranges, things like '1-4' are ambiguous
                if start < MIN_RANGE_HOUSENUMBER || end < MIN_RANGE_HOUSENUMBER { return nil }
                
                // ensure the range is within acceptible limits
                if diff <= MAX_RANGE && diff > MIN_RANGE {
                    number = "\(Int(floor( Double(start) + ( Double(diff) / 2 ) )))"
                }
            }
        }
    }
    
    // a format we don't currently support
    // @see: https://github.com/pelias/interpolation/issues/16
    if !number.match("^[0-9]+([a-z]|¼|½|¾)?$") { return nil }
    
    // @note: removes letters such as '2a' -> 2
    var float = parseFloat(number)
    
    // zero house number
    if float <= 0 { return nil }
    
    // if the house number is followed by a single letter [a-z] then we
    // add a fraction to the house number representing the offset.
    // eg: 1a -> 1.1
    let apartment = number.match("^[0-9]+([a-z]|¼|½|¾)$") as [String]
    if !apartment.isEmpty {
        switch apartment[0] {
        case "¼": float += 0.25
        case "½": float += 0.5
        case "¾": float += 0.74
        default:
            let offset = Double(apartment[0].utf8.first!) - 96 // gives a:1, b:2 etc..
            float += offset * 0.03 // add fraction to housenumber for apt;
        }
    }
    
    return float
}
