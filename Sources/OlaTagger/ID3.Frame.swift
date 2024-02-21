//
//  ID3.Frame.swift
//  OlaMusic
//
//  Created by Mike Miklin on 30.11.2023.
//

import Foundation


extension ID3 {
    public struct Frame: Identifiable, Equatable {
        public typealias Value = ID3FrameValue

        public let id = UUID()
        let tag: Tag
        private(set) var major: UInt8 = 4
        public let value: (any Value)

        let flags: Flags

        public var name: String
        public var size: UInt32 { value.size }
        let headerSize: UInt32 = 10
    }
}

extension ID3.Frame {
    init(tag: Tag, value: any Value, major: UInt8? = nil) {
        self.tag = tag
        self.name = tag.rawValue
        self.value = value
        self.flags = Flags()
        if let major { self.major = major }
    }
    init?(data orig: inout UData, major: UInt8? = nil) {
        if let major { self.major = major }
        var data = orig

        guard data.count >= headerSize,
              data.prefix(2) != [0,0],
              let name = String(bytes: data.prefix(4), encoding: .ascii)
        else { return nil }

        data.removeFirst(4)

        // v2.4 frame size
        let (prefix, shift): (Int?, Int?) = switch self.major {
        // case 2: (3, 8)
        case 3: (4, 8)
        case 4: (4, 7)
        default: (nil, nil)
        }
        guard let prefix, let shift else { return nil }
        let size = data.prefix(prefix).reduce(0) { ($0 << shift) | UInt32($1) }
        data.removeFirst(prefix)

        guard let flags = Flags(bytes: data) else { return nil }
        self.flags = flags
        data.removeFirst(2)

        guard data.count >= size else { return nil }

        self.name = name
        tag = Tag(rawValue: name) ?? .other
        guard let value = tag.getValue(data: Array(data[..<Int(size)])) else { return nil }
        self.value = value

        orig = Array(data.dropFirst(Int(size)))
    }
    func encode() -> UData? {
        let valueData = value.encode()
        if valueData.isEmpty { return nil }

        var result = name.chars
        result += self.major == 3 ? size.toUInt8 : size.toUInt7
        result += flags.toUint8
        result += valueData
        return result
    }
    public static func == (lhs: ID3.Frame, rhs: ID3.Frame) -> Bool {
        return (
            lhs.tag == rhs.tag &&
            lhs.name == rhs.name &&
            lhs.value == rhs.value
        )
    }
}

extension ID3 {
    public typealias Frames = [Frame]
}
extension ID3.Frames {
    var size: UInt32 {
        reduce(0, { $0 + $1.headerSize + $1.size })
    }
    func encode() -> UData {
        compactMap { $0.encode() }.reduce(UData(), +)
    }
    mutating func merge(_ source: ID3.Frames) {
        source.forEach { self[$0.tag] = $0 }
    }
    public subscript (tag: ID3.Frame.Tag) -> ID3.Frame? {
        get { first(where: { $0.tag == tag }) }
        set {
            guard let newValue else {
                removeAll { $0.tag == tag }
                return
            }
            if let index = firstIndex(where: { $0 == newValue }) {
                self[index] = newValue
            } else {
                self.append(newValue)
            }
        }
    }
}
