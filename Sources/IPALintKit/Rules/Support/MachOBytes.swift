import Foundation

/// Bounds-checked big- and little-endian integer reads from a window of `Data` that starts at `base`.
struct MachOBytes {
    let data: Data
    let base: Int

    init(_ data: Data, base: Int = 0) {
        self.data = data
        self.base = base
    }

    func offsetting(by offset: Int) -> MachOBytes? {
        guard offset >= 0, offset <= data.count else {
            return nil
        }
        return MachOBytes(data, base: offset)
    }

    func contains(offset: Int, count: Int) -> Bool {
        offset >= 0 && count >= 0 && count <= data.count - base && offset <= data.count - base - count
    }

    func uint32(at offset: Int, bigEndian: Bool = false) -> UInt32? {
        read(at: offset, width: 4, bigEndian: bigEndian).map { UInt32(truncatingIfNeeded: $0) }
    }

    func uint64(at offset: Int, bigEndian: Bool = false) -> UInt64? {
        read(at: offset, width: 8, bigEndian: bigEndian)
    }

    private func read(at offset: Int, width: Int, bigEndian: Bool) -> UInt64? {
        guard contains(offset: offset, count: width) else {
            return nil
        }
        let start = data.startIndex + base + offset
        let bytes = data[start ..< start + width].map(UInt64.init)
        return (bigEndian ? bytes : bytes.reversed()).reduce(0) { $0 << 8 | $1 }
    }
}
