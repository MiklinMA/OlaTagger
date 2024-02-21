//
//  Value.Lyrics.swift
//  OlaMusic
//
//  Created by Mike Miklin on 02.12.2023.
//

import Foundation


extension ID3.Frame {
    public struct Lyrics: ID3FrameValue {
        public let value: String?
        public let data: Data? = nil
        public var size: UInt32

        private var encoder: Encoder = .utf16
        var language: String = "eng"
        var description: String = ""

        public init(_ value: String, language: String? = nil,
             description: String? = nil, encoding: Encoder? = nil)
        {
            if let language { self.language = language }
            if let description { self.description = description }
            if let encoding { self.encoder = encoding }
            self.value = value

            size = 0
            size = UInt32(encode().count)
        }
        public init?(_ orig: UData) {
            var data = orig

            guard let encoder = Encoder(rawValue: data[0])
            else { return nil }

            self.encoder = encoder
            data.removeFirst()

            guard let language = String(bytes: data.prefix(3), encoding: .utf8) else { return nil }
            self.language = language
            data.removeFirst(3)


            guard let description = encoder.toString(data: &data) else { return nil }
            self.description = description

            guard let value = encoder.toString(data: &data) else { return nil }
            self.value = value

            self.size = UInt32(orig.count)
        }
        public func encode() -> UData {
            var result = [encoder.rawValue] 
            result += language.chars
            result += encoder.fromString(value: description) + encoder.nullByte
            result += encoder.fromString(value: value ?? "")
            return result
        }
        public static func == (lhs: Self, rhs: any ID3FrameValue) -> Bool {
            lhs.language == (rhs as? Lyrics)?.language
        }
    }
}
