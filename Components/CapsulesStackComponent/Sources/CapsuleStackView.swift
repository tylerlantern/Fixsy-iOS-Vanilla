import SwiftUI

public struct CapsulesStackView<Item: Identifiable, Content: View>: View {
	public let items: [Item]
	public let horizontalSpacing: CGFloat
	public let verticalSpacing: CGFloat
	public let maxWidth: CGFloat?
	public let content: (Item) -> Content

	public init(
		items: [Item],
		horizontalSpacing: CGFloat = 8,
		verticalSpacing: CGFloat = 8,
		maxWidth: CGFloat? = nil,
		@ViewBuilder content: @escaping (Item) -> Content
	) {
		self.items = items
		self.horizontalSpacing = horizontalSpacing
		self.verticalSpacing = verticalSpacing
		self.maxWidth = maxWidth
		self.content = content
	}

	public var body: some View {
		FlowLayout(
			spacing: horizontalSpacing,
			rowSpacing: verticalSpacing,
			maxWidth: maxWidth
		) {
			ForEach(items) { item in
				content(item)
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

public struct FlowLayout: Layout {
	public var spacing: CGFloat
	public var rowSpacing: CGFloat
	public var maxWidth: CGFloat?   // if nil, use container width

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

		// Fallback when width is unknown (e.g., inside a Lazy* before layout pass):
		if !wrapWidth.isFinite || subviews.isEmpty {
			var totalHeight: CGFloat = 0
			var maxW: CGFloat = 0
			for sub in subviews {
				let s = sub.sizeThatFits(.unspecified)
				totalHeight += s.height
				maxW = max(maxW, s.width)
			}
			if subviews.count > 1 {
				totalHeight += CGFloat(subviews.count - 1) * rowSpacing
			}
			return CGSize(width: maxW, height: totalHeight)
		}

		// Normal wrapping measurement
		var lineWidth: CGFloat = 0
		var lineHeight: CGFloat = 0
		var totalHeight: CGFloat = 0
		var maxLineWidth: CGFloat = 0

		for sub in subviews {
			let size = sub.sizeThatFits(.unspecified)
			if lineWidth > 0, lineWidth + spacing + size.width > wrapWidth {
				totalHeight += lineHeight + rowSpacing
				maxLineWidth = max(maxLineWidth, lineWidth)
				lineWidth = size.width
				lineHeight = size.height
			} else {
				lineWidth += (lineWidth == 0 ? 0 : spacing) + size.width
				lineHeight = max(lineHeight, size.height)
			}
		}

		totalHeight += lineHeight
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

			if x > bounds.minX, x + spacing + size.width > bounds.minX + wrapWidth {
				x = bounds.minX
				y += lineHeight + rowSpacing
				lineHeight = 0
			}

			sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
			x += (x == bounds.minX ? 0 : spacing) + size.width
			lineHeight = max(lineHeight, size.height)
		}
	}
}
