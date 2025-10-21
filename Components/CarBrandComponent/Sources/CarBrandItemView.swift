import SwiftUI

public struct CarBrandItemView: View {
	public let displayName: String
	@Binding public var isSelected: Bool

	/// If true, tapping toggles `isSelected` before calling `onTap`.
	public let togglesOnTap: Bool
	public let activeColor: Color
	public let onTap: () -> Void

	public init(
		displayName: String,
		isSelected: Binding<Bool>,
		togglesOnTap: Bool = true,
		activeColor: Color = .accentColor,
		onTap: @escaping () -> Void = {}
	) {
		self.displayName = displayName
		self._isSelected = isSelected
		self.togglesOnTap = togglesOnTap
		self.activeColor = activeColor
		self.onTap = onTap
	}

	public var body: some View {
		Button {
			if togglesOnTap { isSelected.toggle() }
			onTap()
		} label: {
			Text(displayName)
				.font(.subheadline.weight(.medium))
				.padding(.horizontal, 12)
				.padding(.vertical, 8)
				.background(isSelected ? activeColor : Color.gray.opacity(0.5))
				.foregroundColor(isSelected ? .white : Color.gray.opacity(0.85))
				.clipShape(Capsule())
				.overlay(
					Capsule().stroke(isSelected ? activeColor : .clear, lineWidth: 1)
				)
				.contentShape(Capsule())
				.accessibilityLabel(Text(displayName))
				.accessibilityAddTraits(isSelected ? .isSelected : [])
				.animation(.easeInOut(duration: 0.15), value: isSelected)
		}
		.buttonStyle(.plain)
		.padding(.horizontal, 4)
		.padding(.vertical, 5)
	}
}
