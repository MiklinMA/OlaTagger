//
//  Value.Popularimeter.swift
//  OlaTagger
//
//  Created by Mike Miklin on 10.12.2024.
//

import Foundation


extension ID3.Frame {
    public struct Popularimeter: ID3FrameValue {
        public var value: String? { self.email }
        public var data: Data? = nil
        public var size: UInt32 { UInt32(encode().count) }

        var email: String
        var rating: UInt8 = 0
        var counter: UInt32 = 0

        public init(_ value: String, rating: UInt8? = nil, counter: UInt32? = nil) {
            self.email = value

            if let rating { self.rating = rating }
            if let counter { self.counter = counter }
        }
        public init?(_ orig: UData) {
            var data = orig

            guard let email = Encoder.iso.toString(data: &data) else { return nil }
            self.email = email

            self.rating = data[0]
            data.removeFirst()

            self.counter = data.reduce(0) { ($0 << 8) | UInt32($1) }
        }
        public func encode() -> UData {
            var result = email.chars + [UInt8.zero]
            result += rating.toUInt8
            result += counter.toUInt8
            return result
        }
        public static func == (lhs: Self, rhs: any ID3FrameValue) -> Bool {
            lhs.email == (rhs as? Popularimeter)?.email
        }
    }
}
