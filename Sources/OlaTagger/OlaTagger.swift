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
    private var found: Bool = false
    let marker: String = "ID3"
    var major: UInt8 = 4
    var minor: UInt8 = 0
    var flags: Flags = 0
    public var size: UInt32 = 0

    private var data: UData = []
    let headerSize = 10
    let paddingSize: Int
    public var frames: Frames = Frames()

    public init?(url: URL, paddingSize: Int = 128) {
        self.url = url
        self.paddingSize = paddingSize
        guard let immutable = try? Data(contentsOf: url) else { return nil }
        loadHeader(immutable)
    }

    mutating func loadHeader(_ immutable: Data) {
        var data = immutable.prefix(headerSize).map { UInt8($0) }
        guard data.count >= headerSize,
              Array(data.prefix(3)) == Array(marker.utf8)
        else {
            found = false
            return
        }
        data.removeFirst(3)

        major = data[0]
        minor = data[1]
        flags = data[2]
        data.removeFirst(3)

        size = data.prefix(4).reduce(0) { ($0 << 7) | UInt32($1) }
        data.removeFirst(4)

        // TODO: maybe later
        // if flags.exhead {
        //     let size = data.prefix(4).reduce(0) { ($0 << 7) | UInt32($1) }
        // }

        self.data = immutable
            .dropFirst(headerSize)
            .prefix(Int(size))
            .map { UInt8($0) }

        found = true
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

        let skipID3 = found ? headerSize + Int(size) : 0

        guard let current = try? Data(contentsOf: url) else { return }
        let encoded = encode(shrink: !keepFields)

        let data = Data(encoded) + current.dropFirst(skipID3)
        try data.write(to: url)

        loadHeader(data)
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
            frames.encode(major: major) +
            Array(0..<tail).map { _ in UInt8(0) }
        )
    }
    private func seek(name: String) -> Int? {
        if data.count < 4 { return nil }

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
            let frame = Frame(tag: tag, value: newValue)
            frames[tag] = frame
        }
    }
}

