import Foundation

/// Selects the files whose printable strings the content-scanning rules inspect.
enum ScannableText {
    private static let maximumSize = 100 * 1024 * 1024
    private static let skippedExtensions: Set<String> = [
        "png", "jpg", "jpeg", "gif", "heic", "webp", "pdf", "mp4", "mov", "m4a", "mp3", "caf", "ttf", "otf", "mobileprovision",
    ]

    /// Whether the content of the file at `path` with `size` bytes is worth scanning for strings.
    static func isScannable(path: String, size: Int, skippingFrameworks: Bool) -> Bool {
        if size > maximumSize || path.contains("_CodeSignature/") {
            return false
        }
        if skippingFrameworks, path.contains(".framework/") {
            return false
        }
        let url = URL(filePath: path)
        return url.lastPathComponent != "Assets.car" && !skippedExtensions.contains(url.pathExtension.lowercased())
    }

    /// The printable strings of each scannable file, joined by newlines so a match never spans two runs.
    static func texts(in context: RuleContext, skippingFrameworks: Bool = false) -> [(path: String, text: String)] {
        context.contents.files.compactMap { file in
            guard isScannable(path: file.path, size: file.size, skippingFrameworks: skippingFrameworks),
                  let data = context.data(at: file.path)
            else {
                return nil
            }
            return (file.path, PrintableStrings.extract(from: data).joined(separator: "\n"))
        }
    }
}
