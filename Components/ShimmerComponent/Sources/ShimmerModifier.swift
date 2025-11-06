import SwiftUI

public struct Shimmer: ViewModifier {
  var angle: Double = 20
  var speed: Double = 1.2
  var baseTint: Color = .init(.systemGray5)
  var highlight: Color = .white

  @State private var animate = false

  public func body(content: Content) -> some View {
    content
      .overlay {
        GeometryReader { geo in
          let size = geo.size
          // Narrow highlight band (relative to height)
          let bandWidth = max(24, size.height * 1)
          // Gradient just for the moving band
          let band = LinearGradient(
            colors: [
              highlight.opacity(0.0),
              self.highlight.opacity(0.35),
              self.highlight.opacity(0.0)
            ],
            startPoint: .top,
            endPoint: .bottom
          )

          ZStack {
            self.baseTint
            band
              .frame(width: bandWidth)
              .rotationEffect(.degrees(self.angle))
              // travel across, with a bit extra so we don't cut edges
              .offset(x: self.animate ? size.width + bandWidth : -bandWidth)
              .animation(
                .linear(duration: self.speed)
                  .repeatForever(autoreverses: false),
                value: self.animate
              )
          }
          // Only show shimmer where the content exists
          .mask(content)
          .compositingGroup()
        }
      }
      .onAppear { self.animate = true }
  }
}

public extension View {
  func shimmer(
    angle: Double = 35,
    speed: Double = 1.2,
    baseTint: Color = Color(.systemGray5),
    highlight: Color = .white
  ) -> some View {
    modifier(Shimmer(angle: angle, speed: speed, baseTint: baseTint, highlight: highlight))
  }
}
