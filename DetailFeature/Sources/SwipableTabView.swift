import SwiftUI

public struct SwipableTabView: View {
  public enum Tab: Equatable, CaseIterable {
    case info, review
    public var title: String {
      switch self {
      case .info:
				return String(
					localized: "Info",
					bundle: .module
				)
      case .review: 
				return String(
					localized: "Review",
					bundle: .module
				)
      }
    }
  }

  @State private var selectedIndex: Int = 0
  private let tabs: [Tab] = Tab.allCases

  @Namespace private var underlineNS

  let geoWidth: CGFloat
  let onChangeTab: @Sendable (Tab) -> ()

  public init(
    geoWidth: CGFloat,
    onChangeTab: @escaping @Sendable (Tab) -> ()
  ) {
    self.geoWidth = geoWidth
    self.onChangeTab = onChangeTab
  }

  private var segmentWidth: CGFloat {
    self.geoWidth / CGFloat(self.tabs.count)
  }

  public var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        ForEach(Array(self.tabs.enumerated()), id: \.offset) { idx, tab in
          Button {
            withAnimation(.snappy) {
              self.selectedIndex = idx
              self.onChangeTab(tab)
            }
          } label: {
            Text(tab.title)
              .font(.system(size: 16, weight: self.selectedIndex == idx ? .bold : .regular))
              .foregroundStyle(self.selectedIndex == idx ? .primary : .secondary)
              .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
          }
          .contentShape(Rectangle())
          .frame(width: self.segmentWidth, height: 55)
          // Put the underline inside each cell so matchedGeometry can move it
          .overlay(alignment: .bottom) {
            if self.selectedIndex == idx {
              Rectangle()
                .fill(DetailFeatureAsset.Colors.primary.swiftUIColor)
                .frame(width: self.segmentWidth, height: 3)
                .matchedGeometryEffect(id: "underline", in: self.underlineNS)
            } else {
              // Placeholder to keep layout constant
              Color.clear.frame(width: self.segmentWidth, height: 3)
            }
          }
        }
      }
    }
    .frame(height: 55)
  }
}
