import Foundation
@testable import IPALintKit
import Testing

struct MachOMagicTests {
    @Test(
        "recognizes thin 64-bit, universal, and big-endian headers but not other files",
        arguments: [
            ([0xCF, 0xFA, 0xED, 0xFE], true),
            ([0xCA, 0xFE, 0xBA, 0xBE], true),
            ([0xFE, 0xED, 0xFA, 0xCF], true),
            ([0x89, 0x50, 0x4E, 0x47], false),
            ([0xCF, 0xFA], false),
        ] as [([UInt8], Bool)],
    )
    func recognizes(bytes: [UInt8], expected: Bool) {
        #expect(MachOMagic.isMachO(Data(bytes)) == expected)
    }
}
