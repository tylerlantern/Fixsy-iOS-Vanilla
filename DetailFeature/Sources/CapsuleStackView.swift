import SwiftUI

public struct CapsulesStackView<Item: Identifiable & Equatable, Content: View>: View {
  public let items: [Item]
  public let demandedWidthSize: CGFloat
  public let horizontalSpacing: CGFloat
  public let verticalSpacing: CGFloat
  public let content: (Item) -> Content

  public init(
    items: [Item],
    demandedWidthSize: CGFloat,
    horizontalSpacing: CGFloat = 8,
    verticalSpacing: CGFloat = 8,
    @ViewBuilder content: @escaping (Item) -> Content
  ) {
    self.items = items
    self.demandedWidthSize = demandedWidthSize
    self.horizontalSpacing = horizontalSpacing
    self.verticalSpacing = verticalSpacing
    self.content = content
  }

  public var body: some View {
    FlowLayout(
      spacing: self.horizontalSpacing,
      rowSpacing: self.verticalSpacing,
      maxWidth: self.demandedWidthSize
    ) {
      ForEach(self.items) { item in
        self.content(item)
      }
    }
  }
}

public struct FlowLayout: Layout {
  public var spacing: CGFloat
  public var rowSpacing: CGFloat

  /// If `nil`, uses the container's width. If specified, wraps at this width.
  public var maxWidth: CGFloat?

  public init(spacing: CGFloat = 8, rowSpacing: CGFloat = 8, maxWidth: CGFloat? = nil) {
    self.spacing = spacing
    self.rowSpacing = rowSpacing
    self.maxWidth = maxWidth
  }

  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize {
    let wrapWidth = self.maxWidth ?? proposal.width ?? .infinity
    guard wrapWidth.isFinite, !subviews.isEmpty else {
      // Stack vertically if width is unknown
      let totalHeight = subviews.reduce(0) { $0 + ($1.sizeThatFits(.unspecified).height) } +
        CGFloat(max(0, subviews.count - 1)) * self.rowSpacing
      let maxWidth = subviews.map { $0.sizeThatFits(.unspecified).width }.max() ?? 0
      return CGSize(width: maxWidth, height: totalHeight)
    }

    var lineWidth: CGFloat = 0
    var lineHeight: CGFloat = 0
    var totalHeight: CGFloat = 0
    var maxLineWidth: CGFloat = 0

    for sub in subviews {
      let size = sub.sizeThatFits(.unspecified)
      if lineWidth > 0, lineWidth + self.spacing + size.width > wrapWidth {
        // wrap
        totalHeight += lineHeight + self.rowSpacing
        maxLineWidth = max(maxLineWidth, lineWidth)
        lineWidth = size.width
        lineHeight = size.height
      } else {
        lineWidth += (lineWidth == 0 ? 0 : self.spacing) + size.width
        lineHeight = max(lineHeight, size.height)
      }
    }

    totalHeight += lineHeight // last line
    maxLineWidth = max(maxLineWidth, lineWidth)
    return CGSize(width: maxLineWidth, height: totalHeight)
  }

  public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    let wrapWidth = min(bounds.width, self.maxWidth ?? bounds.width)

    var x = bounds.minX
    var y = bounds.minY
    var lineHeight: CGFloat = 0

    for sub in subviews {
      let size = sub.sizeThatFits(.unspecified)

      if x > bounds.minX, x + self.spacing + size.width > bounds.minX + wrapWidth {
        // wrap to next line
        x = bounds.minX
        y += lineHeight + self.rowSpacing
        lineHeight = 0
      }

      sub.place(
        at: CGPoint(x: x, y: y),
        proposal: ProposedViewSize(size)
      )

      x += (x == bounds.minX ? 0 : self.spacing) + size.width
      lineHeight = max(lineHeight, size.height)
    }
  }
}
