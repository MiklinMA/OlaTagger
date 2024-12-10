@testable import OlaTagger
import XCTest


final class OlaTaggerTests: XCTestCase {
    var url: URL!
    var size: UInt32!

    let title = "Название трека"
    let artist = "Исполнитель"
    let album = "Название альбома"
    let artwork = ID3.Frame.Artwork(
        Data(Array(0..<10).map { UInt8($0) }),
        mime: "test/data",
        type: .covba,
        description: "Последовательность"
    )
    let lyrics = ID3.Frame.Lyrics(
        """
        Мороз и солнце, день чудесный
        Еще ты дремлешь, друг прелестный
        """,
        language: "ru",
        description: "Стихи",
        encoding: .utf8
    )
    let popm = ID3.Frame.Popularimeter(
        "ru.olasoft.OlaTagger",
        rating: 255,
        counter: 4294967295
    )

    override func setUpWithError() throws {
        continueAfterFailure = false

        // url = URL.temporaryDirectory.appending(component: UUID().description)
        url = URL(filePath: "/tmp/test.mp3")
        // FileManager.default.createFile(atPath: url.path(), contents: nil)
        try Data([0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA]).write(to: url)
        try create_frames()
    }

    override func tearDownWithError() throws {
        try FileManager.default.removeItem(at: url)
    }

    func create_frames() throws {
        var header = ID3(url: url)!
        header[.title] = ID3.Frame.OneLine(title, encoding: .utf8)
        header[.artist] = ID3.Frame.OneLine(artist, encoding: .utf16)
        header[.album] = ID3.Frame.OneLine(album, encoding: .utf16be)
        header[.artwork] = artwork
        header[.lyrics] = lyrics
        header[.popm] = popm
        try header.write()
        size = header.size
    }

    func test_read_header() throws {
        let header = ID3(url: url)!
        XCTAssertEqual(header.url, url)
        XCTAssertEqual(header.marker, "ID3")
        XCTAssertEqual(header.major, 4)
        XCTAssertEqual(header.minor, 0)
        XCTAssertEqual(header.flags, 0)
        XCTAssertEqual(header.size, size)
        XCTAssertEqual(header.frames.count, 0, "Should be empty before loading")
    }
    func test_load_frames() throws {
        var header = ID3(url: url)!
        header.load()
        XCTAssertEqual(header.frames.count, 6)
        XCTAssertEqual(header[.title]?.value, title)
        XCTAssertEqual(header[.artist]?.value, artist)
        XCTAssertEqual(header[.album]?.value, album)

        guard let artwork = header[.artwork] as? ID3.Frame.Artwork else {
            return XCTFail("Could not cast artwork frame to ID3.Frame.Artwork")
        }
        XCTAssertEqual(artwork.mime, self.artwork.mime)
        XCTAssertEqual(artwork.type, self.artwork.type)
        XCTAssertEqual(artwork.description, self.artwork.description)
        XCTAssertEqual(artwork.data, self.artwork.data)

        guard let lyrics = header[.lyrics] as? ID3.Frame.Lyrics else {
            return XCTFail("Could not cast lyrics frame to ID3.Frame.Lyrics")
        }
        XCTAssertEqual(lyrics.language, self.lyrics.language)
        XCTAssertEqual(lyrics.description, self.lyrics.description)
        XCTAssertEqual(lyrics.value, self.lyrics.value)
    }
    func test_seek_frame_title() throws {
        let header = ID3(url: url)!
        XCTAssertEqual(header[.title]?.value, title)
    }
    func test_seek_frame_artist() throws {
        let header = ID3(url: url)!
        XCTAssertEqual(header[.artist]?.value, artist)
    }
    func test_seek_frame_album() throws {
        let header = ID3(url: url)!
        XCTAssertEqual(header[.album]?.value, album)
    }
    func test_seek_frame_artwork() throws {
        let header = ID3(url: url)!
        guard let artwork = header[.artwork] as? ID3.Frame.Artwork else {
            return XCTFail("Could not cast artwork frame to ID3.Frame.Artwork")
        }
        XCTAssertEqual(artwork.mime, self.artwork.mime)
        XCTAssertEqual(artwork.type, self.artwork.type)
        XCTAssertEqual(artwork.description, self.artwork.description)
        XCTAssertEqual(artwork.data, self.artwork.data)
    }
    func test_seek_frame_lyrics() throws {
        let header = ID3(url: url)!
        guard let lyrics = header[.lyrics] as? ID3.Frame.Lyrics else {
            return XCTFail("Could not cast lyrics frame to ID3.Frame.Lyrics")
        }
        XCTAssertEqual(lyrics.language, self.lyrics.language)
        XCTAssertEqual(lyrics.description, self.lyrics.description)
        XCTAssertEqual(lyrics.value, self.lyrics.value)
    }
    func test_seek_frame_popm() throws {
        let header = ID3(url: url)!
        guard let popm = header[.popm] as? ID3.Frame.Popularimeter else {
            return XCTFail("Could not cast POPM frame to ID3.Frame.Popularimeter")
        }
        XCTAssertEqual(popm.email, self.popm.email)
        XCTAssertEqual(popm.rating, self.popm.rating)
        XCTAssertEqual(popm.counter, self.popm.counter)
    }
    func test_changing_version() throws {
        var header = ID3(url: url)!
        header.load()
        header.major = 3
        header.minor = 1
        try header.write(keepFields: false)

        header = ID3(url: url)!
        XCTAssertEqual(header.major, 3)
        XCTAssertEqual(header.minor, 1)

        XCTAssertEqual(header[.artist]?.value, artist)
    }
    func test_padding_empty() throws {
        var artwork = artwork
        artwork.description = ""

        // clear the header
        var header = ID3(url: url)!
        try header.write(keepFields: false)

        XCTAssertEqual(header.size, header.frames.size)
        XCTAssertEqual(header.frames.size, 0)

        // add padding
        artwork.data = Data(Array(0..<8).map { UInt8($0) })
        header[.artwork] = artwork
        try header.write()

        XCTAssertEqual(header.size, header.frames.size + UInt32(header.paddingSize))

        // fill padding
        let paddingSize = header.size
        (0..<header.paddingSize).forEach { _ in
            artwork.data?.append(contentsOf: [0xFF])
            header[.artwork] = artwork
            try! header.write()

            XCTAssertEqual(header.size, paddingSize)
        }

        // extend padding
        artwork.data?.append(contentsOf: [0xFF])
        header[.artwork] = artwork
        try header.write()
        XCTAssertEqual(header.size, header.frames.size + UInt32(header.paddingSize))
    }


    /*
    func test_existing_file() throws {
        var header: OlaTagger.ID3
        let path = "/tmp/01 - I Saw Her Standing There.mp3"
        let newPath = path.replacing(".mp3", with: " copy.mp3")
        try? FileManager.default.trashItem(at: URL(filePath: newPath), resultingItemURL: nil)
        try FileManager.default.copyItem(atPath: path, toPath: newPath)

        header = OlaTagger.ID3(url: URL(filePath: newPath))!
        header[.title] = ID3.Frame.OneLine("Название трека", encoding: .utf16)
        header[.artist] = ID3.Frame.OneLine("Исполнитель", encoding: .utf16)
        header[.album] = ID3.Frame.OneLine("Название альбома", encoding: .utf16)
        try header.write(keepFields: false)
    }
    */
}
