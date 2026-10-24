import FileManagerProtocol
import Foundation

/// Opens an input path as `AppContents` for the duration of a closure, then deletes anything it unpacked.
package struct AppReader: Sendable {
    private let fileManager: any FileManagerProtocol
    private let resolver: InputResolver
    private let loader: AppLoader

    package init(fileManager: some FileManagerProtocol, extractor: some ArchiveExtracting, entitlementsReader: some EntitlementsReading) {
        self.fileManager = fileManager
        resolver = InputResolver(fileManager: fileManager, extractor: extractor)
        loader = AppLoader(fileManager: fileManager, entitlementsReader: entitlementsReader)
    }

    /// Calls `body` with the contents of `input`. Rules read files lazily, so they must run inside `body`.
    package func withContents<Result: Sendable>(
        of input: URL,
        _ body: (AppContents) async throws -> Result,
    ) async throws -> Result {
        let resolved = try await resolver.resolve(input)
        defer {
            if let directory = resolved.temporaryDirectory {
                try? fileManager.removeItem(at: directory)
            }
        }
        return try await body(loader.load(resolved.appURL))
    }
}
