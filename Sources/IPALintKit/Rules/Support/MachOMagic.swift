import Foundation

/// Recognizes Mach-O files (thin or universal) by their first four bytes.
package enum MachOMagic {
    /// MH_MAGIC, MH_MAGIC_64, FAT_MAGIC, and FAT_MAGIC_64, in both byte orders.
    private static let magics: Set<UInt32> = [
        0xFEED_FACE, 0xFEED_FACF, 0xCAFE_BABE, 0xCAFE_BABF,
        0xCEFA_EDFE, 0xCFFA_EDFE, 0xBEBA_FECA, 0xBFBA_FECA,
    ]

    /// Whether `data` starts with a Mach-O or universal-binary magic number.
    package static func isMachO(_ data: Data) -> Bool {
        guard data.count >= 4 else {
            return false
        }
        let magic = data.prefix(4).reduce(UInt32(0)) { $0 << 8 | UInt32($1) }
        return magics.contains(magic)
    }
}
