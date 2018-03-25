//
//  Common.swift
//  AddressInterpolation
//
//  Created by Igor Makarov on 25/03/2018.
//

import Foundation
import Dispatch

extension DispatchSemaphore {
    func locked<T>(_ function:() throws -> T) rethrows -> T {
        self.wait()
        defer { self.signal() }
        return try function()
    }
}
