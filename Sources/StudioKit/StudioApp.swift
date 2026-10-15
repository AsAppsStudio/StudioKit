import Foundation

/// One AS Apps title on the App Store.
public struct StudioApp: Identifiable, Hashable, Sendable {
    /// App Store numeric id.
    public let id: String
    public let bundleID: String
    public let name: String
    public let blurb: String

    public var storeURL: URL { URL(string: "https://apps.apple.com/app/id\(id)")! }
    /// Image set name in the package asset catalog.
    public var iconName: String { "icon-\(id)" }
}

public enum StudioApps {
    public static let all: [StudioApp] = [
        .init(id: "6758200639", bundleID: "com.as.tvre.ios", name: "AS Remote", blurb: "Universal TV remote & casting"),
        .init(id: "6757202297", bundleID: "com.as.cleaner", name: "AS Cleaner", blurb: "Free up photo storage"),
        .init(id: "6757927352", bundleID: "com.as.Authy", name: "Auth Kit", blurb: "2FA codes & passkeys"),
        .init(id: "6760897608", bundleID: "com.as.rock.scanner.ai", name: "AS Rock ID", blurb: "Identify rocks with AI"),
        .init(id: "6760654834", bundleID: "com.as.croncraft.app", name: "CronCraft", blurb: "Visual cron builder"),
        .init(id: "6763884150", bundleID: "com.as.ios.receiptrescue", name: "Receipt Rescue", blurb: "AI receipt tracker"),
        .init(id: "6788262183", bundleID: "com.as.familybrief", name: "FamilyBrief", blurb: "Private family planner"),
        .init(id: "6791677299", bundleID: "com.as.pocketpos", name: "PocketPOS", blurb: "Offline point of sale"),
        .init(id: "6804779818", bundleID: "com.as.ios.partygame", name: "Party Games", blurb: "22 games, one phone"),
    ]

    /// Everyone except the running app.
    public static var others: [StudioApp] { all.filter { $0.bundleID != Bundle.main.bundleIdentifier } }
}
