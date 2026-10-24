/// How serious a finding is. `error` fails a run; `warning` fails it only in strict mode.
package enum Severity: String, Codable, Sendable, CaseIterable {
    case warning
    case error
}
