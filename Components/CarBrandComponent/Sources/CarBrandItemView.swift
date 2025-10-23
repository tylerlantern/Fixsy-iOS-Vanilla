import SwiftUI

public struct CarBrandItemView: View {
  public let displayName: String
  @Binding public var isSelected: Bool

  /// If true, tapping toggles `isSelected` before calling `onTap`.
  public let togglesOnTap: Bool
  public let activeColor: Color
  public let onTap: () -> ()

  public init(
    displayName: String,
    isSelected: Binding<Bool>,
    togglesOnTap: Bool = true,
    activeColor: Color = .accentColor,
    onTap: @escaping () -> () = {}
  ) {
    self.displayName = displayName
    self._isSelected = isSelected
    self.togglesOnTap = togglesOnTap
    self.activeColor = activeColor
    self.onTap = onTap
  }

  public var body: some View {
    Button {
      if self.togglesOnTap { self.isSelected.toggle() }
      self.onTap()
    } label: {
      Text(self.displayName)
        .font(.subheadline.weight(.medium))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(self.isSelected ? self.activeColor : Color.gray.opacity(0.5))
        .foregroundColor(self.isSelected ? .white : Color.gray.opacity(0.85))
        .clipShape(Capsule())
        .overlay(
          Capsule().stroke(self.isSelected ? self.activeColor : .clear, lineWidth: 1)
        )
        .contentShape(Capsule())
        .accessibilityLabel(Text(self.displayName))
        .accessibilityAddTraits(self.isSelected ? .isSelected : [])
        .animation(.easeInOut(duration: 0.15), value: self.isSelected)
    }
    .buttonStyle(.plain)
    .padding(.horizontal, 4)
    .padding(.vertical, 5)
  }
}
