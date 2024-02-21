//
//  Value.Artwork.swift
//  OlaMusic
//
//  Created by Mike Miklin on 01.12.2023.
//

import Foundation


extension ID3.Frame {
    public struct Artwork: ID3FrameValue {
        public let value: String? = nil
        public var data: Data?
        public var size: UInt32

        private var encoder: Encoder = .utf16
        var mime: String = "image/"
        var type: PictureType = .covfr
        var description: String = String()

        public init(_ data: Data, mime: String? = nil, type: PictureType? = nil,
             description: String? = nil, encoding: Encoder? = nil
        ) {
            self.data = data

            if let mime { self.mime = mime }
            if let type { self.type = type }
            if let description { self.description = description }
            if let encoding { self.encoder = encoding }

            size = 0
            size = UInt32(encode().count)
        }
        public init?(_ orig: UData) {
            var data = orig

            guard let encoder = Encoder(rawValue: data[0])
            else { return nil }

            self.encoder = encoder
            data.removeFirst()

            guard let mime = encoder.toString(data: &data) else { return nil }
            self.mime = mime

            guard let type = PictureType(rawValue: data[0])
            else { return nil }

            self.type = type
            data.removeFirst()

            guard let description = encoder.toString(data: &data) else { return nil }

            self.description = description
            self.data = Data(data)
            self.size = UInt32(orig.count)
        }
        public func encode() -> UData {
            guard let data, !data.isEmpty else { return [] }

            var result = [encoder.rawValue] + Array(mime.utf8) + [UInt8.zero]
            result += [type.rawValue] + encoder.fromString(value: description)
            result += encoder.nullByte + data.map { UInt8($0) }
            return result
        }
        public static func == (lhs: Self, rhs: any ID3FrameValue) -> Bool {
            lhs.type == (rhs as? Artwork)?.type
        }
    }
}
