import Foundation
import IPALintKit
import ProcessRunning
import Subprocess

/// Reads entitlements with `codesign -d --entitlements - --xml`.
package struct CodesignEntitlementsReader: EntitlementsReading {
    private let processRunner: any ProcessRunning

    package init(processRunner: some ProcessRunning = ProcessRunner()) {
        self.processRunner = processRunner
    }

    /// The XML entitlements of `bundle`; nil when the bundle is unsigned (for example an archive built without
    /// signing) or has no entitlements.
    package func entitlementsData(ofBundleAt bundle: URL) async throws -> Data? {
        let result = try await processRunner.run(
            .name("codesign"),
            arguments: ["-d", "--entitlements", "-", "--xml", bundle.path(percentEncoded: false)],
            output: .bytes(limit: 4 * 1024 * 1024),
            error: .string(limit: 64 * 1024),
        )
        let message = result.standardError
        guard result.terminationStatus.isSuccess else {
            if message.contains("not signed") {
                return nil
            }
            throw ToolError.failed(tool: "codesign", status: "\(result.terminationStatus)", message: message)
        }
        return result.standardOutput.isEmpty ? nil : Data(result.standardOutput)
    }
}
