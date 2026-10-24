import Foundation
@testable import IPALintKit
import Testing

struct PrintableStringsTests {
    @Test("splits on non-printable bytes, keeps tabs, and drops runs shorter than the minimum")
    func extractsRuns() {
        var data = Data("hello world".utf8)
        data.append(contentsOf: [0x00, 0xFF])
        data.append(Data("short".utf8))
        data.append(0x0A)
        data.append(Data("a\tb_long_enough".utf8))

        #expect(PrintableStrings.extract(from: data) == ["hello world", "a\tb_long_enough"])
    }

    @Test("honors a custom minimum length and includes runs at both ends of the data")
    func customMinimum() {
        let data = Data("abc".utf8) + Data([0x01]) + Data("defg".utf8)

        #expect(PrintableStrings.extract(from: data, minimumLength: 3) == ["abc", "defg"])
        #expect(PrintableStrings.extract(from: data, minimumLength: 4) == ["defg"])
        #expect(PrintableStrings.extract(from: Data()).isEmpty)
    }

    @Test("treats bytes 0x1F and 0x7F as non-printable but 0x20 and 0x7E as printable")
    func boundaries() {
        let data = Data([0x1F]) + Data("  ~~~~~~".utf8) + Data([0x7F])

        #expect(PrintableStrings.extract(from: data) == ["  ~~~~~~"])
    }

    @Test("scans a 20 MB buffer without trouble")
    func largeInput() {
        let data = Data(repeating: 0x41, count: 20_000_000)

        #expect(PrintableStrings.extract(from: data).map(\.count) == [20_000_000])
    }
}
