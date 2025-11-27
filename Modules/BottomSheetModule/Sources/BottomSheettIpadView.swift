import SwiftUI

private enum Constants {
  static let radius: CGFloat = 16
  static let indicatorHeight: CGFloat = 6
  static let indicatorWidth: CGFloat = 60
  static let snapRatio: CGFloat = 0.25
  static let minHeightRatio: CGFloat = 0.3
}

public enum BottomSheetDisplayIpadType {
  case fullScreen
  case halfScreen
  case none
}

public struct BottomSheetIpadView<Content: View>: View {
  @Binding var displayType: BottomSheetDisplayIpadType
  let maxHeight: CGFloat
  let minHeight: CGFloat
  let content: Content

  public init(
    displayType: Binding<BottomSheetDisplayIpadType>,
    maxHeight: CGFloat,
    minHeight: CGFloat,
    @ViewBuilder content: () -> Content
  ) {
    self._displayType = displayType // note the underscore for @Binding
    self.maxHeight = maxHeight
    self.minHeight = minHeight
    self.content = content()
  }

  @GestureState private var translation: CGFloat = 0

  // MARK: - Offset from top edge

  private var offset: CGFloat {
    switch self.displayType {
    case .fullScreen:
      return 0
    case .halfScreen:
      return self.maxHeight * 0.45
    case .none:
      return self.maxHeight - self.minHeight
    }
  }

  private var indicator: some View {
    RoundedRectangle(cornerRadius: Constants.radius)
      .fill(Color.secondary)
      .frame(
        width: Constants.indicatorWidth,
        height: Constants.indicatorHeight
      ).onTapGesture {
        // self.isOpen.toggle()
      }
  }

  public var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        self.indicator.padding()
        self.content
      }
      .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
      .background(Color(.secondarySystemBackground))
      .roundedCorner(8, corners: [.topLeft, .topRight])
      .frame(height: geometry.size.height, alignment: .bottom)
      .offset(y: max(self.offset + self.translation, 0))
      .animation(.interactiveSpring())
      .gesture(
        DragGesture().updating(self.$translation) { value, state, _ in
          state = value.translation.height
        }.onEnded { value in
          let snapDistanceFullScreen = self.maxHeight * 0.35
          let snapDistanceHalfScreen = self.maxHeight * 0.75
          if value.location.y <= snapDistanceFullScreen {
            self.displayType = .fullScreen
          } else if value.location.y > snapDistanceFullScreen,
                    value.location.y <= snapDistanceHalfScreen
          {
            self.displayType = .halfScreen
          } else {
            self.displayType = .none
          }
        }
      )
    }
  }
}

extension View {
  func roundedCorner(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape(RoundedCorner(radius: radius, corners: corners))
  }
}

struct RoundedCorner: Shape {
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners

  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius)
    )
    return Path(path.cgPath)
  }
}
