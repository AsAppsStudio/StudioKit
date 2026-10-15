import Foundation

/// One review-prompt policy for every AS Apps title.
///
/// Call `noteLaunch()` from the App initializer and `recordSuccess(_:)` at every success moment.
/// When `recordSuccess` returns `true`, flip the binding passed to `studioReviewPrompt(on:)`.
public enum ReviewPrompt {
    public struct Policy: Sendable {
        /// Success moments before the first ask.
        public var minSuccesses = 3
        public var minDaysSinceInstall = 2
        /// Apple shows at most 3 prompts per 365 days anyway.
        public var minDaysBetweenAsks = 120
        public var maxAsksPerVersion = 1
        public init() {}
    }

    public static var policy = Policy()

    // Injection points for tests and QA builds.
    static var defaults: UserDefaults = .standard
    static var now: () -> Date = Date.init
    static var appVersion: () -> String = {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
    }

    private enum Key {
        static let firstLaunch = "studio.review.firstLaunch"
        static let launchCount = "studio.review.launchCount"
        static let successCount = "studio.review.successCount"
        static let lastAsk = "studio.review.lastAsk"
        static let lastAskVersion = "studio.review.lastAskVersion"
        static let asksThisVersion = "studio.review.asksThisVersion"
        static let lastMoment = "studio.review.lastMoment"
        static let all = [firstLaunch, launchCount, successCount, lastAsk, lastAskVersion, asksThisVersion, lastMoment]
    }

    /// Starts the install-age clock and counts launches. Call from the App initializer.
    public static func noteLaunch() {
        startClockIfNeeded()
        defaults.set(defaults.integer(forKey: Key.launchCount) + 1, forKey: Key.launchCount)
    }

    /// Call at every success moment. Returns `true` when a prompt should be shown now (and records the ask).
    @discardableResult
    public static func recordSuccess(_ moment: String) -> Bool {
        startClockIfNeeded()
        let successes = defaults.integer(forKey: Key.successCount) + 1
        defaults.set(successes, forKey: Key.successCount)
        defaults.set(moment, forKey: Key.lastMoment)

        let today = now()
        let version = appVersion()
        guard successes >= policy.minSuccesses,
              let firstLaunch = defaults.object(forKey: Key.firstLaunch) as? Date,
              days(from: firstLaunch, to: today) >= policy.minDaysSinceInstall
        else { return false }

        if let lastAsk = defaults.object(forKey: Key.lastAsk) as? Date,
           days(from: lastAsk, to: today) < policy.minDaysBetweenAsks {
            return false
        }

        let asksThisVersion = defaults.string(forKey: Key.lastAskVersion) == version
            ? defaults.integer(forKey: Key.asksThisVersion) : 0
        guard asksThisVersion < policy.maxAsksPerVersion else { return false }

        defaults.set(today, forKey: Key.lastAsk)
        defaults.set(version, forKey: Key.lastAskVersion)
        defaults.set(asksThisVersion + 1, forKey: Key.asksThisVersion)
        StudioKit.track?("review_prompted", ["moment": moment])
        return true
    }

    /// Clears all stored state (debug/QA).
    public static func reset() {
        Key.all.forEach(defaults.removeObject(forKey:))
    }

    /// `launches=N successes=N lastPrompt=<ISO8601|nil> lastMoment=<moment|nil>`
    public static var debugState: String {
        let lastAsk = (defaults.object(forKey: Key.lastAsk) as? Date).map { ISO8601DateFormatter().string(from: $0) }
        return "launches=\(defaults.integer(forKey: Key.launchCount)) "
            + "successes=\(defaults.integer(forKey: Key.successCount)) "
            + "lastPrompt=\(lastAsk ?? "nil") "
            + "lastMoment=\(defaults.string(forKey: Key.lastMoment) ?? "nil")"
    }

    private static func startClockIfNeeded() {
        if defaults.object(forKey: Key.firstLaunch) == nil {
            defaults.set(now(), forKey: Key.firstLaunch)
        }
    }

    private static func days(from start: Date, to end: Date) -> Int {
        Int(end.timeIntervalSince(start) / 86_400)
    }
}
