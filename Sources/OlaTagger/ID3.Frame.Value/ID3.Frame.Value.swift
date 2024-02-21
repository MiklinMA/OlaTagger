//
//  ID3.Frame.Value.swift
//  OlaMusic
//
//  Created by Mike Miklin on 30.11.2023.
//

import Foundation

public protocol ID3FrameValue {
    var value: String? { get }
    var data: Data? { get }
    var size: UInt32 { get }

    init?(_ data: UData)
    func encode() -> UData
    static func == (lhs: Self, rhs: any ID3FrameValue) -> Bool
}

func == (lhs: some ID3FrameValue, rhs: some ID3FrameValue) -> Bool {
    type(of: lhs) == type(of: rhs) && lhs == rhs
}

extension ID3.Frame {
    public struct Unknown: ID3FrameValue {
        public var data: Data? = nil
        public var value: String? = nil
        public var size: UInt32 { UInt32(orig.count) }

        var orig: UData

        public func encode() -> UData { orig }

        public init?(_ orig: UData) {
            self.orig = orig
        }
        public static func == (lhs: Self, rhs: any ID3FrameValue) -> Bool { rhs as? Unknown != nil }
    }
}

