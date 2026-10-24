/// Reads the header and load commands of one thin Mach-O image.
enum MachOSliceReader {
    private static let magic32: UInt32 = 0xFEED_FACE
    private static let magic64: UInt32 = 0xFEED_FACF
    private static let buildVersionCommand: UInt32 = 0x32

    /// The slice for a little-endian thin image at the start of `bytes`, or nil when it is malformed or truncated.
    static func read(_ bytes: MachOBytes) -> MachOSlice? {
        guard let magic = bytes.uint32(at: 0),
              magic == magic32 || magic == magic64,
              let cpuType = bytes.uint32(at: 4),
              let commandCount = bytes.uint32(at: 16),
              let platforms = platforms(in: bytes, from: magic == magic64 ? 32 : 28, commandCount: commandCount)
        else {
            return nil
        }
        return MachOSlice(cpuType: cpuType, platforms: platforms)
    }

    /// Walks `commandCount` load commands from `start`; nil when a command is cut off or declares an impossible size.
    private static func platforms(in bytes: MachOBytes, from start: Int, commandCount: UInt32) -> [UInt32]? {
        var platforms: [UInt32] = []
        var offset = start
        for _ in 0 ..< commandCount {
            guard let command = bytes.uint32(at: offset),
                  let size = bytes.uint32(at: offset + 4).map(Int.init),
                  size >= 8,
                  bytes.contains(offset: offset, count: size)
            else {
                return nil
            }
            if command == buildVersionCommand {
                guard let platform = bytes.uint32(at: offset + 8) else {
                    return nil
                }
                platforms.append(platform)
            }
            offset += size
        }
        return platforms
    }
}
