import SwiftUI
import UIKit
import PlaceStore

public struct MapVisualKitView: UIViewControllerRepresentable {
  let channel: MapVisualChannel

  public init(
		channel: MapVisualChannel
	) {
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
