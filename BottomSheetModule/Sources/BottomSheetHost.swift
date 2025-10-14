import SwiftUI

public struct BottomSheetModifier<SheetContent: View>: ViewModifier {
  @State private var showBottomSheet: Bool = true
  @State private var sheetDetent: PresentationDetent = .height(80)
  @State private var sheetHeight: CGFloat = 0
  @State private var animationDuration: CGFloat = 0
  @State private var toolbarOpacity: CGFloat = 1
  private let sheetContent: SheetContent

  public init(@ViewBuilder sheetContent: () -> SheetContent) {
    self.sheetContent = sheetContent()
  }

  public func body(content: Content) -> some View {
    content
      .background(Color.black)
      .sheet(isPresented: self.$showBottomSheet) {
        BottomSheetView(
          sheetDetent: self.$sheetDetent,
          content: {
            self.sheetContent
          }
        )
        .presentationDetents([.height(80), .height(350), .large])
        .presentationBackgroundInteraction(.enabled)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onGeometryChange(for: CGFloat.self) {
          max(min($0.size.height, 350), 0)
        } action: { oldValue, newValue in
          self.sheetHeight = newValue

          // Calculating Opacity
          let progress = max(min((newValue - 300) / 50, 1), 0)
          self.toolbarOpacity = 1 - progress

          // Calculating Animation Duration
          let diff = abs(newValue - oldValue)
          let duration = max(min(diff / 100, 0.3), 0)
          self.animationDuration = duration
        }
        .ignoresSafeArea()
        .interactiveDismissDisabled()
      }
      .ignoresSafeArea()
      .overlay(alignment: .bottomTrailing) {
        // trailing overlay (empty as in original)
      }
  }
}

// MARK: - Convenience API

public extension View {
  func bottomSheet<Sheet: View>(
    @ViewBuilder _ sheetContent: @escaping () -> Sheet
  ) -> some View {
    self.modifier(BottomSheetModifier(sheetContent: sheetContent))
  }
}

// MARK: - readSize utility

private struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}

private extension View {
  func readSize(onChange: @escaping (CGSize) -> ()) -> some View {
    background(
      GeometryReader { proxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: proxy.size)
      }
    )
    .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
  }
}

public struct BottomSheetView<Content: View>: View {
  @Binding var sheetDetent: PresentationDetent

  private let content: Content

  public init(
    sheetDetent: Binding<PresentationDetent>,
    @ViewBuilder content: () -> Content
  ) {
    self._sheetDetent = sheetDetent
    self.content = content()
  }

  public var body: some View {
    self.content
  }
}
