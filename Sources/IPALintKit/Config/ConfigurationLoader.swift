import FileManagerProtocol
import Foundation
import Yams

/// Reads and decodes an `.ipa-lint.yml` file.
package struct ConfigurationLoader: Sendable {
    private let fileManager: any FileManagerProtocol

    package init(fileManager: some FileManagerProtocol) {
        self.fileManager = fileManager
    }

    /// Decodes the file at `url`. An empty file is the empty configuration.
    package func load(_ url: URL) throws -> LintConfiguration {
        let path = url.path(percentEncoded: false)
        guard let data = fileManager.contents(atPath: path) else {
            throw ConfigurationError.unreadable(path)
        }
        let text = String(decoding: data, as: UTF8.self)
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .empty
        }
        do {
            return try YAMLDecoder().decode(LintConfiguration.self, from: text)
        } catch {
            throw ConfigurationError.invalid(path: path, detail: String(describing: error))
        }
    }
}
