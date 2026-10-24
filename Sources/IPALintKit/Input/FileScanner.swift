import FileManagerProtocol
import Foundation

/// Lists every regular file inside an app directory with its size.
package struct FileScanner: Sendable {
    private let fileManager: any FileManagerProtocol

    package init(fileManager: some FileManagerProtocol) {
        self.fileManager = fileManager
    }

    /// The regular files under `root`, sorted by path. Symbolic links and directories are skipped.
    package func scan(_ root: URL) throws -> [BundleFile] {
        let rootPath = root.path(percentEncoded: false)
        return try fileManager.subpathsOfDirectory(atPath: rootPath).sorted().compactMap { subpath in
            let attributes = try fileManager.attributesOfItem(atPath: root.appending(path: subpath).path(percentEncoded: false))
            guard attributes[.type] as? FileAttributeType == .typeRegular else {
                return nil
            }
            let size = (attributes[.size] as? NSNumber)?.intValue ?? 0
            return BundleFile(path: subpath, size: size)
        }
    }
}
