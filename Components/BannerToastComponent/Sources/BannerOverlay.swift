import BannerCenterModule
import SwiftUI
import UIKit

@MainActor
public final class BannerOverlay {
  public static let shared = BannerOverlay()

  private var window: UIWindow?
  private var hosting: UIHostingController<AnyView>? // <- erase generic

  private init() {}

  public func install(center: BannerCenter) {
    guard self.window == nil else { return }

    guard let scene = UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .first(where: { $0.activationState == .foregroundActive })
    else {
      return
    }

    let root = AnyView(
      BannerOverlayView()
        .environmentObject(center)
    )

    let host = UIHostingController(rootView: root)
    host.view.backgroundColor = .clear
    host.view.isUserInteractionEnabled = true

    let win = UIWindow(windowScene: scene)
    win.rootViewController = host
    win.windowLevel = .alert + 1
    win.backgroundColor = .clear
    win.isHidden = false
    win.isUserInteractionEnabled = false

    self.hosting = host
    self.window = win
  }

  public func uninstall() {
    self.window?.isHidden = true
    self.window = nil
    self.hosting = nil
  }
}

// Your overlay content
struct BannerOverlayView: View {
  @EnvironmentObject var center: BannerCenter

  var body: some View {
    VStack(spacing: 8) {
      ForEach(self.center.toasts) { toast in
        BannerRow(toast: toast)
          .transition(.move(edge: .top).combined(with: .opacity))
      }
      Spacer(minLength: 0)
    }
    .padding(.horizontal, 12)
    .padding(.top, 8)
    .frame(maxWidth: .infinity, alignment: .top)
    .animation(.spring(), value: self.center.toasts)
  }
}
