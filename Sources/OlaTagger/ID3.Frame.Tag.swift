//
//  ID3.Frame.Tag.swift
//  OlaMusic
//
//  Created by Mike Miklin on 01.12.2023.
//

import Foundation


extension ID3.Frame {
    public enum Tag: String {
        case title = "TIT2"
        case album = "TALB"
        case artist = "TPE1"
        case artwork = "APIC"
        case lyrics = "USLT"
        case popm = "POPM"

        case other = "UNKN"

        func getValue(data: UData) -> (any Value)? {
            return switch self {
            case .title: OneLine(data)
            case .album: OneLine(data)
            case .artist: OneLine(data)
            case .artwork: Artwork(data)
            case .lyrics: Lyrics(data)
            case .popm: Popularimeter(data)
            default: Unknown(data)
            }
        }
        func check(value: any Value) -> Bool {
            return switch self {
            case .title: (value as? OneLine) != nil
            case .album: (value as? OneLine) != nil
            case .artist: (value as? OneLine) != nil
            case .artwork: (value as? Artwork) != nil
            case .lyrics: (value as? Lyrics) != nil
            case .popm: (value as? Popularimeter) != nil
            default: false
            }
        }
    }
}
