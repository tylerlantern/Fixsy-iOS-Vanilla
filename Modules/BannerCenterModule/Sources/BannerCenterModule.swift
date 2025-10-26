import SwiftUI

public enum BannerKind {
  case info, success, error

  public var title: String {
    switch self {
    case .info: return "Info"
    case .success: return "Success"
    case .error: return "Error"
    }
  }

  public var tint: Color {
    switch self {
    case .info: return .blue
    case .success: return .green
    case .error: return .red
    }
  }

  public var systemImage: String {
    switch self {
    case .info: return "info.circle.fill"
    case .success: return "checkmark.circle.fill"
    case .error: return "xmark.octagon.fill"
    }
  }
}

public struct BannerToast: Identifiable, Equatable {
  public let id = UUID()
  public let kind: BannerKind
  public let title: String
  public let body: String?

  public init(
    kind: BannerKind,
    title: String,
    body: String?
  ) {
    self.kind = kind
    self.title = title
    self.body = body
  }

  /// Back-compat convenience: use kind.title as the title
  public init(kind: BannerKind, message: String) {
    self.init(kind: kind, title: kind.title, body: message)
  }
}

// MARK: - Center

public final class BannerCenter: ObservableObject {
  @Published public private(set) var toasts: [BannerToast] = []

  public init() {}

  /// New: explicit title + body
  @MainActor
  public func show(
    _ kind: BannerKind, title: String, body: String?, seconds: Double = 3
  ) {
    let toast = BannerToast(kind: kind, title: title, body: body)
    self.toasts.append(toast)

    Task { @MainActor in
      try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
      self.dismiss(id: toast.id)
    }
  }

  /// Convenience: old signature (uses kind.title as title)
  @MainActor
  public func show(_ kind: BannerKind, _ title: String, seconds: Double = 3) {
    self.show(kind, title: title, body: nil, seconds: seconds)
  }

  @MainActor
  public func dismiss(id: UUID) {
    if let idx = toasts.firstIndex(where: { $0.id == id }) {
      withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
        _ = self.toasts.remove(at: idx)
      }
    }
  }

  @MainActor
  public func dismissAll() {
    withAnimation(.spring) { self.toasts.removeAll() }
  }
}
