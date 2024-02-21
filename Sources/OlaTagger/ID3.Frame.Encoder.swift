//
//  ID3.Frame.Encoder.swift
//  OlaMusic
//
//  Created by Mike Miklin on 30.11.2023.
//

import Foundation


extension ID3.Frame {
    public enum Encoder: UInt8, Comparable, CaseIterable {
        case iso = 0x00
        case utf16 = 0x01
        case utf16be = 0x02
        case utf8 = 0x03

        public var encoding: String.Encoding {
            switch self {
            case .iso: .isoLatin1
            case .utf16: .utf16
            case .utf16be: .utf16BigEndian
            case .utf8: .utf8
            }
        }

        public var nullByte: UData {
            self < .utf16 ? [.zero] : [.zero, .zero]
        }

        public func toString(data orig: inout UData) -> String? {
            var data = orig
            if data.isEmpty { return nil }

            data = if self < .utf16 {
                data.prefix { $0 != 0 }
            } else {
                data.enumerated()
                    .filter { $0.offset % 2 == 0 && $0.offset < data.count - 1 }
                    .prefix {
                        data[$0.offset] != .zero ||
                        data[$0.offset + 1] != .zero
                    }
                    .reduce(UData()) {
                        $0 + [
                            data[$1.offset],
                            data[$1.offset + 1],
                        ]
                    }
            }
            orig = Array(orig.dropFirst(data.count + nullByte.count))
            return String(bytes: data, encoding: encoding)
        }
        public func fromString(value: String) -> UData {
            guard let result = value.data(using: encoding)?.map({ UInt8($0) })
            else { return [] }
            return result
        }
        public static func < (lhs: Self, rhs: Self) -> Bool {
            let values: [Encoder: Int] = [.iso: 0, .utf8: 1, .utf16: 2, .utf16be: 3]
            return values[lhs]! < values[rhs]!
        }

    }
}
