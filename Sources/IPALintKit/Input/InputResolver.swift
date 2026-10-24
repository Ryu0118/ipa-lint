import FileManagerProtocol
import Foundation

/// Turns an `.ipa`, `.xcarchive`, or `.app` path into the `.app` directory to inspect.
package struct InputResolver: Sendable {
    private let fileManager: any FileManagerProtocol
    private let extractor: any ArchiveExtracting

    package init(fileManager: some FileManagerProtocol, extractor: some ArchiveExtracting) {
        self.fileManager = fileManager
        self.extractor = extractor
    }

    /// Resolves `input`, unpacking an `.ipa` into a fresh temporary directory.
    package func resolve(_ input: URL) async throws -> ResolvedInput {
        guard fileManager.fileExists(atPath: input.path(percentEncoded: false)) else {
            throw InputError.notFound(input.path(percentEncoded: false))
        }
        switch input.pathExtension {
        case "app":
            return ResolvedInput(appURL: input, temporaryDirectory: nil)
        case "xcarchive":
            let app = try findApp(in: input.appending(path: "Products/Applications"), input: input)
            return ResolvedInput(appURL: app, temporaryDirectory: nil)
        case "ipa":
            return try await unpack(input)
        default:
            throw InputError.unsupportedType(input.path(percentEncoded: false))
        }
    }

    private func unpack(_ ipa: URL) async throws -> ResolvedInput {
        let directory = fileManager.temporaryDirectory.appending(path: "ipa-lint-\(UUID().uuidString)")
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        do {
            try await extractor.extract(archiveAt: ipa, into: directory)
            let app = try findApp(in: directory.appending(path: "Payload"), input: ipa)
            return ResolvedInput(appURL: app, temporaryDirectory: directory)
        } catch {
            try? fileManager.removeItem(at: directory)
            throw error
        }
    }

    private func findApp(in directory: URL, input: URL) throws -> URL {
        let names = (try? fileManager.contentsOfDirectory(atPath: directory.path(percentEncoded: false))) ?? []
        guard let name = names.sorted().first(where: { $0.hasSuffix(".app") }) else {
            throw InputError.appNotFound(input.path(percentEncoded: false))
        }
        return directory.appending(path: name)
    }
}
