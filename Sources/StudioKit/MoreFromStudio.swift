#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI
import UIKit

/// "More from AS Apps" as a `Form`/`List` section.
public struct MoreFromStudioSection: View {
    public init() {}

    public var body: some View {
        Section {
            ForEach(StudioApps.others) { app in
                StudioAppRow(app: app, textColor: .primary, secondaryColor: .secondary)
            }
        } header: {
            Label {
                Text("More from AS Apps", bundle: .module)
            } icon: {
                Image(systemName: "square.grid.2x2")
            }
        } footer: {
            Text("Small, private utilities from the same studio.", bundle: .module)
        }
    }
}

/// "More from AS Apps" rows without section chrome, for custom (non-`Form`) settings screens.
public struct MoreFromStudioList: View {
    private let rowSpacing: CGFloat
    private let textColor: Color
    private let secondaryColor: Color

    public init(rowSpacing: CGFloat = 14, textColor: Color = .primary, secondaryColor: Color = .secondary) {
        self.rowSpacing = rowSpacing
        self.textColor = textColor
        self.secondaryColor = secondaryColor
    }

    public var body: some View {
        VStack(spacing: rowSpacing) {
            ForEach(StudioApps.others) { app in
                StudioAppRow(app: app, textColor: textColor, secondaryColor: secondaryColor)
                    .buttonStyle(.plain)
            }
        }
    }
}

struct StudioAppRow: View {
    let app: StudioApp
    let textColor: Color
    let secondaryColor: Color
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            StudioKit.track?("cross_promo_tapped", ["app": app.id])
            openURL(app.storeURL)
        } label: {
            HStack(spacing: 12) {
                icon
                    .frame(width: 34, height: 34)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(secondaryColor.opacity(0.25), lineWidth: 0.5)
                    }
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(app.name)
                        .font(.body)
                        .foregroundStyle(textColor)
                    Text(app.blurb)
                        .font(.caption)
                        .foregroundStyle(secondaryColor)
                }
                Spacer()
                Image(systemName: "arrow.up.forward")
                    .font(.caption)
                    .foregroundStyle(secondaryColor.opacity(0.6))
            }
            .contentShape(Rectangle())
        }
        .accessibilityHint(Text("Opens the App Store", bundle: .module))
    }

    @ViewBuilder private var icon: some View {
        if let image = UIImage(named: app.iconName, in: .module, with: nil) {
            Image(uiImage: image).resizable().scaledToFill()
        } else {
            Image(systemName: "app.fill").resizable().scaledToFit().foregroundStyle(secondaryColor)
        }
    }
}
#endif
