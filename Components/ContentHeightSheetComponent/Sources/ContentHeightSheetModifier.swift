import SwiftUI

private struct ContentHeightSheetModifier: ViewModifier {
	@State private var contentHeight: CGFloat = .zero

	private var contentHeightMeasurerView: some View {
		GeometryReader { geometry in
			Color.clear
				.onChange(of: geometry.size.height, initial: true) { _, newHeight in
					contentHeight = newHeight
				}
		}
	}

	func body(content: Content) -> some View {
		content
			.background(contentHeightMeasurerView)
			.presentationDetents([.height(contentHeight)])
	}
}

public extension View {
	func adjustSheetHeightToContent() -> some View {
		self.modifier(ContentHeightSheetModifier())
	}
}
