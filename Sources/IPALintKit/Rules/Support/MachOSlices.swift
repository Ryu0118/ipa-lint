import Foundation

/// Reads the architecture slices of a Mach-O file, thin or universal.
package enum MachOSlices {
    private static let fatMagic: UInt32 = 0xCAFE_BABE
    private static let fatMagic64: UInt32 = 0xCAFE_BABF

    /// The slices of `data`; empty when it is not a Mach-O file or is malformed. A universal file's slices that
    /// are truncated or out of range are skipped.
    package static func read(_ data: Data) -> [MachOSlice] {
        let bytes = MachOBytes(data)
        guard let magic = bytes.uint32(at: 0, bigEndian: true) else {
            return []
        }
        return switch magic {
        case fatMagic: universalSlices(in: bytes, entrySize: 20)
        case fatMagic64: universalSlices(in: bytes, entrySize: 32)
        default: MachOSliceReader.read(bytes).map { [$0] } ?? []
        }
    }

    /// Reads `fat_arch` (20 bytes) or `fat_arch_64` (32 bytes) entries after the 8-byte `fat_header`.
    private static func universalSlices(in bytes: MachOBytes, entrySize: Int) -> [MachOSlice] {
        guard let count = bytes.uint32(at: 4, bigEndian: true).map(Int.init),
              count <= (bytes.data.count - 8) / entrySize
        else {
            return []
        }
        return (0 ..< count).compactMap { index in
            let entry = 8 + index * entrySize
            let offset = entrySize == 20
                ? bytes.uint32(at: entry + 8, bigEndian: true).map(UInt64.init)
                : bytes.uint64(at: entry + 8, bigEndian: true)
            guard let offset, let start = Int(exactly: offset), let slice = bytes.offsetting(by: start) else {
                return nil
            }
            return MachOSliceReader.read(slice)
        }
    }
}
