import SwiftUI

struct SocialButtonStyle: ButtonStyle {
  var borderColor: Color? = nil
  var backgroundColor: Color
  var pressedBackgroundColor: Color? = nil
  var foregroundColor: Color
  var cornerRadius: CGFloat = 12
  var minHeight: CGFloat = 48
  var horizontalPadding: CGFloat = 0
  var elevation: CGFloat = 8

  @Environment(\.isEnabled) private var isEnabled

  func makeBody(configuration: Configuration) -> some View {
    let isPressed = configuration.isPressed
    let bg = isPressed
      ? (pressedBackgroundColor ?? self.backgroundColor.opacity(0.9))
      : self.backgroundColor

    let stroke = self.borderColor

    return configuration.label
      .frame(maxWidth: .infinity, minHeight: self.minHeight, alignment: .center)
      .padding(.horizontal, self.horizontalPadding)
      .foregroundColor(self.foregroundColor.opacity(self.isEnabled ? 1 : 0.5))
      .background(bg)
      .overlay(
        Group {
          if let stroke {
            RoundedRectangle(cornerRadius: self.cornerRadius)
              .stroke(isPressed ? stroke.opacity(0.9) : stroke, lineWidth: 1)
          }
        }
      )
      .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous))
      .shadow(
        color: Color.black.opacity(isPressed || !self.isEnabled ? 0 : 0.15),
        radius: self.elevation, x: 0, y: self.elevation / 2
      )
      .scaleEffect(isPressed ? 0.985 : 1.0)
      .animation(.easeOut(duration: 0.15), value: isPressed)
      .contentShape(RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous))
      .accessibilityAddTraits(.isButton)
  }
}
