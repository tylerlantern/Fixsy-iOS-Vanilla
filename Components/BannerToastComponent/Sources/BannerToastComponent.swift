import BannerCenterModule
import SwiftUI

// MARK: - View Modifier Host

public struct BannerHost: ViewModifier {
  @ObservedObject var center: BannerCenter

  public func body(content: Content) -> some View {
    content
      .overlay(alignment: .top) {
        VStack(spacing: 8) {
          ForEach(self.center.toasts) { toast in
            BannerRow(toast: toast)
              .transition(.move(edge: .top).combined(with: .opacity))
          }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .frame(maxWidth: .infinity)
        .zIndex(999)
      }
  }
}

public extension View {
  func bannerHost(_ center: BannerCenter) -> some View {
    self.modifier(BannerHost(center: center))
  }
}

// MARK: - Single Banner Row

struct BannerRow: View {
  let toast: BannerToast

  var body: some View {
    HStack(alignment: .center, spacing: 10) {
      Image(systemName: self.toast.kind.systemImage)
        .imageScale(.large)

      VStack(alignment: .leading, spacing: 2) {
        Text(self.toast.title)
          .font(
            self.toast.body == nil ? .headline : .callout
          )
          .fontWeight(.semibold)
          .lineLimit(2)
          .minimumScaleFactor(0.9)

        if let body = toast.body {
          Text(body)
            .font(.footnote)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
    }
    .padding(.vertical, 12)
    .padding(.horizontal, 12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .glassEffect(
      .regular
        .tint(self.toast.kind.tint.opacity(0.5))
        .interactive(),
      in: RoundedRectangle(cornerRadius: 16, style: .continuous)
    )
    .foregroundStyle(self.toast.kind.tint)
    .shadow(radius: 8, y: 3)
  }
}
