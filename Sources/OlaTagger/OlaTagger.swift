//
//  ID3Tagger.swift
//  OlaMusic
//
//  Created by Mike Miklin on 30.11.2023.
//

import Foundation


public typealias UData = [UInt8]

public struct ID3 {
    let url: URL
    let marker: String = "ID3"
    let major: UInt8
    let minor: UInt8
    let flags: Flags
    public var size: UInt32

    private var data: UData
    private let headerSize = 10
    private let paddingSize = 16
    public var frames: Frames = Frames()

    public init?(url: URL) {
        self.url = url
        guard let immutable = try? Data(contentsOf: url) else { return nil }
        var data = immutable.prefix(headerSize).map { UInt8($0) }

        guard data.count >= headerSize,
              Array(data.prefix(3)) == Array(marker.utf8)
        else { return nil }
        data.removeFirst(3)

        major = data[0]
        minor = data[1]
        flags = data[2]
        data.removeFirst(3)

        size = data.prefix(4).reduce(0) { ($0 << 7) | UInt32($1) }
        print("\(size) \(data.prefix(4).description)")
        data.removeFirst(4)

        // maybe later
        // if flags.exhead {
        //     let size = data.prefix(4).reduce(0) { ($0 << 7) | UInt32($1) }
        // }

        self.data = immutable
            .dropFirst(headerSize)
            .prefix(Int(size))
            .map { UInt8($0) }
    }
    public mutating func load() {
        frames = Frames()

        var data = self.data

        while let frame = Frame(data: &data, major: major) {
            frames.append(frame)
        }
    }
    public mutating func write(keepFields: Bool = true) throws {
        if keepFields {
            if frames.isEmpty { return }

            let changed = frames
            self.load()
            frames.merge(changed)
        }

        let size = headerSize + Int(size)
        guard let current = try? Data(contentsOf: url) else { return }
        let data = Data(encode(shrink: !keepFields) + Array(current.dropFirst(size)))
        try data.write(to: url)
    }
    mutating func encode(shrink: Bool = false) -> UData {
        let size = frames.size
        if shrink {
            self.size = size
        } else {
            if self.size < size {
                self.size = size + UInt32(paddingSize)
            }
        }
        let tail = Int(self.size) - Int(size)

        return (
            marker.chars + [major, minor, flags] + self.size.toUInt7 +
            frames.encode() +
            Array(0..<tail).map { _ in UInt8(0) }
        )
    }
    private func seek(name: String) -> Int? {
        for i in 0..<(data.count - 4) {
            if Array(data[i..<i + 4]) == name.chars {
                return i
            }
        }
        return nil
    }
    public subscript (tag: Frame.Tag) -> (any Frame.Value)? {
        get {
            guard let found = seek(name: tag.rawValue)
            else { return nil }

            var data = Array(self.data.dropFirst(found))
            return Frame(data: &data, major: major)?.value
        }
        mutating set {
            guard let newValue else {
                frames[tag] = nil
                return
            }
            let frame = Frame(tag: tag, value: newValue, major: major)
            frames[tag] = frame
        }
    }
}

