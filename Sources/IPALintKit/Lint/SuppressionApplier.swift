/// Moves findings matched by `allow` entries aside and reports entries that matched nothing.
package struct SuppressionApplier: Sendable {
    private let configuration: LintConfiguration

    package init(configuration: LintConfiguration) {
        self.configuration = configuration
    }

    /// Splits `findings` into kept and suppressed ones, adding a `stale-allow` finding for each unused entry.
    package func apply(to findings: [Finding]) -> LintReport {
        var kept: [Finding] = []
        var suppressed: [SuppressedFinding] = []
        var used = Set<Int>()
        for finding in findings {
            guard let index = configuration.allow.firstIndex(where: { $0.suppresses(finding) }) else {
                kept.append(finding)
                continue
            }
            used.insert(index)
            suppressed.append(SuppressedFinding(finding: finding, reason: configuration.allow[index].reason))
        }
        return LintReport(findings: Self.sorted(kept + staleFindings(used: used)), suppressed: suppressed)
    }

    private func staleFindings(used: Set<Int>) -> [Finding] {
        let descriptor = RuleCatalog.staleAllow
        guard !configuration.disabledRules.contains(descriptor.id) else {
            return []
        }
        let severity = configuration.settings(for: descriptor.id).severity ?? descriptor.defaultSeverity
        return configuration.allow.indices.filter { !used.contains($0) }.map { index in
            let entry = configuration.allow[index]
            let scope = entry.rule.map { " for rule '\($0)'" } ?? ""
            let message = "The allow entry '\(entry.path.pattern)'\(scope) matches nothing; remove it."
            return Finding(ruleID: descriptor.id, severity: severity, path: ".ipa-lint.yml", message: message)
        }
    }

    private static func sorted(_ findings: [Finding]) -> [Finding] {
        findings.sorted { lhs, rhs in
            (lhs.severity == .error ? 0 : 1, lhs.ruleID, lhs.path) < (rhs.severity == .error ? 0 : 1, rhs.ruleID, rhs.path)
        }
    }
}
