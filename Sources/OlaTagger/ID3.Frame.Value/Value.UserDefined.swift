//
//  Value.UserDefined.swift
//  OlaTagger
//
//  Created by Mike Miklin on 10.12.2024.
//

import Foundation


extension ID3.Frame {
    public struct UserDefined: ID3FrameValue {
        public let value: String?
        public let data: Data? = nil
        public var size: UInt32 { UInt32(encode().count) }

        private var encoder: Encoder = .utf16
        public var description: String = ""

        public init(_ value: String, description: String? = nil, encoding: Encoder? = nil) {
            if let description { self.description = description }
            if let encoding { self.encoder = encoding }
            self.value = value
        }
        public init?(_ orig: UData) {
            var data = orig

            guard let encoder = Encoder(rawValue: data[0])
            else { return nil }

            self.encoder = encoder
            data.removeFirst()

            guard let description = encoder.toString(data: &data) else { return nil }
            self.description = description

            guard let value = encoder.toString(data: &data) else { return nil }
            self.value = value
        }
        public func encode() -> UData {
            var result = [encoder.rawValue]
            result += encoder.fromString(value: description) + encoder.nullByte
            result += encoder.fromString(value: value ?? "")
            return result
        }
        public static func == (lhs: Self, rhs: any ID3FrameValue) -> Bool {
            lhs.description == (rhs as? UserDefined)?.description
        }
    }
}
