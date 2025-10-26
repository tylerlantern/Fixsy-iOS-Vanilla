import AuthProvidersClient
import Foundation
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
  var authProvidersClient: AuthProvidersClient?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    true
  }
}
