/// Shared hooks for every AS Apps host app.
public enum StudioKit {
    /// Analytics sink. Apps with analytics assign it at launch; `nil` means events are dropped.
    public static var track: (@Sendable (String, [String: String]) -> Void)?
}
