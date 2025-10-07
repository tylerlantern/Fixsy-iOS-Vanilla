import SwiftUI

public struct ExpandedCommentView: View {
  @Binding var navPath: NavigationPath
  @Environment(\.dismiss) var dismiss

  public init(
    navPath: Binding<NavigationPath>
  ) {
    self._navPath = navPath
  }

  public var body: some View {
    VStack {
      Text("Hello, ExpandedComment View!")
      Button {
        self.dismiss()
      } label: {
        Text("Dismiss")
      }
    }
  }
}
