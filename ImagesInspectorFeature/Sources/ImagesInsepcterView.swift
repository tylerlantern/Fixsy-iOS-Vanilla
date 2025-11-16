import SwiftUI

public struct ImagesInspectorView: View {
  public let urls: [URL]

  @State private var index: Int

  @Environment(\.dismiss) var dismiss

  public init(
    urls: [URL],
    initialIndex: Int
  ) {
    self.urls = urls
    self.index = initialIndex
  }

  public var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      TabView(selection: self.$index) {
        ForEach(self.urls.indices, id: \.self) { i in
          ZoomableAsyncImage(url: self.urls[i])
            .tag(i)
            .ignoresSafeArea(edges: .bottom)
            .background(Color.black.opacity(0.95))
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .automatic))
      .background(Color.black.edgesIgnoringSafeArea(.all))

      VStack {
        HStack {
          Spacer()
          Button(
            action: { self.dismiss() },
            label: {
              Label("Dismiss", systemImage: "xmark")
                .labelStyle(.iconOnly)
                .frame(width: 44, height: 44)
            }
          )
          .glassEffect() // keep your existing style
          .padding(.top, 8)
          .padding(.trailing, 12)
        }
        Spacer()
      }
    }
    // If the URL list changes and the current index is now invalid, fix it.
    .onChange(of: self.urls) { _, new in
      guard !new.isEmpty else { self.index = 0; return }
      if self.index >= new.count { self.index = max(0, new.count - 1) }
    }
  }
}

private struct ZoomableAsyncImage: View {
  let url: URL

  // Zoom & pan state
  @State private var scale: CGFloat = 1.0
  @State private var lastScale: CGFloat = 1.0
  @State private var offset: CGSize = .zero
  @State private var lastOffset: CGSize = .zero

  // Config
  private let minScale: CGFloat = 1.0
  private let maxScale: CGFloat = 4.0
  private let doubleTapZoomIn: CGFloat = 2.5

  var body: some View {
    GeometryReader { geo in
      let viewSize = geo.size

      AsyncImage(url: self.url, transaction: .init(animation: .easeInOut)) { phase in
        switch phase {
        case .empty:
          ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failure:
          VStack(spacing: 8) {
            Image(systemName: "photo").font(.system(size: 42, weight: .light))
            Text("Failed to load").font(.footnote)
          }
          .foregroundStyle(.white.opacity(0.7))
          .frame(maxWidth: .infinity, maxHeight: .infinity)

        case let .success(image):
          let magnify = MagnificationGesture()
            .onChanged { value in
              var new = self.lastScale * value
              new = min(max(new, self.minScale), self.maxScale)
              self.scale = new
              if self.scale <= 1.01 { self.offset = .zero; self.lastOffset = .zero }
            }
            .onEnded { _ in
              self.scale = min(max(self.scale, self.minScale), self.maxScale)
              self.lastScale = self.scale
              self.offset = self.clamped(offset: self.offset, scale: self.scale, in: viewSize)
              self.lastOffset = self.offset
            }

          let drag = DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
              guard self.scale > 1.01 else { return }
              let proposed = CGSize(
                width: lastOffset.width + value.translation.width,
                height: self.lastOffset.height + value.translation.height
              )
              self.offset = self.clamped(offset: proposed, scale: self.scale, in: viewSize)
            }
            .onEnded { _ in
              self.lastOffset = self.offset
            }

          let doubleTap = TapGesture(count: 2).onEnded {
            if self.scale > 1.01 {
              withAnimation(.spring) {
                self.scale = 1.0
                self.lastScale = 1.0
                self.offset = .zero
                self.lastOffset = .zero
              }
            } else {
              withAnimation(.spring) {
                self.scale = self.doubleTapZoomIn
                self.lastScale = self.scale
              }
            }
          }

          image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: viewSize.width)
            .scaleEffect(self.scale, anchor: .center)
            .offset(self.offset)
            .highPriorityGesture(self.scale > 1.01 ? drag : nil)
            .gesture(magnify)
            .simultaneousGesture(doubleTap)
            .contentShape(Rectangle())
            .animation(.interactiveSpring(), value: self.offset)
            .animation(.interactiveSpring(), value: self.scale)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.black)

        @unknown default:
          EmptyView()
        }
      }
    }
  }

  private func clamped(offset: CGSize, scale: CGFloat, in size: CGSize) -> CGSize {
    guard scale > 1.01 else { return .zero }
    let contentWidth = size.width * scale
    let maxX = max(0, (contentWidth - size.width) / 2)
    let contentHeight = size.height * scale
    let maxY = max(0, (contentHeight - size.height) / 2)

    let clampedX = min(max(offset.width, -maxX), maxX)
    let clampedY = min(max(offset.height, -maxY), maxY)
    return CGSize(width: clampedX, height: clampedY)
  }
}
