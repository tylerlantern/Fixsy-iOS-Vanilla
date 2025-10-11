import SwiftUI
import UIKit

public struct MapVisualKitView: UIViewControllerRepresentable {
  let channel: MapChannel

  public init(channel: MapChannel) {
    self.channel = channel
  }

  public func makeUIViewController(context: Context) -> UIViewController {
    MapVisualViewController(
      channel: self.channel
    )
  }

  public func updateUIViewController(
    _ uiViewController: UIViewController,
    context: Context
  ) {}
}
