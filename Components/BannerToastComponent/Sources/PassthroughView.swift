import SwiftUI
import UIKit

/// A container view that only returns true for touches that hit a subview.
/// Everywhere else, touches pass through to the app beneath.
final class PassthroughView: UIView {
  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    // Hit-test only interactive, visible subviews
    for sub in subviews where sub.isUserInteractionEnabled && !sub.isHidden && sub.alpha > 0.01 {
      let p = convert(point, to: sub)
      if sub.point(inside: p, with: event) { return true }
    }
    return false
  }
}

/// UIViewController that hosts SwiftUI inside a PassthroughView.
final class PassthroughContainerController<Content: View>: UIViewController {
  private let hosting: UIHostingController<Content>

  init(rootView: Content) {
    self.hosting = UIHostingController(rootView: rootView)
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func loadView() {
    let v = PassthroughView()
    v.backgroundColor = .clear
    view = v
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.hosting.view.backgroundColor = .clear
    addChild(self.hosting)
    self.hosting.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(self.hosting.view)
    NSLayoutConstraint.activate([
      self.hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      self.hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      self.hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
      self.hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    self.hosting.didMove(toParent: self)
  }
}
