//
//  File.swift
//  
//
//  Created by Mike Miklin on 21.02.2024.
//

import Foundation

extension BinaryInteger {
    var binaryDescription: String {
        var binaryString = ""
        var internalNumber = self
        var counter = 0

        for _ in (1...self.bitWidth) {
            binaryString.insert(contentsOf: "\(internalNumber & 1)", at: binaryString.startIndex)
            internalNumber >>= 1
            counter += 1
            if counter % 4 == 0 {
                binaryString.insert(contentsOf: " ", at: binaryString.startIndex)
            }
        }

        return binaryString
    }
    var toUInt8: [UInt8] {
        let size = bitWidth / 8
        return Array(1...size).map {
            UInt8(self >> ((size - $0) * 8) & 0xFF)
        }
    }
    var toUInt7: [UInt8] {
        let size = bitWidth / 8

        return Array(1...size).map {
            UInt8(self >> ((size - $0) * 7) & 0b01111111)
        }
    }
}

