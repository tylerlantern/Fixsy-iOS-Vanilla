import SwiftUI

public struct BottomSheetModifier<SheetContent: View>: ViewModifier {
  @State private var animationDuration: CGFloat = 0
  @State private var toolbarOpacity: CGFloat = 1

  @Binding var show: Bool
  @Binding var detent: PresentationDetent
  @Binding private var sheetHeight: CGFloat
  private let sheetContent: SheetContent

  public init(
    show: Binding<Bool>,
    detent: Binding<PresentationDetent>,
    sheetHeight: Binding<CGFloat>,
    @ViewBuilder sheetContent: () -> SheetContent
  ) {
    self._show = show
    self._detent = detent
    self._sheetHeight = sheetHeight
    self.sheetContent = sheetContent()
  }

  public func body(content: Content) -> some View {
    content
      .background(Color.black)
      .sheet(isPresented: self.$show) {
        BottomSheetView(
          sheetDetent: self.$detent,
          content: {
            self.sheetContent
          }
        )
        .presentationDetents(
          [
            BottomSheetDetents.collapsed,
            BottomSheetDetents.medium,
            BottomSheetDetents.expanded
          ],
          selection: self.$detent
        )
        .presentationBackgroundInteraction(.enabled)
        .presentationSizing(
          .automatic
            .fitted(horizontal: true, vertical: true) // fit to content
            .sticky(vertical: true) // grow but don't shrink
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onGeometryChange(for: CGFloat.self) {
          max(min($0.size.height, 350), 0)
        } action: { oldValue, newValue in
					print("NEW SHEET HEIGHT",newValue)
          self.sheetHeight = newValue
          let progress = max(min((newValue - 300) / 50, 1), 0)
          self.toolbarOpacity = 1 - progress
          let diff = abs(newValue - oldValue)
          let duration = max(min(diff / 100, 0.3), 0)
          self.animationDuration = duration
        }
        .ignoresSafeArea()
        .interactiveDismissDisabled()
      }
      .ignoresSafeArea()
      .overlay(alignment: .bottomTrailing) {}
  }
}

public extension View {
  func bottomSheet<Sheet: View>(
    show: Binding<Bool> = .constant(true),
    detent: Binding<PresentationDetent>,
    sheetHeight: Binding<CGFloat>,
    @ViewBuilder _ sheetContent: @escaping () -> Sheet
  ) -> some View {
    self.modifier(
      BottomSheetModifier(
        show: show,
        detent: detent,
        sheetHeight: sheetHeight,
        sheetContent: sheetContent
      )
    )
  }
}

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

public enum BottomSheetDetents {
  public static let collapsed = PresentationDetent.height(76)
  public static let medium = PresentationDetent.medium
  public static let expanded = PresentationDetent.large
}
