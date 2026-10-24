import Foundation

/// Builds minimal Mach-O byte arrays for tests.
enum MachOFixture {
    static let arm64: UInt32 = 0x0100_000C
    static let x86_64: UInt32 = 0x0100_0007
    static let i386: UInt32 = 7

    /// A thin little-endian Mach-O with a filler command followed by one `LC_BUILD_VERSION` per platform.
    static func thin(cpuType: UInt32, platforms: [UInt32] = [], is64: Bool = true) -> Data {
        let fillerSize: UInt32 = 16
        let buildVersionSize: UInt32 = 24
        var commands = Data()
        commands.appendLittleEndian(0x2A)
        commands.appendLittleEndian(fillerSize)
        commands.append(Data(count: Int(fillerSize) - 8))
        for platform in platforms {
            commands.appendLittleEndian(0x32)
            commands.appendLittleEndian(buildVersionSize)
            commands.appendLittleEndian(platform)
            commands.append(Data(count: Int(buildVersionSize) - 12))
        }
        var data = Data()
        data.appendLittleEndian(is64 ? 0xFEED_FACF : 0xFEED_FACE)
        data.appendLittleEndian(cpuType)
        data.appendLittleEndian(0)
        data.appendLittleEndian(2)
        data.appendLittleEndian(UInt32(platforms.count + 1))
        data.appendLittleEndian(UInt32(commands.count))
        data.appendLittleEndian(0)
        if is64 {
            data.appendLittleEndian(0)
        }
        return data + commands
    }

    /// A universal binary wrapping `slices`; `wide` selects `FAT_MAGIC_64` with 32-byte entries.
    static func fat(_ slices: [Data], wide: Bool = false) -> Data {
        let entrySize = wide ? 32 : 20
        var offset = 8 + entrySize * slices.count
        var header = Data()
        header.appendBigEndian(wide ? 0xCAFE_BABF : 0xCAFE_BABE)
        header.appendBigEndian(UInt32(slices.count))
        var body = Data()
        for slice in slices {
            header.appendBigEndian(cpuType(of: slice))
            header.appendBigEndian(0)
            if wide {
                header.appendBigEndian(UInt32(0))
                header.appendBigEndian(UInt32(offset))
                header.appendBigEndian(UInt32(0))
                header.appendBigEndian(UInt32(slice.count))
                header.appendBigEndian(0)
                header.appendBigEndian(0)
            } else {
                header.appendBigEndian(UInt32(offset))
                header.appendBigEndian(UInt32(slice.count))
                header.appendBigEndian(0)
            }
            body.append(slice)
            offset += slice.count
        }
        return header + body
    }

    private static func cpuType(of slice: Data) -> UInt32 {
        slice.subdata(in: 4 ..< 8).enumerated().reduce(UInt32(0)) { $0 | UInt32($1.element) << (8 * UInt32($1.offset)) }
    }
}

extension Data {
    mutating func appendLittleEndian(_ value: UInt32) {
        append(contentsOf: (0 ..< 4).map { UInt8(truncatingIfNeeded: value >> (8 * UInt32($0))) })
    }

    mutating func appendBigEndian(_ value: UInt32) {
        append(contentsOf: (0 ..< 4).reversed().map { UInt8(truncatingIfNeeded: value >> (8 * UInt32($0))) })
    }
}
