import Foundation

/// Extracts runs of printable ASCII from binary data, like the `strings` tool.
package enum PrintableStrings {
    /// The runs of printable ASCII bytes (0x20-0x7E and tab) in `data` that are at least `minimumLength` long.
    package static func extract(from data: Data, minimumLength: Int = 8) -> [String] {
        var runs: [String] = []
        data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            var start = 0
            for index in 0 ... bytes.count {
                if index < bytes.count, isPrintable(bytes[index]) {
                    continue
                }
                if index - start >= minimumLength {
                    runs.append(String(decoding: UnsafeRawBufferPointer(rebasing: bytes[start ..< index]), as: UTF8.self))
                }
                start = index + 1
            }
        }
        return runs
    }

    private static func isPrintable(_ byte: UInt8) -> Bool {
        (0x20 ... 0x7E).contains(byte) || byte == 0x09
    }
}
