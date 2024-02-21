//
//  ID3.Frame.swift
//  OlaMusic
//
//  Created by Mike Miklin on 30.11.2023.
//

import Foundation

extension ID3 {
    typealias Flags = UInt8
}
extension ID3.Flags {
    var unsync: Bool {
        get { (self >> 7) & 1 != 0 }
        set { self |= newValue ? 1 << 7 : 0 }
    }
    var exhead: Bool {
        get { (self >> 6) & 1 != 0 }
        set { self |= newValue ? 1 << 6 : 0 }
    }
    var experm: Bool {
        get { (self >> 5) & 1 != 0 }
        set { self |= newValue ? 1 << 5 : 0 }
    }
    var footer: Bool {
        get { (self >> 4) & 1 != 0 }
        set { self |= newValue ? 1 << 4 : 0 }
    }
}

extension ID3.Frame {
    public struct Flags {
        let altertag: Bool
        let alterfil: Bool
        let readonly: Bool
        let grouping: Bool
        let compress: Bool
        let encryptn: Bool
        let unsyncrn: Bool
        let lengthin: Bool

        init() {
            altertag = false
            alterfil = false
            readonly = false
            grouping = false
            compress = false
            encryptn = false
            unsyncrn = false
            lengthin = false
        }

        init?(bytes: [UInt8]) {
            guard bytes.count >= 2 else { return nil }

            altertag = ((bytes[0] >> 6) & 1) != 0
            alterfil = ((bytes[0] >> 5) & 1) != 0
            readonly = ((bytes[0] >> 4) & 1) != 0

            grouping = ((bytes[1] >> 6) & 1) != 0
            compress = ((bytes[1] >> 3) & 1) != 0
            encryptn = ((bytes[1] >> 2) & 1) != 0
            unsyncrn = ((bytes[1] >> 1) & 1) != 0
            lengthin = ((bytes[1] >> 0) & 1) != 0
        }
        var toUint8: [UInt8] {
            var bytes: [UInt8] = [0, 0]
            bytes[0] |= altertag ? 1 << 6 : 0
            bytes[0] |= alterfil ? 1 << 5 : 0
            bytes[0] |= readonly ? 1 << 4 : 0

            bytes[1] |= grouping ? 1 << 6 : 0
            bytes[1] |= compress ? 1 << 3 : 0
            bytes[1] |= encryptn ? 1 << 2 : 0
            bytes[1] |= unsyncrn ? 1 << 1 : 0
            bytes[1] |= lengthin ? 1 << 0 : 0
            return bytes
        }
    }
}

extension ID3.Frame.Artwork {
    public enum PictureType: UInt8 {
        case other = 0x00  // Other
        case pix32 = 0x01  // 32x32 pixels 'file icon' (PNG only)
        case ficon = 0x02  // Other file icon
        case covfr = 0x03  // Cover (front)
        case covba = 0x04  // Cover (back)
        case leafp = 0x05  // Leaflet page
        case media = 0x06  // Media (e.g. label side of CD)
        case soloi = 0x07  // Lead artist/lead performer/soloist
        case artst = 0x08  // Artist/performer
        case condr = 0x09  // Conductor
        case bando = 0x0a  // Band/Orchestra
        case compo = 0x0b  // Composer
        case lyric = 0x0c  // Lyricist/text writer
        case locat = 0x0d  // Recording Location
        case recor = 0x0e  // During recording
        case perfo = 0x0f  // During performance
        case video = 0x10  // Movie/video screen capture
        case brigh = 0x11  // A bright coloured fish
        case illus = 0x12  // Illustration
        case logoa = 0x13  // Band/artist logotype
        case logop = 0x14  // Publisher/Studio logotype
    }
}
