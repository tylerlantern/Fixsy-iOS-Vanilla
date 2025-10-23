import SwiftUI

public enum BannerKind {
	case info, success, error

	var title: String {
		switch self {
		case .info: return "Info"
		case .success: return "Success"
		case .error: return "Error"
		}
	}

	var tint: Color {
		switch self {
		case .info: return .blue
		case .success: return .green
		case .error: return .red
		}
	}

	var systemImage: String {
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
	public let message: String
}

// MARK: - Center

public final class BannerCenter: ObservableObject {
	@Published public private(set) var toasts: [BannerToast] = []

	public init() {}

	/// Show a toast and auto-dismiss after `seconds` (default 3).
	@MainActor
	public func show(_ kind: BannerKind, _ message: String, seconds: Double = 3) {
		let toast = BannerToast(kind: kind, message: message)
		toasts.append(toast)

		Task { @MainActor in
			try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
			dismiss(id: toast.id)
		}
	}

	@MainActor
	public func dismiss(id: UUID) {
		if let idx = toasts.firstIndex(where: { $0.id == id }) {
			withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
				_ = toasts.remove(at: idx)
			}
		}
	}

	@MainActor
	public func dismissAll() {
		withAnimation(.spring) { toasts.removeAll() }
	}
}

// MARK: - View Modifier Host

public struct BannerHost: ViewModifier {
	@ObservedObject var center: BannerCenter

	public func body(content: Content) -> some View {
		content
			.overlay(alignment: .top) {
				VStack(spacing: 8) {
					ForEach(center.toasts) { toast in
						BannerRow(toast: toast) {
							center.dismiss(id: toast.id)
						}
						.transition(
							.move(edge: .top)
							.combined(with: .opacity)
						)
					}
				}
				.padding(.horizontal, 12)
				.padding(.top, 8)
				.frame(maxWidth: .infinity)
				.zIndex(999) // stay on top
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
	let onClose: () -> Void

	var body: some View {
		HStack(alignment: .center, spacing: 10) {
			Image(systemName: toast.kind.systemImage)
				.imageScale(.large)

			VStack(alignment: .leading, spacing: 2) {
				Text(toast.kind.title)
					.font(.callout.weight(.semibold))
				Text(toast.message)
					.font(.footnote)
					.fixedSize(horizontal: false, vertical: true)
			}

			Spacer(minLength: 8)

			Button(action: onClose) {
				Image(systemName: "xmark")
					.font(.footnote.weight(.semibold))
					.padding(6)
					.background(.ultraThinMaterial, in: Circle())
			}
			.buttonStyle(.plain)
			.accessibilityLabel("Dismiss banner")
		}
		.padding(.vertical, 10)
		.padding(.horizontal, 12)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(
			RoundedRectangle(cornerRadius: 14, style: .continuous)
				.fill(toast.kind.tint.opacity(0.14))
				.overlay(
					RoundedRectangle(cornerRadius: 14, style: .continuous)
						.stroke(toast.kind.tint.opacity(0.45), lineWidth: 1)
				)
		)
		.foregroundStyle(toast.kind.tint)
		.shadow(radius: 8, y: 3)
	}
}

// MARK: - Example Usage

//struct DemoView: View {
//	@StateObject private var banners = BannerCenter()
//
//	var body: some View {
//		VStack(spacing: 16) {
//			Button("Show Info")    { banners.show(.info, "This is an informational banner.") }
//			Button("Show Success") { banners.show(.success, "Saved successfully!") }
//			Button("Show Error")   { banners.show(.error, "Something went wrong.") }
//			Button("Stack 3") {
//				banners.show(.info, "Queued A")
//				banners.show(.success, "Queued B")
//				banners.show(.error, "Queued C")
//			}
//		}
//		.padding()
//		.bannerHost(banners) // attach once at the screen/container level
//		.navigationTitle("Banner Toast Demo")
//	}
//}
