import ArgumentParser

/// Exit statuses this CLI defines beyond ArgumentParser's own (0 success, 64 invalid arguments).
package enum ExitStatus {
    /// The lint found problems that fail the run.
    package static let violations = ExitCode(1)
}
