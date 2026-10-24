import Foundation
@testable import IPALintKit
import Testing

struct InputResolverTests {
    /// Pretends to unzip by creating `Payload/<name>` in the destination.
    struct FakeExtractor: ArchiveExtracting {
        let appName: String?

        func extract(archiveAt _: URL, into directory: URL) async throws {
            guard let appName else {
                return
            }
            try FileManager.default.createDirectory(at: directory.appending(path: "Payload/\(appName)"), withIntermediateDirectories: true)
        }
    }

    @Test("an .ipa resolves to the app inside Payload/ in a temporary directory")
    func resolvesIPA() async throws {
        let workspace = try TemporaryApp()
        let ipa = workspace.root.appending(path: "Sample.ipa")
        try Data().write(to: ipa)
        let resolver = InputResolver(fileManager: FileManager.default, extractor: FakeExtractor(appName: "Sample.app"))

        let resolved = try await resolver.resolve(ipa)

        #expect(resolved.appURL.lastPathComponent == "Sample.app")
        #expect(resolved.temporaryDirectory != nil)
        try FileManager.default.removeItem(at: #require(resolved.temporaryDirectory))
    }

    @Test("an .xcarchive resolves to Products/Applications/<app>")
    func resolvesArchive() async throws {
        let workspace = try TemporaryApp()
        let archive = workspace.root.appending(path: "Sample.xcarchive")
        try FileManager.default.createDirectory(at: archive.appending(path: "Products/Applications/Sample.app"), withIntermediateDirectories: true)
        let resolver = InputResolver(fileManager: FileManager.default, extractor: FakeExtractor(appName: nil))

        let resolved = try await resolver.resolve(archive)

        #expect(resolved.appURL == archive.appending(path: "Products/Applications/Sample.app"))
        #expect(resolved.temporaryDirectory == nil)
    }

    @Test("an .ipa without an app in Payload/ fails")
    func rejectsEmptyIPA() async throws {
        let workspace = try TemporaryApp()
        let ipa = workspace.root.appending(path: "Empty.ipa")
        try Data().write(to: ipa)
        let resolver = InputResolver(fileManager: FileManager.default, extractor: FakeExtractor(appName: nil))

        await #expect(throws: InputError.appNotFound(ipa.path(percentEncoded: false))) {
            try await resolver.resolve(ipa)
        }
    }

    @Test("other file types are rejected")
    func rejectsUnknownType() async throws {
        let workspace = try TemporaryApp()
        let file = workspace.root.appending(path: "notes.txt")
        try Data().write(to: file)
        let resolver = InputResolver(fileManager: FileManager.default, extractor: FakeExtractor(appName: nil))

        await #expect(throws: InputError.unsupportedType(file.path(percentEncoded: false))) {
            try await resolver.resolve(file)
        }
    }
}
