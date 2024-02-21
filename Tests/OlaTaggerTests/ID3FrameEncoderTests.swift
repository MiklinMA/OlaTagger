import XCTest
import OlaTagger

public final class ID3FrameEncoderTests: XCTestCase {

    public override func setUpWithError() throws {
        continueAfterFailure = false
    }

    public override func tearDownWithError() throws {
    }

    func check(encoder: OlaTagger.ID3.Frame.Encoder) throws {
        let string = encoder > .iso ?
        "test string with unicode symbols 🥹" :
        "test string without unicode symbols"

        let strings = Array(0...10).map { "\(string) \($0)" }
        var data = Array(strings
            .map { encoder.fromString(value: $0) + encoder.nullByte }
            .joined()
        )

        for i in 0...10 {
            var count = data.count

            guard let result = encoder.toString(data: &data) else {
                return XCTFail("Encoder returns null")
            }
            count -= result.data(using: encoder.encoding)!.count
            count -= encoder.nullByte.count
            XCTAssertEqual(result, "\(string) \(i)")
            XCTAssertEqual(data.count, count)
        }
    }

    public func test_encoder_iso() throws {
        try check(encoder: ID3.Frame.Encoder.iso)
    }
    public func test_encoder_utf8() throws {
        try check(encoder: ID3.Frame.Encoder.utf8)
    }
    public func test_encoder_utf16() throws {
        try check(encoder: ID3.Frame.Encoder.utf16)
    }
    public func test_encoder_utf16be() throws {
        try check(encoder: ID3.Frame.Encoder.utf16be)
    }
}
