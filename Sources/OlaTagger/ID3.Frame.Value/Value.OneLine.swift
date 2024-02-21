//
//  Value.OneLine.swift
//  OlaMusic
//
//  Created by Mike Miklin on 01.12.2023.
//

import Foundation


extension ID3.Frame {
    public struct OneLine: ID3FrameValue {
        public let value: String?
        public let data: Data? = nil
        public var size: UInt32

        private var encoder: Encoder = .utf16

        public init(_ value: String, encoding: Encoder? = nil) {
            self.value = value
            if let encoding { encoder = encoding }

            size = 0
            size = UInt32(encode().count)
        }
        public init?(_ orig: UData) {
            var data = orig
            guard let encoder = Encoder(rawValue: data[0])
            else { return nil }

            self.encoder = encoder
            data.removeFirst()

            guard let value = encoder.toString(data: &data) else { return nil }
            self.value = value
            self.size = UInt32(orig.count)
        }
        public func encode() -> UData {
            // guard let value else { return [] }
            return [encoder.rawValue] + encoder.fromString(value: value ?? "")
        }
        public static func == (lhs: Self, rhs: any ID3FrameValue) -> Bool { rhs as? OneLine != nil }
    }
}
