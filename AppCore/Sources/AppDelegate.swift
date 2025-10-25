import UIKit
import Foundation
import AuthProvidersClient

final class AppDelegate: NSObject, UIApplicationDelegate {
	
	var authProvidersClient: AuthProvidersClient?
	
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {
		
		return true
	}
	
//	func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
//		
//	}
	
//	func application(_ app: UIApplication,
//									 open url: URL,
//									 options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//		var handled: Bool
//
//		handled = GIDSignIn.sharedInstance.handle(url)
//		if handled {
//			return true
//		}
//
//		// Handle other custom URL schemes if needed
//
//		return false
//	}
	
}
