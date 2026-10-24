import Foundation

/// Formats byte counts for rule messages.
enum ByteSize {
    /// A short size such as `512 B`, `34 KB`, or `2.5 MB`.
    static func describe(_ bytes: Int) -> String {
        if bytes < 1024 {
            return "\(bytes) B"
        }
        if bytes < 1_048_576 {
            return "\(Int((Double(bytes) / 1024).rounded())) KB"
        }
        return megabytes(bytes)
    }

    /// The size in MB with one decimal, such as `3.0 MB`.
    static func megabytes(_ bytes: Int) -> String {
        "\(String(format: "%.1f", Double(bytes) / 1_048_576)) MB"
    }
}
